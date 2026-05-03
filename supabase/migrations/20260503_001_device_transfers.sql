-- Device ownership transfer requests
CREATE TABLE IF NOT EXISTS public.device_transfers (
  id               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id        uuid         REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
  from_owner_id    uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  to_cnic          text         NOT NULL,
  to_owner_id      uuid         REFERENCES public.profiles(id),
  status           text         NOT NULL DEFAULT 'pending'
                                CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),
  note             text,
  created_at       timestamptz  DEFAULT now(),
  resolved_at      timestamptz
);

-- RLS policies for device_transfers
ALTER TABLE public.device_transfers ENABLE ROW LEVEL SECURITY;

-- Sender can see their outgoing transfers
CREATE POLICY "Users can view own outgoing transfers"
  ON public.device_transfers FOR SELECT
  USING (from_owner_id = auth.uid());

-- Recipient can see incoming transfers
CREATE POLICY "Users can view incoming transfers by cnic"
  ON public.device_transfers FOR SELECT
  USING (
    to_owner_id = auth.uid()
    OR to_cnic = (SELECT cnic FROM public.profiles WHERE id = auth.uid())
  );

-- Owner can create transfer requests for their own devices
CREATE POLICY "Owners can create transfer requests"
  ON public.device_transfers FOR INSERT
  WITH CHECK (from_owner_id = auth.uid());

-- Sender can cancel, recipient can accept/reject
CREATE POLICY "Participants can update transfers"
  ON public.device_transfers FOR UPDATE
  USING (
    from_owner_id = auth.uid()
    OR to_owner_id = auth.uid()
    OR to_cnic = (SELECT cnic FROM public.profiles WHERE id = auth.uid())
  );

-- ═════════════════════════════════════════════════════════════
-- Helper: look up a profile ID by CNIC (SECURITY DEFINER bypasses RLS)
-- ═════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.lookup_profile_by_cnic(target_cnic text)
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.profiles WHERE cnic = target_cnic LIMIT 1;
$$;

-- ═════════════════════════════════════════════════════════════
-- Helper: accept a transfer (SECURITY DEFINER — updates device owner)
-- Verifies the caller is the recipient before proceeding.
-- ═════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.accept_device_transfer(transfer_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_device_id   uuid;
  v_to_cnic     text;
  v_caller_cnic text;
  v_status      text;
BEGIN
  -- Fetch the transfer
  SELECT device_id, to_cnic, status
    INTO v_device_id, v_to_cnic, v_status
    FROM public.device_transfers
   WHERE id = transfer_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transfer not found';
  END IF;

  IF v_status <> 'pending' THEN
    RAISE EXCEPTION 'Transfer is no longer pending';
  END IF;

  -- Verify caller is the recipient
  SELECT cnic INTO v_caller_cnic
    FROM public.profiles
   WHERE id = auth.uid();

  IF v_caller_cnic IS NULL OR v_caller_cnic <> v_to_cnic THEN
    RAISE EXCEPTION 'Only the designated recipient can accept this transfer';
  END IF;

  -- Update transfer
  UPDATE public.device_transfers
     SET status = 'accepted',
         to_owner_id = auth.uid(),
         resolved_at = now()
   WHERE id = transfer_id;

  -- Transfer device ownership
  UPDATE public.devices
     SET owner_id = auth.uid(),
         updated_at = now()
   WHERE id = v_device_id;
END;
$$;
