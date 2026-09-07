-- Production hardening for the complete GlowMatch schema.

ALTER TABLE public.skincare_shelf
  ALTER COLUMN user_id SET NOT NULL,
  ADD CONSTRAINT skincare_shelf_price_nonnegative CHECK (price >= 0),
  ADD CONSTRAINT skincare_shelf_estimated_uses_nonnegative CHECK (estimated_uses >= 0),
  ADD CONSTRAINT skincare_shelf_remaining_uses_nonnegative CHECK (remaining_uses >= 0);

ALTER TABLE public.routines
  ALTER COLUMN user_id SET NOT NULL,
  ALTER COLUMN step_number SET NOT NULL,
  ADD CONSTRAINT routines_type_valid CHECK (routine_type IN ('AM', 'PM')),
  ADD CONSTRAINT routines_step_number_positive CHECK (step_number > 0);

ALTER TABLE public.journal_entries
  ALTER COLUMN user_id SET NOT NULL,
  ADD CONSTRAINT journal_entries_skin_score_valid
    CHECK (skin_score IS NULL OR skin_score BETWEEN 0 AND 100);

ALTER TABLE public.user_streaks ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE public.daily_completion_log ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE public.routine_step_completions
  ALTER COLUMN user_id SET NOT NULL,
  ALTER COLUMN step_id SET NOT NULL;

CREATE INDEX IF NOT EXISTS skincare_shelf_user_created_idx
  ON public.skincare_shelf (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS routines_user_type_step_idx
  ON public.routines (user_id, routine_type, step_number);
CREATE INDEX IF NOT EXISTS journal_entries_user_created_idx
  ON public.journal_entries (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS daily_completion_log_user_date_idx
  ON public.daily_completion_log (user_id, completion_date DESC);
CREATE INDEX IF NOT EXISTS routine_step_completions_user_date_idx
  ON public.routine_step_completions (user_id, completion_date DESC);

CREATE UNIQUE INDEX IF NOT EXISTS skincare_categories_default_name_uidx
  ON public.skincare_categories (lower(name))
  WHERE is_default = true;
CREATE UNIQUE INDEX IF NOT EXISTS skincare_categories_user_name_uidx
  ON public.skincare_categories (user_id, lower(name))
  WHERE is_default = false;

DROP POLICY IF EXISTS "Allow update access to owned categories" ON public.skincare_categories;
CREATE POLICY "Allow update access to owned categories" ON public.skincare_categories
  FOR UPDATE
  USING (auth.uid() = user_id AND is_default = false)
  WITH CHECK (auth.uid() = user_id AND is_default = false);

-- Journal photos can contain sensitive skin images. Product photos use the
-- same authenticated access model so object URLs cannot bypass RLS.
UPDATE storage.buckets
SET public = false
WHERE id IN ('journal-photos', 'product-photos');

