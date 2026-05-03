-- Storage bucket for purchase invoices uploaded during device registration

INSERT INTO storage.buckets (id, name, public)
VALUES ('device-invoices', 'device-invoices', false)
ON CONFLICT (id) DO NOTHING;

-- Owner can upload invoices to their own folder: device-invoices/<user_id>/...
CREATE POLICY "invoice_owner_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'device-invoices'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Owner can read their own invoices
CREATE POLICY "invoice_owner_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'device-invoices'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- PTA and police can read all invoices (for verification)
CREATE POLICY "invoice_admin_select"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'device-invoices'
    AND public.get_user_role() IN ('police', 'pta')
  );
