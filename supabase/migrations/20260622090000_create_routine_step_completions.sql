-- Create routine_step_completions table
CREATE TABLE IF NOT EXISTS public.routine_step_completions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  step_id text REFERENCES public.routines(id) ON DELETE CASCADE,
  completion_date date NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, step_id, completion_date)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.routine_step_completions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any to avoid conflicts
DROP POLICY IF EXISTS "Users can manage own step completions" ON public.routine_step_completions;

-- Create RLS Policies for routine_step_completions
CREATE POLICY "Users can manage own step completions" ON public.routine_step_completions
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
