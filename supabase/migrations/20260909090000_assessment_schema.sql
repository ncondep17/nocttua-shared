-- Assessment del onboarding (A1–A6). Ver plan en
-- /Users/nataliaconde/.claude/plans/resilient-booping-dawn.md para el contexto completo.

-- Prematuridad — nullable a propósito: a término o "no sé" se guarda null y
-- correctedAgeMonths() usa la edad cronológica sin corregir en ese caso.
alter table public.babies add column gestation_weeks int check (gestation_weeks between 22 and 42);

-- Plan estructurado que el assessment escribe y Hoy lee programáticamente
-- (wakeTime/bedtime/wakeWindowMin como valores tipados, no texto libre).
-- Distinto de plan_versions/plan_fields, que es el plan de la asesora
-- (label/value de texto libre, pensado para mostrarse, no para calcular).
create table public.sleep_plans (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  version int not null default 1,
  source text not null check (source in ('assessment', 'coach', 'user')),
  wake_time time not null,
  bedtime time not null,
  wake_window_min int not null,
  naps int not null,
  nap_schedule jsonb not null default '[]',
  tolerance_min int not null default 15,
  twin_sync_default boolean not null default true,
  updated_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create index sleep_plans_family_id_idx on public.sleep_plans (family_id, version desc);

alter table public.sleep_plans enable row level security;
alter table public.sleep_plans force row level security;

create policy sleep_plans_select on public.sleep_plans
  for select to authenticated
  using (private.is_family_member(family_id));

create policy sleep_plans_insert on public.sleep_plans
  for insert to authenticated
  with check (private.has_full_access(family_id));

-- Respuestas crudas del assessment — se conservan completas (no solo el
-- plan derivado) para poder recalcular si cambia una fórmula más adelante.
create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  version int not null default 1,
  answers jsonb not null,
  answered_at timestamptz not null default now()
);

create index assessments_family_id_idx on public.assessments (family_id, answered_at desc);

alter table public.assessments enable row level security;
alter table public.assessments force row level security;

create policy assessments_select on public.assessments
  for select to authenticated
  using (private.is_family_member(family_id));

create policy assessments_insert on public.assessments
  for insert to authenticated
  with check (private.has_full_access(family_id));

-- Línea base de diagnóstico declarada el día 1, una fila por bebé. NO es
-- plan (intención) y NO es registro (SleepLog/events, hecho medido) — sirve
-- solo como punto de comparación hasta que haya 14 noches reales.
create table public.baselines (
  id uuid primary key default gen_random_uuid(),
  baby_id uuid not null references public.babies(id) on delete cascade,
  wakings_per_night numeric not null,
  fall_asleep_method text not null check (fall_asleep_method in ('alone', 'patted', 'held', 'fed')),
  latency_min int not null,
  night_feeds jsonb not null default '[]',
  declared_at timestamptz not null default now()
);

create index baselines_baby_id_idx on public.baselines (baby_id);

alter table public.baselines enable row level security;
alter table public.baselines force row level security;

create policy baselines_select on public.baselines
  for select to authenticated
  using (exists (
    select 1 from public.babies b
    where b.id = baselines.baby_id and private.is_family_member(b.family_id)
  ));

create policy baselines_insert on public.baselines
  for insert to authenticated
  with check (exists (
    select 1 from public.babies b
    where b.id = baselines.baby_id and private.has_full_access(b.family_id)
  ));
