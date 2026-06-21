-- Add product_size column to skincare_shelf table
ALTER TABLE public.skincare_shelf ADD COLUMN IF NOT EXISTS product_size TEXT;
