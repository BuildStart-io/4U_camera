-- ============================================================================
-- 03_cron.sql — scheduled jobs (safety net + follow-ups).
-- Requires pg_cron + pg_net. Run as superuser on your self-hosted Postgres.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'drain-message-queue') THEN
    PERFORM cron.unschedule('drain-message-queue');
  END IF;
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'send-followups') THEN
    PERFORM cron.unschedule('send-followups');
  END IF;
END $$;

-- Queue drainer safety net. webhook-wsender already fires process-message
-- immediately on each inbound message; this catches anything left behind.
SELECT cron.schedule(
  'drain-message-queue',
  '* * * * *',
  $$
  SELECT net.http_post(
    url     := 'http://api-gw:8000/functions/v1/process-message_ucam',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UiLCJpYXQiOjE3OTIxMzMyMjMsImV4cCI6MjEwNzQ5MzIyM30.noah6drtB2LgrNjSxOi8y5kasIv0_odISK925IRpTg8"}'::jsonb,
    body    := '{"trigger":"cron"}'::jsonb
  );
  $$
);

-- Order follow-ups + inactivity follow-ups.
SELECT cron.schedule(
  'send-followups',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url     := 'http://api-gw:8000/functions/v1/send-followups_ucam',
    headers := '{"Content-Type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UiLCJpYXQiOjE3OTIxMzMyMjMsImV4cCI6MjEwNzQ5MzIyM30.noah6drtB2LgrNjSxOi8y5kasIv0_odISK925IRpTg8"}'::jsonb,
    body    := '{}'::jsonb
  );
  $$
);
