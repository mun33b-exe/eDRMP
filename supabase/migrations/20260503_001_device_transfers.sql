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
