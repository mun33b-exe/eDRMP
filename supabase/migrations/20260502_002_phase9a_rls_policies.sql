-- Phase 9A — Row Level Security Policies
-- Idempotent: each policy is dropped (IF EXISTS) then recreated.
-- Run AFTER 20260502_001_phase9a_initial_schema.sql.
-- The helper function public.get_user_role() is defined in migration 001.

-- ─────────────────────────────────────────────────────────────
-- Enable RLS on every table
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.firs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.block_requests  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unblock_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_status_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.theft_zones     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_qr_codes ENABLE ROW LEVEL SECURITY;

-- ═════════════════════════════════════════════════════════════
-- profiles
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "profiles_select"  ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert"  ON public.profiles;
DROP POLICY IF EXISTS "profiles_update"  ON public.profiles;

-- Users see their own row; police and PTA see all.
CREATE POLICY "profiles_select" ON public.profiles
  FOR SELECT TO authenticated
  USING (
    id = auth.uid()
    OR public.get_user_role() IN ('police', 'pta')
  );

-- Only the owner may insert their own profile row (called during register()).
CREATE POLICY "profiles_insert" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

-- Only the owner may update their own row (e.g. FCM token refresh).
CREATE POLICY "profiles_update" ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- ═════════════════════════════════════════════════════════════
-- devices
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "devices_select" ON public.devices;
DROP POLICY IF EXISTS "devices_insert" ON public.devices;
DROP POLICY IF EXISTS "devices_update" ON public.devices;

-- Citizens see their own; police and PTA see all.
CREATE POLICY "devices_select" ON public.devices
  FOR SELECT TO authenticated
  USING (
    owner_id = auth.uid()
    OR public.get_user_role() IN ('police', 'pta')
  );

-- Citizens register their own devices.
CREATE POLICY "devices_insert" ON public.devices
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

-- Only PTA may update device status (approve / reject / block / unblock).
CREATE POLICY "devices_update" ON public.devices
  FOR UPDATE TO authenticated
  USING (public.get_user_role() = 'pta');

-- ═════════════════════════════════════════════════════════════
-- firs
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "firs_select" ON public.firs;
DROP POLICY IF EXISTS "firs_insert" ON public.firs;
DROP POLICY IF EXISTS "firs_update" ON public.firs;

-- Citizens see their own; police and PTA see all.
CREATE POLICY "firs_select" ON public.firs
  FOR SELECT TO authenticated
  USING (
    owner_id = auth.uid()
    OR public.get_user_role() IN ('police', 'pta')
  );

-- Citizens file their own FIRs.
CREATE POLICY "firs_insert" ON public.firs
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

-- Police and PTA update FIR status.
CREATE POLICY "firs_update" ON public.firs
  FOR UPDATE TO authenticated
  USING (public.get_user_role() IN ('police', 'pta'));

-- ═════════════════════════════════════════════════════════════
-- block_requests
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "block_requests_select" ON public.block_requests;
DROP POLICY IF EXISTS "block_requests_insert" ON public.block_requests;
DROP POLICY IF EXISTS "block_requests_update" ON public.block_requests;

-- Requesters see their own; PTA sees all.
CREATE POLICY "block_requests_select" ON public.block_requests
  FOR SELECT TO authenticated
  USING (
    requested_by = auth.uid()
    OR public.get_user_role() = 'pta'
  );

-- Citizens create block requests after FIR is verified.
CREATE POLICY "block_requests_insert" ON public.block_requests
  FOR INSERT TO authenticated
  WITH CHECK (requested_by = auth.uid());

-- PTA approves or rejects block requests.
CREATE POLICY "block_requests_update" ON public.block_requests
  FOR UPDATE TO authenticated
  USING (public.get_user_role() = 'pta');

-- ═════════════════════════════════════════════════════════════
-- unblock_requests
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "unblock_requests_select" ON public.unblock_requests;
DROP POLICY IF EXISTS "unblock_requests_insert" ON public.unblock_requests;
DROP POLICY IF EXISTS "unblock_requests_update" ON public.unblock_requests;

-- Requesters see their own; police and PTA see all.
CREATE POLICY "unblock_requests_select" ON public.unblock_requests
  FOR SELECT TO authenticated
  USING (
    requested_by = auth.uid()
    OR public.get_user_role() IN ('police', 'pta')
  );

-- Citizens create unblock requests after marking device recovered.
CREATE POLICY "unblock_requests_insert" ON public.unblock_requests
  FOR INSERT TO authenticated
  WITH CHECK (requested_by = auth.uid());

-- Police and PTA progress unblock requests.
CREATE POLICY "unblock_requests_update" ON public.unblock_requests
  FOR UPDATE TO authenticated
  USING (public.get_user_role() IN ('police', 'pta'));

-- ═════════════════════════════════════════════════════════════
-- case_status_log  (append-only audit; INSERT by service role via triggers)
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "case_status_log_select" ON public.case_status_log;

-- Citizens see log entries tied to their own devices or FIRs.
-- Police and PTA see everything.
CREATE POLICY "case_status_log_select" ON public.case_status_log
  FOR SELECT TO authenticated
  USING (
    public.get_user_role() IN ('police', 'pta')
    OR changed_by = auth.uid()
    OR entity_id IN (
      SELECT id FROM public.devices WHERE owner_id = auth.uid()
      UNION ALL
      SELECT id FROM public.firs   WHERE owner_id = auth.uid()
    )
  );

-- ═════════════════════════════════════════════════════════════
-- notifications  (INSERT by service role / Edge Functions only)
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "notifications_select" ON public.notifications;
DROP POLICY IF EXISTS "notifications_update" ON public.notifications;

-- Each user reads only their own notifications.
CREATE POLICY "notifications_select" ON public.notifications
  FOR SELECT TO authenticated
  USING (recipient_id = auth.uid());

-- Users mark their own notifications as read.
CREATE POLICY "notifications_update" ON public.notifications
  FOR UPDATE TO authenticated
  USING (recipient_id = auth.uid())
  WITH CHECK (recipient_id = auth.uid());

-- ═════════════════════════════════════════════════════════════
-- theft_zones  (INSERT by service role / Edge Functions only)
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "theft_zones_select" ON public.theft_zones;

-- All authenticated users may read the theft zone map.
CREATE POLICY "theft_zones_select" ON public.theft_zones
  FOR SELECT TO authenticated
  USING (true);

-- ═════════════════════════════════════════════════════════════
-- device_qr_codes  (INSERT by service role only)
-- ═════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "device_qr_codes_select" ON public.device_qr_codes;

-- All authenticated users may read QR codes (needed for the Verify IMEI screen).
CREATE POLICY "device_qr_codes_select" ON public.device_qr_codes
  FOR SELECT TO authenticated
  USING (true);
