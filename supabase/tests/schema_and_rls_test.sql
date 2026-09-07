BEGIN;
SELECT plan(29);

SELECT has_table('public', 'skincare_shelf', 'skincare_shelf exists');
SELECT has_table('public', 'routines', 'routines exists');
SELECT has_table('public', 'journal_entries', 'journal_entries exists');
SELECT has_table('public', 'user_streaks', 'user_streaks exists');
SELECT has_table('public', 'skincare_categories', 'skincare_categories exists');
SELECT has_table('public', 'daily_completion_log', 'daily_completion_log exists');
SELECT has_table('public', 'routine_step_completions', 'routine_step_completions exists');

SELECT col_not_null('public', 'skincare_shelf', 'user_id', 'shelf owner is required');
SELECT col_not_null('public', 'routines', 'user_id', 'routine owner is required');
SELECT col_not_null('public', 'journal_entries', 'user_id', 'journal owner is required');
SELECT col_not_null('public', 'user_streaks', 'user_id', 'streak owner is required');
SELECT col_not_null('public', 'daily_completion_log', 'user_id', 'completion owner is required');
SELECT col_not_null('public', 'routine_step_completions', 'user_id', 'step completion owner is required');
SELECT col_not_null('public', 'routine_step_completions', 'step_id', 'completed step is required');

SELECT is(
  (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.skincare_shelf'::regclass),
  true,
  'shelf RLS is enabled'
);
SELECT is((SELECT relrowsecurity FROM pg_class WHERE oid = 'public.routines'::regclass), true, 'routine RLS is enabled');
SELECT is((SELECT relrowsecurity FROM pg_class WHERE oid = 'public.journal_entries'::regclass), true, 'journal RLS is enabled');
SELECT is((SELECT relrowsecurity FROM pg_class WHERE oid = 'public.user_streaks'::regclass), true, 'streak RLS is enabled');
SELECT is((SELECT relrowsecurity FROM pg_class WHERE oid = 'public.skincare_categories'::regclass), true, 'category RLS is enabled');
SELECT is((SELECT relrowsecurity FROM pg_class WHERE oid = 'public.daily_completion_log'::regclass), true, 'daily log RLS is enabled');
SELECT is((SELECT relrowsecurity FROM pg_class WHERE oid = 'public.routine_step_completions'::regclass), true, 'step completion RLS is enabled');

SELECT policies_are('public', 'skincare_shelf', ARRAY['Users can manage own shelf items'], 'shelf policy is installed');
SELECT policies_are('public', 'routines', ARRAY['Users can manage own routines'], 'routine policy is installed');
SELECT policies_are('public', 'journal_entries', ARRAY['Users can manage own journal entries'], 'journal policy is installed');
SELECT policies_are('public', 'user_streaks', ARRAY['Users can manage own streaks'], 'streak policy is installed');
SELECT policies_are('public', 'daily_completion_log', ARRAY['Users can manage own completion log'], 'daily log policy is installed');
SELECT policies_are('public', 'routine_step_completions', ARRAY['Users can manage own step completions'], 'step completion policy is installed');

SELECT is((SELECT public FROM storage.buckets WHERE id = 'journal-photos'), false, 'journal bucket is private');
SELECT is((SELECT public FROM storage.buckets WHERE id = 'product-photos'), false, 'product bucket is private');

SELECT * FROM finish();
ROLLBACK;

