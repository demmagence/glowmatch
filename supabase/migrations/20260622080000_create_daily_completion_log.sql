-- Create daily_completion_log table
CREATE TABLE IF NOT EXISTS public.daily_completion_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  completion_date date NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, completion_date)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.daily_completion_log ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any to avoid conflicts
DROP POLICY IF EXISTS "Users can manage own completion log" ON public.daily_completion_log;

-- Create RLS Policies for daily_completion_log
CREATE POLICY "Users can manage own completion log" ON public.daily_completion_log
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
