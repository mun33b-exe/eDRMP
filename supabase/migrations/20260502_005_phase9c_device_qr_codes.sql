-- Phase 9C — device_qr_codes additional RLS policies
-- The device_qr_codes table was created in Phase 9A migration 001.
-- This file adds PTA insert/update policies required for the QR workflow.
-- Safe to run multiple times (DROP POLICY IF EXISTS before CREATE).

-- INSERT policy: PTA users insert QR code records after approving a device.
DROP POLICY IF EXISTS "qr_codes_pta_insert" ON public.device_qr_codes;
CREATE POLICY "qr_codes_pta_insert" ON public.device_qr_codes
  FOR INSERT TO authenticated
  WITH CHECK (public.get_user_role() = 'pta');

-- UPDATE policy: PTA can update the storage path after the QR image is uploaded.
DROP POLICY IF EXISTS "qr_codes_pta_update" ON public.device_qr_codes;
CREATE POLICY "qr_codes_pta_update" ON public.device_qr_codes
  FOR UPDATE TO authenticated
  USING (public.get_user_role() = 'pta');
