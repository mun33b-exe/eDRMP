-- =============================================================================
-- Notification Triggers → Supabase Edge Functions via pg_net
-- =============================================================================
-- These triggers fire on status changes and call the appropriate Edge Function.
-- The Edge Functions handle FCM push + notifications table insert.
--
-- IMPORTANT: After running this migration, you must configure two Supabase
-- vault secrets via the Supabase Dashboard → Settings → Vault:
--   1. project_url  = https://elscrcjnpjvgpvjiihcs.supabase.co
--   2. service_role_key = <your service role key>
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ---------------------------------------------------------------------------
-- Helper: call an Edge Function with a JSON payload
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.invoke_edge_function(fn_name text, payload jsonb)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  base_url text := 'https://elscrcjnpjvgpvjiihcs.supabase.co';
  svc_key  text;
BEGIN
  -- Read service_role_key from Supabase vault (set via Dashboard)
  SELECT decrypted_secret INTO svc_key
    FROM vault.decrypted_secrets
   WHERE name = 'service_role_key'
   LIMIT 1;

  IF svc_key IS NULL THEN
    RAISE WARNING 'service_role_key not found in vault – skipping edge function call';
    RETURN;
  END IF;

  PERFORM net.http_post(
    url     := base_url || '/functions/v1/' || fn_name,
    body    := payload,
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || svc_key
    )
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- 1. devices → notify-device-approved / rejected / blocked
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_notify_device_status()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  fn_name text;
BEGIN
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  CASE NEW.status
    WHEN 'approved' THEN fn_name := 'notify-device-approved';
    WHEN 'rejected' THEN fn_name := 'notify-device-rejected';
    WHEN 'blocked'  THEN fn_name := 'notify-device-blocked';
    ELSE RETURN NEW;
  END CASE;

  PERFORM invoke_edge_function(fn_name, jsonb_build_object(
    'record', jsonb_build_object(
      'id',       NEW.id,
      'owner_id', NEW.owner_id,
      'status',   NEW.status,
      'brand',    NEW.brand,
      'model',    NEW.model,
      'imei1',    NEW.imei1
    )
  ));

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_device_status ON public.devices;
CREATE TRIGGER trg_notify_device_status
  AFTER UPDATE OF status ON public.devices
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_device_status();

-- ---------------------------------------------------------------------------
-- 2. firs → notify-fir-received-police / verified / rejected
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_notify_fir_status()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  fn_name text;
BEGIN
  -- For UPDATE triggers, skip if status didn't change
  IF TG_OP = 'UPDATE' AND OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  CASE NEW.status
    WHEN 'submitted' THEN fn_name := 'notify-fir-received-police';
    WHEN 'verified'  THEN fn_name := 'notify-fir-verified';
    WHEN 'rejected'  THEN fn_name := 'notify-fir-rejected';
    ELSE RETURN NEW;
  END CASE;

  PERFORM invoke_edge_function(fn_name, jsonb_build_object(
    'record', jsonb_build_object(
      'id',             NEW.id,
      'owner_id',       NEW.owner_id,
      'device_id',      NEW.device_id,
      'status',         NEW.status,
      'police_station', NEW.police_station
    )
  ));

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_fir_status ON public.firs;
CREATE TRIGGER trg_notify_fir_status
  AFTER UPDATE OF status ON public.firs
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_fir_status();

-- Fire on INSERT too (new FIR = 'submitted')
DROP TRIGGER IF EXISTS trg_notify_fir_insert ON public.firs;
CREATE TRIGGER trg_notify_fir_insert
  AFTER INSERT ON public.firs
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_fir_status();

-- ---------------------------------------------------------------------------
-- 3. unblock_requests → notify-unblock-received-police / pta / device-unblocked
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_notify_unblock_status()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  fn_name text;
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  CASE NEW.status
    WHEN 'pending'         THEN fn_name := 'notify-unblock-received-police';
    WHEN 'police_approved' THEN fn_name := 'notify-unblock-received-pta';
    WHEN 'pta_unblocked'   THEN fn_name := 'notify-device-unblocked';
    ELSE RETURN NEW;
  END CASE;

  PERFORM invoke_edge_function(fn_name, jsonb_build_object(
    'record', jsonb_build_object(
      'id',           NEW.id,
      'device_id',    NEW.device_id,
      'requested_by', NEW.requested_by,
      'status',       NEW.status
    )
  ));

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_unblock_status ON public.unblock_requests;
CREATE TRIGGER trg_notify_unblock_status
  AFTER UPDATE OF status ON public.unblock_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_unblock_status();

-- Fire on INSERT too (new unblock request = 'pending')
DROP TRIGGER IF EXISTS trg_notify_unblock_insert ON public.unblock_requests;
CREATE TRIGGER trg_notify_unblock_insert
  AFTER INSERT ON public.unblock_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_unblock_status();
