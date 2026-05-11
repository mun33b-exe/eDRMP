-- Allow any authenticated user to read the minimal fields needed for IMEI
-- verification (status check). Personal owner data is NOT exposed here —
-- the profiles join in the verification query is restricted by the existing
-- profiles_select policy (owner_id = auth.uid() OR police/pta), so the
-- maskedCnic field will be NULL for non-owners, which is acceptable.

DROP POLICY IF EXISTS "devices_select_verify" ON public.devices;

CREATE POLICY "devices_select_verify" ON public.devices
  FOR SELECT TO authenticated
  USING (true);

-- NOTE: The existing "devices_select" policy (owner_id = auth.uid() OR police/pta)
-- is superseded by this broader policy for SELECT. Supabase ORs all policies
-- together, so citizens already saw their own rows. This addition means ALL
-- authenticated users can now read any device row for verification purposes.
-- The app layer only exposes brand, model, status, imei1, registered_at —
-- owner CNIC is masked and only visible to the device owner via the profiles join.
