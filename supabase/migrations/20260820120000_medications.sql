-- Medicinas / modo enfermedad (ver app-completa-handoff 2, CAMBIOS-2026-08.md).
-- Noctua repite la indicación del médico, no calcula dosis. Tres tablas:
-- episodes (marca días como atípicos para la analítica de sueño),
-- prescriptions + su dosis por bebé (editable solo por acceso total),
-- y el log de dosis dadas (cualquier cuidador puede registrar, como sueño/toma).

create function private.has_full_access(target_family_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select exists (
    select 1 from public.family_members
    where family_id = target_family_id
      and user_id = (select auth.uid())
      and permission_level = 'full'
  );
$$;

revoke execute on function private.has_full_access(uuid) from public, anon, authenticated;
grant execute on function private.has_full_access(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- episodes: mientras hay una fila con ended_at null, esos días quedan fuera
-- de promedios/correlaciones/cumplimiento (ver 03_AnalyticsScreen).
-- ---------------------------------------------------------------------------
create table public.med_episodes (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  label text not null default 'Fiebre / resfriado',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

create index med_episodes_family_id_idx on public.med_episodes (family_id);
create unique index med_episodes_one_active_per_family on public.med_episodes (family_id) where ended_at is null;

alter table public.med_episodes enable row level security;
alter table public.med_episodes force row level security;

create policy med_episodes_select on public.med_episodes
  for select to authenticated
  using (private.is_family_member(family_id));

create policy med_episodes_insert on public.med_episodes
  for insert to authenticated
  with check (private.is_family_member(family_id));

create policy med_episodes_update on public.med_episodes
  for update to authenticated
  using (private.is_family_member(family_id))
  with check (private.is_family_member(family_id));

-- ---------------------------------------------------------------------------
-- prescriptions: la indicación del médico. Solo un miembro con acceso total
-- la escribe; la asesora y el resto del equipo la ven.
-- ---------------------------------------------------------------------------
create table public.med_prescriptions (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  name text not null,
  conc text not null default '',
  every_hours int not null check (every_hours > 0),
  max_day int not null check (max_day > 0),
  doctor text not null default '',
  prescribed_on date not null default current_date,
  note text not null default '',
  alt_note text not null default '',
  active boolean not null default true,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

create index med_prescriptions_family_id_idx on public.med_prescriptions (family_id);

alter table public.med_prescriptions enable row level security;
alter table public.med_prescriptions force row level security;

create policy med_prescriptions_select on public.med_prescriptions
  for select to authenticated
  using (private.is_family_member(family_id));

create policy med_prescriptions_insert on public.med_prescriptions
  for insert to authenticated
  with check (private.has_full_access(family_id));

create policy med_prescriptions_update on public.med_prescriptions
  for update to authenticated
  using (private.has_full_access(family_id))
  with check (private.has_full_access(family_id));

-- ---------------------------------------------------------------------------
-- prescription_doses: la dosis de esta medicina para cada bebé (Mía y Lía
-- tienen dosis distintas, nunca una sola cifra para las dos).
-- ---------------------------------------------------------------------------
create table public.med_prescription_doses (
  prescription_id uuid not null references public.med_prescriptions (id) on delete cascade,
  baby_id uuid not null references public.babies (id) on delete cascade,
  ml numeric not null check (ml > 0),
  primary key (prescription_id, baby_id)
);

alter table public.med_prescription_doses enable row level security;
alter table public.med_prescription_doses force row level security;

create policy med_prescription_doses_select on public.med_prescription_doses
  for select to authenticated
  using (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_doses.prescription_id and private.is_family_member(p.family_id)
  ));

create policy med_prescription_doses_insert on public.med_prescription_doses
  for insert to authenticated
  with check (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_doses.prescription_id and private.has_full_access(p.family_id)
  ));

create policy med_prescription_doses_update on public.med_prescription_doses
  for update to authenticated
  using (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_doses.prescription_id and private.has_full_access(p.family_id)
  ))
  with check (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_doses.prescription_id and private.has_full_access(p.family_id)
  ));

create policy med_prescription_doses_delete on public.med_prescription_doses
  for delete to authenticated
  using (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_doses.prescription_id and private.has_full_access(p.family_id)
  ));

-- ---------------------------------------------------------------------------
-- doses: el log de "le di la medicina". Cualquier cuidador puede registrar,
-- igual que un evento de sueño o toma — dar la dosis no es privilegio de admin.
-- ---------------------------------------------------------------------------
create table public.med_doses (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  prescription_id uuid not null references public.med_prescriptions (id) on delete cascade,
  baby_id uuid not null references public.babies (id) on delete cascade,
  given_at timestamptz not null default now(),
  given_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

create index med_doses_family_id_idx on public.med_doses (family_id);
create index med_doses_prescription_id_idx on public.med_doses (prescription_id);

alter table public.med_doses enable row level security;
alter table public.med_doses force row level security;

create policy med_doses_select on public.med_doses
  for select to authenticated
  using (private.is_family_member(family_id));

create policy med_doses_insert on public.med_doses
  for insert to authenticated
  with check (private.is_family_member(family_id));
