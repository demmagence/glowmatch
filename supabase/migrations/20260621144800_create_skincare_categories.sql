-- Create skincare_categories table
CREATE TABLE IF NOT EXISTS public.skincare_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  color text NOT NULL DEFAULT '0xFFE040FB',
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.skincare_categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow read access to defaults and owned categories" ON public.skincare_categories;
DROP POLICY IF EXISTS "Allow insert access to owned categories" ON public.skincare_categories;
DROP POLICY IF EXISTS "Allow update access to owned categories" ON public.skincare_categories;
DROP POLICY IF EXISTS "Allow delete access to owned categories" ON public.skincare_categories;

-- Create RLS Policies
CREATE POLICY "Allow read access to defaults and owned categories" ON public.skincare_categories
  FOR SELECT
  USING (is_default = true OR auth.uid() = user_id);

CREATE POLICY "Allow insert access to owned categories" ON public.skincare_categories
  FOR INSERT
  WITH CHECK (auth.uid() = user_id AND is_default = false);

CREATE POLICY "Allow update access to owned categories" ON public.skincare_categories
  FOR UPDATE
  USING (auth.uid() = user_id AND is_default = false);

CREATE POLICY "Allow delete access to owned categories" ON public.skincare_categories
  FOR DELETE
  USING (auth.uid() = user_id AND is_default = false);

-- Seed default categories safely without duplication
INSERT INTO public.skincare_categories (name, color, is_default)
SELECT name, color, is_default FROM (
  VALUES 
    ('Serum', '0xFFE040FB', true),
    ('Sunscreen', '0xFF64DD17', true),
    ('Moisturizer', '0xFFD50000', true),
    ('Cleanser', '0xFF29B6F6', true),
    ('Toner', '0xFFFFD600', true),
    ('Exfoliant', '0xFFFF6D00', true),
    ('Mask', '0xFF00BFA5', true),
    ('Eye Cream', '0xFFFF4081', true)
) as v(name, color, is_default)
WHERE NOT EXISTS (
  SELECT 1 FROM public.skincare_categories WHERE public.skincare_categories.name = v.name AND public.skincare_categories.is_default = true
);
