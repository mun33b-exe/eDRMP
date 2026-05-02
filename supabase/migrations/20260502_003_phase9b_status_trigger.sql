-- Phase 9B: Status change trigger → auto-insert into case_status_log

CREATE OR REPLACE FUNCTION public.log_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_entity_type text;
BEGIN
  v_entity_type := CASE TG_TABLE_NAME
    WHEN 'devices'          THEN 'device'
    WHEN 'firs'             THEN 'fir'
    WHEN 'block_requests'   THEN 'block'
    WHEN 'unblock_requests' THEN 'unblock'
    ELSE TG_TABLE_NAME
  END;

  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO public.case_status_log(entity_type, entity_id, old_status, new_status, changed_by)
    VALUES (v_entity_type, NEW.id, OLD.status, NEW.status, auth.uid());
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_log_device_status    ON public.devices;
DROP TRIGGER IF EXISTS trg_log_fir_status       ON public.firs;
DROP TRIGGER IF EXISTS trg_log_block_status     ON public.block_requests;
DROP TRIGGER IF EXISTS trg_log_unblock_status   ON public.unblock_requests;

CREATE TRIGGER trg_log_device_status
  AFTER UPDATE OF status ON public.devices
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();

CREATE TRIGGER trg_log_fir_status
  AFTER UPDATE OF status ON public.firs
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();

CREATE TRIGGER trg_log_block_status
  AFTER UPDATE OF status ON public.block_requests
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();

CREATE TRIGGER trg_log_unblock_status
  AFTER UPDATE OF status ON public.unblock_requests
  FOR EACH ROW EXECUTE FUNCTION public.log_status_change();
