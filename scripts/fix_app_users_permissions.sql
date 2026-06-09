-- ============================================================
-- Acadexa Platform - Fix app_users & Views Permissions
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================
-- Problem: app_users table, v_users_with_roles view, and
-- student_latest_analysis view return "permission denied" (42501)
-- for service_role, anon, and authenticated.
-- ============================================================

-- 1. Grant permissions on public.app_users table
GRANT ALL ON public.app_users TO service_role;
GRANT SELECT ON public.app_users TO anon;
GRANT SELECT, UPDATE ON public.app_users TO authenticated;

-- 2. Grant permissions on public.system_roles table (referenced by role checks)
GRANT ALL ON public.system_roles TO service_role;
GRANT SELECT ON public.system_roles TO anon;
GRANT SELECT ON public.system_roles TO authenticated;

-- 3. Grant permissions on views used in Flutter dashboard & services
-- v_users_with_roles view
GRANT SELECT ON public.v_users_with_roles TO service_role;
GRANT SELECT ON public.v_users_with_roles TO anon;
GRANT SELECT ON public.v_users_with_roles TO authenticated;

-- student_latest_analysis view
GRANT SELECT ON public.student_latest_analysis TO service_role;
GRANT SELECT ON public.student_latest_analysis TO anon;
GRANT SELECT ON public.student_latest_analysis TO authenticated;

-- 4. Enable Row Level Security (RLS) on app_users
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;

-- Create permissive SELECT policy for app_users (public read)
DROP POLICY IF EXISTS "public_read_app_users" ON public.app_users;
CREATE POLICY "public_read_app_users" ON public.app_users
  FOR SELECT USING (true);

-- Allow service_role full access (bypass RLS)
DROP POLICY IF EXISTS "service_role_all_app_users" ON public.app_users;
CREATE POLICY "service_role_all_app_users" ON public.app_users
  FOR ALL USING (true);

-- ============================================================
-- Verification: Run these SELECT statements to confirm access
-- ============================================================
-- SELECT * FROM public.app_users LIMIT 5;
-- SELECT * FROM public.v_users_with_roles LIMIT 5;
-- SELECT * FROM public.student_latest_analysis LIMIT 5;
