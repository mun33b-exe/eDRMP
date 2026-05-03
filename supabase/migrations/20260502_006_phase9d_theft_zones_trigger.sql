-- Phase 9D — Populate theft_zones from FIR incident coordinates
-- Fires AFTER INSERT on firs when incident_lat/lng are provided.
-- Also fires AFTER UPDATE on firs when status changes, updating the
-- risk_level and recovering/unblocking zones.

CREATE OR REPLACE FUNCTION public.sync_theft_zone()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only process FIRs that have location data
  IF NEW.incident_lat IS NULL OR NEW.incident_lng IS NULL THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.theft_zones (fir_id, lat, lng, address, risk_level, fir_count)
    VALUES (
      NEW.id,
      NEW.incident_lat,
      NEW.incident_lng,
      NEW.incident_address,
      'medium',
      1
    )
    ON CONFLICT (fir_id) DO NOTHING;
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF NEW.status IN ('verified', 'blocked') THEN
      INSERT INTO public.theft_zones (fir_id, lat, lng, address, risk_level, fir_count)
      VALUES (
        NEW.id,
        NEW.incident_lat,
        NEW.incident_lng,
        NEW.incident_address,
        CASE NEW.status WHEN 'blocked' THEN 'high' ELSE 'medium' END,
        1
      )
      ON CONFLICT (fir_id) DO UPDATE
        SET risk_level = EXCLUDED.risk_level,
            lat        = EXCLUDED.lat,
            lng        = EXCLUDED.lng,
            address    = EXCLUDED.address;
    END IF;

    IF NEW.status IN ('unblocked', 'recovered') THEN
      UPDATE public.theft_zones
      SET risk_level = 'low'
      WHERE fir_id = NEW.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Add unique constraint on fir_id so ON CONFLICT works (idempotent)
ALTER TABLE public.theft_zones
  DROP CONSTRAINT IF EXISTS theft_zones_fir_id_unique;
ALTER TABLE public.theft_zones
  ADD CONSTRAINT theft_zones_fir_id_unique UNIQUE (fir_id);

DROP TRIGGER IF EXISTS trg_sync_theft_zone_insert ON public.firs;
DROP TRIGGER IF EXISTS trg_sync_theft_zone_update ON public.firs;

CREATE TRIGGER trg_sync_theft_zone_insert
  AFTER INSERT ON public.firs
  FOR EACH ROW EXECUTE FUNCTION public.sync_theft_zone();

CREATE TRIGGER trg_sync_theft_zone_update
  AFTER UPDATE OF status, incident_lat, incident_lng ON public.firs
  FOR EACH ROW EXECUTE FUNCTION public.sync_theft_zone();
