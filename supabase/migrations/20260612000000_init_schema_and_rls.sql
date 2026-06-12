-- 1. Create skincare_shelf table if not exists
CREATE TABLE IF NOT EXISTS public.skincare_shelf (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  brand text,
  category text,
  price double precision DEFAULT 0.0,
  estimated_uses integer DEFAULT 50,
  remaining_uses integer DEFAULT 50,
  indicator_color text,
  image_url text,
  ingredients text[],
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create routines table if not exists
CREATE TABLE IF NOT EXISTS public.routines (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  routine_type text NOT NULL,
  step_number integer,
  name text NOT NULL,
  description text,
  shelf_item_id text REFERENCES public.skincare_shelf(id) ON DELETE SET NULL
);

-- 3. Create journal_entries table if not exists
CREATE TABLE IF NOT EXISTS public.journal_entries (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  logged_date text,
  skin_score integer,
  photo_path text,
  notes text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Enable Row Level Security (RLS) on all tables
ALTER TABLE public.skincare_shelf ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

-- 5. Drop existing policies to avoid conflicts on re-run
DROP POLICY IF EXISTS "Users can manage own shelf items" ON public.skincare_shelf;
DROP POLICY IF EXISTS "Users can manage own routines" ON public.routines;
DROP POLICY IF EXISTS "Users can manage own journal entries" ON public.journal_entries;

-- 6. Create RLS Policies for skincare_shelf
CREATE POLICY "Users can manage own shelf items" ON public.skincare_shelf
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 7. Create RLS Policies for routines
CREATE POLICY "Users can manage own routines" ON public.routines
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 8. Create RLS Policies for journal_entries
CREATE POLICY "Users can manage own journal entries" ON public.journal_entries
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 9. Create journal-photos storage bucket if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('journal-photos', 'journal-photos', true)
ON CONFLICT (id) DO NOTHING;

-- 10. Drop existing storage policies if they exist to avoid conflicts on re-run
DROP POLICY IF EXISTS "Allow user upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Allow user read own folder" ON storage.objects;
DROP POLICY IF EXISTS "Allow user update own folder" ON storage.objects;
DROP POLICY IF EXISTS "Allow user delete own folder" ON storage.objects;

-- 11. Create Storage policies for journal-photos bucket
CREATE POLICY "Allow user upload own folder" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'journal-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Allow user read own folder" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'journal-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Allow user update own folder" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'journal-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Allow user delete own folder" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'journal-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );
