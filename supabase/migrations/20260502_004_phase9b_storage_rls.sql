-- Phase 9B: Storage buckets + RLS for fir-documents and device-qr-codes

-- Ensure buckets exist (no-op if already created via dashboard)
INSERT INTO storage.buckets (id, name, public)
VALUES ('fir-documents',   'fir-documents',   false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('device-qr-codes', 'device-qr-codes', true)
ON CONFLICT (id) DO NOTHING;

-- ── fir-documents (private) ─────────────────────────────────────────────────

DROP POLICY IF EXISTS "fir_docs_owner_insert" ON storage.objects;
DROP POLICY IF EXISTS "fir_docs_owner_select"  ON storage.objects;
DROP POLICY IF EXISTS "fir_docs_admin_select"  ON storage.objects;

-- Citizens may upload to their own folder: fir-documents/<user_id>/...
CREATE POLICY "fir_docs_owner_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'fir-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Citizens may read their own uploads
CREATE POLICY "fir_docs_owner_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'fir-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Police and PTA may read all fir-documents
CREATE POLICY "fir_docs_admin_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'fir-documents'
    AND public.get_user_role() IN ('police', 'pta')
  );

-- ── device-qr-codes (public read) ───────────────────────────────────────────

DROP POLICY IF EXISTS "qr_codes_auth_insert"  ON storage.objects;
DROP POLICY IF EXISTS "qr_codes_public_select" ON storage.objects;

-- Only authenticated users (service role via Phase 9C) may upload QR codes
CREATE POLICY "qr_codes_auth_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'device-qr-codes'
    AND auth.role() = 'authenticated'
  );

-- All authenticated users may read QR codes (needed for verify screen)
CREATE POLICY "qr_codes_public_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'device-qr-codes'
    AND auth.role() = 'authenticated'
  );
