-- CONTRATO-AVISO-VENTANA.md §5: "se mide o no existe" — alert_scheduled,
-- alert_delivered, alert_missed, permission_state. Insert-only from clients;
-- reading/aggregating is an operational concern, not a user-facing feature,
-- so there's no select policy for `authenticated` beyond your own rows.
create table public.telemetry_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id),
  event text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index telemetry_events_event_created_at_idx on public.telemetry_events (event, created_at desc);

alter table public.telemetry_events enable row level security;
alter table public.telemetry_events force row level security;

create policy telemetry_events_insert_own on public.telemetry_events
  for insert to authenticated
  with check (user_id = (select auth.uid()));
