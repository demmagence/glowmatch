-- Create product-photos storage bucket if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-photos', 'product-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing storage policies if they exist to avoid conflicts on re-run
DROP POLICY IF EXISTS "Allow user upload own product photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow user read own product photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow user update own product photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow user delete own product photos" ON storage.objects;

-- Create Storage policies for product-photos bucket
CREATE POLICY "Allow user upload own product photos" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'product-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Allow user read own product photos" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'product-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Allow user update own product photos" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'product-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Allow user delete own product photos" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'product-photos' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );
