-- Phase 9D — Enable Realtime on notifications, theft_zones, and firs tables.
-- This SQL enables the tables in the supabase_realtime publication.
-- NOTE: If a table is already in the publication (added via the dashboard in a
-- prior phase), Postgres will raise an error for that table only. That is safe
-- to ignore — the remaining tables will still be added.

ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.theft_zones;
ALTER PUBLICATION supabase_realtime ADD TABLE public.firs;
