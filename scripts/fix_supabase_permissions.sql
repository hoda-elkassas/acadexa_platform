-- ============================================================
-- Acadexa Platform - Fix Supabase Table Permissions
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================
-- Problem: 16 tables are returning "permission denied" for service_role
-- Only students, student_semesters, student_courses are accessible.
-- Root cause: Tables were created without granting access to service_role.
-- ============================================================

-- GRANT full access to service_role (bypasses RLS for backend)
GRANT ALL ON public.departments              TO service_role;
GRANT ALL ON public.study_plans             TO service_role;
GRANT ALL ON public.courses                 TO service_role;
GRANT ALL ON public.prerequisites           TO service_role;
GRANT ALL ON public.elective_groups         TO service_role;
GRANT ALL ON public.elective_group_courses  TO service_role;
GRANT ALL ON public.plan_structure          TO service_role;
GRANT ALL ON public.academic_load_rules     TO service_role;
GRANT ALL ON public.graduation_requirements TO service_role;
GRANT ALL ON public.grading_scales          TO service_role;
GRANT ALL ON public.grade_scale_items       TO service_role;
GRANT ALL ON public.analysis_results        TO service_role;
GRANT ALL ON public.analysis_issues         TO service_role;
GRANT ALL ON public.analysis_recommendations TO service_role;
GRANT ALL ON public.import_jobs             TO service_role;
GRANT ALL ON public.field_training_rules    TO service_role;

-- Also GRANT to anon role (for Flutter frontend with anon key)
GRANT SELECT ON public.departments              TO anon;
GRANT SELECT ON public.study_plans             TO anon;
GRANT SELECT ON public.courses                 TO anon;
GRANT SELECT ON public.prerequisites           TO anon;
GRANT SELECT ON public.elective_groups         TO anon;
GRANT SELECT ON public.elective_group_courses  TO anon;
GRANT SELECT ON public.plan_structure          TO anon;
GRANT SELECT ON public.academic_load_rules     TO anon;
GRANT SELECT ON public.graduation_requirements TO anon;
GRANT SELECT ON public.grading_scales          TO anon;
GRANT SELECT ON public.grade_scale_items       TO anon;
GRANT SELECT ON public.analysis_results        TO anon;
GRANT SELECT ON public.analysis_issues         TO anon;
GRANT SELECT ON public.analysis_recommendations TO anon;
GRANT SELECT ON public.import_jobs             TO anon;
GRANT SELECT ON public.field_training_rules    TO anon;

-- Also grant for authenticated role (Flutter users logged in)
GRANT SELECT ON public.departments              TO authenticated;
GRANT SELECT ON public.study_plans             TO authenticated;
GRANT SELECT ON public.courses                 TO authenticated;
GRANT SELECT ON public.prerequisites           TO authenticated;
GRANT SELECT ON public.elective_groups         TO authenticated;
GRANT SELECT ON public.elective_group_courses  TO authenticated;
GRANT SELECT ON public.plan_structure          TO authenticated;
GRANT SELECT ON public.academic_load_rules     TO authenticated;
GRANT SELECT ON public.graduation_requirements TO authenticated;
GRANT SELECT ON public.grading_scales          TO authenticated;
GRANT SELECT ON public.grade_scale_items       TO authenticated;
GRANT SELECT ON public.analysis_results        TO authenticated;
GRANT SELECT ON public.analysis_issues         TO authenticated;
GRANT SELECT ON public.analysis_recommendations TO authenticated;
GRANT SELECT ON public.import_jobs             TO authenticated;
GRANT SELECT ON public.field_training_rules    TO authenticated;

-- Also enable RLS on these tables so policies apply properly
ALTER TABLE public.departments              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_plans             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prerequisites           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.elective_groups         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.elective_group_courses  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plan_structure          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_load_rules     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.graduation_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grading_scales          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grade_scale_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_results        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_issues         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.import_jobs             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.field_training_rules    ENABLE ROW LEVEL SECURITY;

-- Create permissive SELECT policies for public read access (anon + authenticated)
-- (Only creates policy if it doesn't already exist)

DO $$
DECLARE
  tables TEXT[] := ARRAY[
    'departments','study_plans','courses','prerequisites',
    'elective_groups','elective_group_courses','plan_structure',
    'academic_load_rules','graduation_requirements','grading_scales',
    'grade_scale_items','analysis_results','analysis_issues',
    'analysis_recommendations','import_jobs','field_training_rules'
  ];
  t TEXT;
BEGIN
  FOREACH t IN ARRAY tables LOOP
    -- Drop old conflicting policy if it exists
    EXECUTE format('DROP POLICY IF EXISTS "public_read_%s" ON public.%I', t, t);
    -- Create new open read policy
    EXECUTE format(
      'CREATE POLICY "public_read_%s" ON public.%I FOR SELECT USING (true)',
      t, t
    );
  END LOOP;
END
$$;

-- ============================================================
-- Verify: Run these SELECT statements to confirm access
-- ============================================================
-- SELECT count(*) FROM public.departments;
-- SELECT count(*) FROM public.study_plans;
-- SELECT count(*) FROM public.courses;
-- SELECT count(*) FROM public.analysis_results;
