-- Soporte para el motor de cálculo real (derive.js del paquete de diseño
-- "app-completa-handoff"): la hoja de sueño distingue "empezó a dormirla"
-- de "se durmió" (eso es la latencia), y captura contacto/humor/factores
-- del día, que alimentan las correlaciones y el cumplimiento del plan.

alter table public.events add column fell_asleep_at timestamptz;
alter table public.events add column contact text;
alter table public.events add column wake_mood text;
alter table public.events add column factors text[];
alter table public.events add column feed_minutes int;
alter table public.events add column pump_dest text;
alter table public.events add column feed_context text;

comment on column public.events.fell_asleep_at is 'Momento real en que se durmió, distinto de started_at ("empezó a dormirla"). latencia = fell_asleep_at - started_at.';
comment on column public.events.contact is 'Cómo se la acompañó a dormir: Sola/Palmaditas/Mano encima/Cargada/Con la toma.';
comment on column public.events.wake_mood is 'Humor al despertar: Buen humor/Tranquila/Mal humor/Llorando.';
comment on column public.events.factors is 'Factores del día marcados en el registro (Teething, Cena escasa, etc).';
comment on column public.events.feed_minutes is 'Duración en minutos de una toma al pecho asociada a este registro (sueño o toma).';
comment on column public.events.pump_dest is 'Destino de una extracción: Al banco/A la nevera/Uso inmediato.';
comment on column public.events.feed_context is 'Contexto de una toma: Al despertar/Despierta/Antes de dormir/Despertar nocturno.';

-- Umbrales del plan de sueño (napStart, napMax, night, wakes, latencia) que
-- alimentan compliance() en la app de la família. Estructurado a propósito
-- —a diferencia de plan_fields, que es texto libre— porque el motor de
-- cumplimiento necesita comparar contra minutos concretos, no prosa.
-- Editable por cualquier miembro con acceso total mientras no exista todavía
-- un panel de asesora que lo publique (Nocttua Coach, fase siguiente).
create table public.plan_thresholds (
  family_id uuid primary key references public.families (id) on delete cascade,
  nap_start_min int not null,
  nap_max_min int not null,
  night_min int not null,
  wakes_max int not null default 3,
  latency_max int not null default 25,
  updated_at timestamptz not null default now()
);

alter table public.plan_thresholds enable row level security;
alter table public.plan_thresholds force row level security;

create policy plan_thresholds_select on public.plan_thresholds
  for select to authenticated
  using (private.is_family_member(family_id));

create policy plan_thresholds_upsert on public.plan_thresholds
  for insert to authenticated
  with check (private.is_family_member(family_id));

create policy plan_thresholds_update on public.plan_thresholds
  for update to authenticated
  using (private.is_family_member(family_id))
  with check (private.is_family_member(family_id));
