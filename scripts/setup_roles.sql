-- ============================================================
-- Acadexa Platform — RBAC Setup
-- Run this in Supabase SQL Editor ONCE
-- ============================================================
-- Roles:
--   admin             → full CRUD on everything
--   academic_advisor  → read all students + write analysis
--   dashboard_viewer  → read-only (summary/stats)
--   user              → read only their own student record
-- ============================================================

-- ─── 1. user_profiles table ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id            uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role          text NOT NULL DEFAULT 'user'
                CHECK (role IN ('admin','academic_advisor','dashboard_viewer','user')),
  full_name     text,
  department_id uuid REFERENCES public.departments(id),
  student_id    uuid REFERENCES public.students(id),  -- only for 'user' role
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

GRANT ALL    ON public.user_profiles TO service_role;
GRANT SELECT ON public.user_profiles TO anon;
GRANT SELECT, UPDATE ON public.user_profiles TO authenticated;

-- ─── 2. Helper: get current user's role ─────────────────────
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.user_profiles WHERE id = auth.uid()
$$;

-- ─── 3. Auto-create profile when admin creates a user ───────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, role, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── 4. user_profiles RLS ───────────────────────────────────
DROP POLICY IF EXISTS "profiles_read_own"   ON public.user_profiles;
DROP POLICY IF EXISTS "profiles_admin_all"  ON public.user_profiles;

CREATE POLICY "profiles_read_own" ON public.user_profiles
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "profiles_admin_all" ON public.user_profiles
  FOR ALL USING (get_my_role() = 'admin');

-- ─── 5. students — role-based access ────────────────────────
-- Remove the old open-read policy
DROP POLICY IF EXISTS "public_read_students" ON public.students;

-- admin: everything
DROP POLICY IF EXISTS "admin_all_students"        ON public.students;
DROP POLICY IF EXISTS "advisor_read_students"     ON public.students;
DROP POLICY IF EXISTS "viewer_read_students"      ON public.students;
DROP POLICY IF EXISTS "user_read_own_student"     ON public.students;

CREATE POLICY "admin_all_students" ON public.students
  FOR ALL USING (get_my_role() = 'admin');

CREATE POLICY "advisor_read_students" ON public.students
  FOR SELECT USING (get_my_role() = 'academic_advisor');

CREATE POLICY "viewer_read_students" ON public.students
  FOR SELECT USING (get_my_role() = 'dashboard_viewer');

CREATE POLICY "user_read_own_student" ON public.students
  FOR SELECT USING (
    id = (SELECT student_id FROM public.user_profiles WHERE id = auth.uid())
  );

-- ─── 6. student_semesters ───────────────────────────────────
DROP POLICY IF EXISTS "public_read_student_semesters" ON public.student_semesters;
DROP POLICY IF EXISTS "admin_all_semesters"           ON public.student_semesters;
DROP POLICY IF EXISTS "advisor_read_semesters"        ON public.student_semesters;
DROP POLICY IF EXISTS "user_read_own_semesters"       ON public.student_semesters;

CREATE POLICY "admin_all_semesters" ON public.student_semesters
  FOR ALL USING (get_my_role() = 'admin');

CREATE POLICY "advisor_read_semesters" ON public.student_semesters
  FOR SELECT USING (get_my_role() = 'academic_advisor');

CREATE POLICY "user_read_own_semesters" ON public.student_semesters
  FOR SELECT USING (
    student_id = (SELECT student_id FROM public.user_profiles WHERE id = auth.uid())
  );

-- ─── 7. student_courses ─────────────────────────────────────
DROP POLICY IF EXISTS "public_read_student_courses" ON public.student_courses;
DROP POLICY IF EXISTS "admin_all_courses_s"         ON public.student_courses;
DROP POLICY IF EXISTS "advisor_read_courses_s"      ON public.student_courses;
DROP POLICY IF EXISTS "user_read_own_courses_s"     ON public.student_courses;

CREATE POLICY "admin_all_courses_s" ON public.student_courses
  FOR ALL USING (get_my_role() = 'admin');

CREATE POLICY "advisor_read_courses_s" ON public.student_courses
  FOR SELECT USING (get_my_role() = 'academic_advisor');

CREATE POLICY "user_read_own_courses_s" ON public.student_courses
  FOR SELECT USING (
    student_id = (SELECT student_id FROM public.user_profiles WHERE id = auth.uid())
  );

-- ─── 8. Curriculum tables — read for all authenticated roles ─
-- (admin + advisor + viewer + user can all see curriculum)
DO $$
DECLARE
  curriculum_tables TEXT[] := ARRAY[
    'departments','study_plans','courses','prerequisites',
    'elective_groups','elective_group_courses','plan_structure',
    'grading_scales','grade_scale_items'
  ];
  t TEXT;
BEGIN
  FOREACH t IN ARRAY curriculum_tables LOOP
    -- Drop old open policy
    EXECUTE format('DROP POLICY IF EXISTS "public_read_%s" ON public.%I', t, t);
    -- Admin: full CRUD
    EXECUTE format('DROP POLICY IF EXISTS "admin_all_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "admin_all_%s" ON public.%I FOR ALL USING (get_my_role() = ''admin'')',
      t, t
    );
    -- Everyone else: SELECT only
    EXECUTE format('DROP POLICY IF EXISTS "auth_read_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "auth_read_%s" ON public.%I FOR SELECT USING (auth.uid() IS NOT NULL)',
      t, t
    );
  END LOOP;
END
$$;

-- ─── 9. analysis tables — advisor can write, user reads own ──
DO $$
DECLARE
  analysis_tables TEXT[] := ARRAY[
    'analysis_results','analysis_issues','analysis_recommendations'
  ];
  t TEXT;
BEGIN
  FOREACH t IN ARRAY analysis_tables LOOP
    EXECUTE format('DROP POLICY IF EXISTS "public_read_%s" ON public.%I', t, t);

    -- Admin: all
    EXECUTE format('DROP POLICY IF EXISTS "admin_all_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "admin_all_%s" ON public.%I FOR ALL USING (get_my_role() = ''admin'')',
      t, t
    );
    -- Advisor: all (read + write analysis)
    EXECUTE format('DROP POLICY IF EXISTS "advisor_all_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "advisor_all_%s" ON public.%I FOR ALL USING (get_my_role() = ''academic_advisor'')',
      t, t
    );
    -- Viewer: read all
    EXECUTE format('DROP POLICY IF EXISTS "viewer_read_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "viewer_read_%s" ON public.%I FOR SELECT USING (get_my_role() = ''dashboard_viewer'')',
      t, t
    );
    -- User: read their own
    EXECUTE format('DROP POLICY IF EXISTS "user_read_own_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "user_read_own_%s" ON public.%I FOR SELECT USING (
        student_id = (SELECT student_id FROM public.user_profiles WHERE id = auth.uid())
      )',
      t, t
    );
  END LOOP;
END
$$;

-- ─── 10. import_jobs — admin all, advisor read+insert ────────
DROP POLICY IF EXISTS "public_read_import_jobs"  ON public.import_jobs;
DROP POLICY IF EXISTS "admin_all_import_jobs"    ON public.import_jobs;
DROP POLICY IF EXISTS "advisor_rw_import_jobs"   ON public.import_jobs;

CREATE POLICY "admin_all_import_jobs" ON public.import_jobs
  FOR ALL USING (get_my_role() = 'admin');

CREATE POLICY "advisor_rw_import_jobs" ON public.import_jobs
  FOR ALL USING (get_my_role() = 'academic_advisor');

-- ─── 11. academic_load_rules / graduation_requirements / field_training_rules ─
DO $$
DECLARE
  config_tables TEXT[] := ARRAY[
    'academic_load_rules','graduation_requirements','field_training_rules'
  ];
  t TEXT;
BEGIN
  FOREACH t IN ARRAY config_tables LOOP
    EXECUTE format('DROP POLICY IF EXISTS "public_read_%s" ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS "admin_all_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "admin_all_%s" ON public.%I FOR ALL USING (get_my_role() = ''admin'')',
      t, t
    );
    EXECUTE format('DROP POLICY IF EXISTS "auth_read_%s" ON public.%I', t, t);
    EXECUTE format(
      'CREATE POLICY "auth_read_%s" ON public.%I FOR SELECT USING (auth.uid() IS NOT NULL)',
      t, t
    );
  END LOOP;
END
$$;

-- ============================================================
-- Manual step after running this script:
-- Go to Supabase Dashboard → Authentication → Users
-- Create users and set their metadata:
--   { "role": "admin", "full_name": "Admin Name" }
--   { "role": "academic_advisor", "full_name": "Advisor Name" }
--   { "role": "dashboard_viewer", "full_name": "Viewer Name" }
--   { "role": "user", "full_name": "Student Name" }
--
-- Then for 'user' role, link to student record:
--   UPDATE public.user_profiles
--   SET student_id = '<student-uuid>'
--   WHERE id = '<auth-user-uuid>';
-- ============================================================
