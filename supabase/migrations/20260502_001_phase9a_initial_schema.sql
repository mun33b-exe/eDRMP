-- STEP 1: Create profiles table FIRST
CREATE TABLE IF NOT EXISTS public.profiles (
  id           uuid         REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name    text         NOT NULL,
  cnic         text         UNIQUE NOT NULL,
  email        text         UNIQUE NOT NULL,
  phone        text,
  role         text         NOT NULL DEFAULT 'user'
                            CHECK (role IN ('user', 'police', 'pta')),
  fcm_token    text,
  created_at   timestamptz  DEFAULT now()
);

-- STEP 2: NOW create the function (profiles exists)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- STEP 3: Rest of tables
CREATE TABLE IF NOT EXISTS public.devices (
  id                    uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id              uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  imei1                 text         UNIQUE NOT NULL,
  imei2                 text,
  brand                 text,
  model                 text,
  operator              text,
  status                text         NOT NULL DEFAULT 'pending'
                                     CHECK (status IN (
                                       'pending', 'approved', 'rejected',
                                       'blocked', 'unblocked'
                                     )),
  purchase_invoice_url  text,
  registered_at         timestamptz  DEFAULT now(),
  updated_at            timestamptz  DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.firs (
  id               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id         uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  device_id        uuid         REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
  fir_number       text         NOT NULL,
  police_station   text         NOT NULL,
  incident_date    date         NOT NULL,
  description      text,
  proof_url        text,
  incident_lat     double precision,
  incident_lng     double precision,
  incident_address text,
  status           text         NOT NULL DEFAULT 'pending_review'
                                CHECK (status IN (
                                  'pending_review', 'under_review', 'verified',
                                  'rejected', 'block_pending', 'block_approved',
                                  'block_rejected', 'blocked', 'recovered',
                                  'unblock_pending', 'unblock_approved', 'unblocked'
                                )),
  rejection_reason text,
  created_at       timestamptz  DEFAULT now(),
  updated_at       timestamptz  DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.block_requests (
  id               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  fir_id           uuid         REFERENCES public.firs(id) ON DELETE CASCADE NOT NULL,
  device_id        uuid         REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
  requested_by     uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  status           text         NOT NULL DEFAULT 'pending'
                                CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason text,
  created_at       timestamptz  DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.unblock_requests (
  id                  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  fir_id              uuid         REFERENCES public.firs(id) ON DELETE CASCADE NOT NULL,
  device_id           uuid         REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
  requested_by        uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  police_approved_at  timestamptz,
  police_approved_by  uuid         REFERENCES public.profiles(id),
  status              text         NOT NULL DEFAULT 'pending_police'
                                   CHECK (status IN (
                                     'pending_police', 'police_approved',
                                     'pta_unblocked', 'rejected'
                                   )),
  rejection_reason    text,
  created_at          timestamptz  DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.case_status_log (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type  text         NOT NULL
                            CHECK (entity_type IN ('device', 'fir', 'block', 'unblock')),
  entity_id    uuid         NOT NULL,
  old_status   text,
  new_status   text         NOT NULL,
  changed_by   uuid         REFERENCES public.profiles(id),
  note         text,
  created_at   timestamptz  DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_id uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title        text         NOT NULL,
  body         text         NOT NULL,
  type         text         NOT NULL,
  entity_id    uuid,
  is_read      boolean      NOT NULL DEFAULT false,
  created_at   timestamptz  DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.theft_zones (
  id          uuid             PRIMARY KEY DEFAULT gen_random_uuid(),
  fir_id      uuid             REFERENCES public.firs(id),
  lat         double precision NOT NULL,
  lng         double precision NOT NULL,
  address     text,
  risk_level  text             NOT NULL DEFAULT 'medium'
                               CHECK (risk_level IN ('low', 'medium', 'high')),
  fir_count   integer          NOT NULL DEFAULT 1,
  created_at  timestamptz      DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.device_qr_codes (
  id               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id        uuid         REFERENCES public.devices(id) ON DELETE CASCADE UNIQUE NOT NULL,
  qr_storage_path  text         NOT NULL,
  created_at       timestamptz  DEFAULT now()
);