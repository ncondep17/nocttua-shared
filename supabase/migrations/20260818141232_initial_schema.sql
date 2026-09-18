-- Nocttua initial schema: families, membership/permissions, babies, events, sleep plan.
-- Scope: vertical slice (Welcome -> BabyCount -> AppleAuth -> Ready -> TodayScreen).
-- Guide content, billing, and practice analytics are added when those screens are ported.

create schema if not exists private;

-- ---------------------------------------------------------------------------
-- profiles: one row per auth user, independent of family membership so a
-- coach (who belongs to many families) isn't forced into a single family_id.
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'caregiver' check (role in ('caregiver', 'coach')),
  display_name text not null default '',
  initial text not null default '',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.profiles force row level security;

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- families + membership. permission_level is the single enum shared by
-- Nocttua App's TeamScreen and Nocttua Coach's AccessManagementPanel.
-- ---------------------------------------------------------------------------
create table public.families (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now()
);

alter table public.families enable row level security;
alter table public.families force row level security;

create type public.permission_level as enum ('full', 'reports', 'plan', 'none');

create table public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  permission_level public.permission_level not null default 'full',
  created_at timestamptz not null default now(),
  unique (family_id, user_id)
);

create index family_members_family_id_idx on public.family_members (family_id);
create index family_members_user_id_idx on public.family_members (user_id);

alter table public.family_members enable row level security;
alter table public.family_members force row level security;

-- Security-definer helper: indexed membership check, callable from any policy
-- without re-invoking auth.uid() per row (see security-rls-performance).
create function private.is_family_member(target_family_id uuid)
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
  );
$$;

revoke execute on function private.is_family_member(uuid) from public, anon, authenticated;
grant execute on function private.is_family_member(uuid) to authenticated;

-- Bootstraps a new family for the calling user (used once, during onboarding's
-- "sola" path in 09_AccountTypeScreen). Joining an existing coach/family via
-- invite code is a separate flow added when JoinWithCodeScreen is ported.
create function public.create_family()
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_family_id uuid;
begin
  insert into public.families default values returning id into new_family_id;
  insert into public.family_members (family_id, user_id, permission_level)
  values (new_family_id, (select auth.uid()), 'full');
  return new_family_id;
end;
$$;

revoke execute on function public.create_family() from public, anon;
grant execute on function public.create_family() to authenticated;

-- ---------------------------------------------------------------------------
-- babies
-- ---------------------------------------------------------------------------
create table public.babies (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  name text not null,
  initial text not null,
  tone text not null check (tone in ('a', 'b')),
  birth_date date,
  created_at timestamptz not null default now(),
  unique (family_id, tone)
);

create index babies_family_id_idx on public.babies (family_id);

alter table public.babies enable row level security;
alter table public.babies force row level security;

-- ---------------------------------------------------------------------------
-- events: unified sleep/feed/pump log. Replaces the mock's separate
-- todayFeed/milkLog string-time arrays with real timestamps.
-- ---------------------------------------------------------------------------
create table public.events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  baby_id uuid references public.babies (id) on delete cascade,
  type text not null check (type in ('sleep', 'feed', 'pump')),
  started_at timestamptz not null,
  ended_at timestamptz,
  place text,
  kind text,
  side text,
  volume_ml numeric,
  note text,
  fell_asleep_feeding boolean not null default false,
  was_due boolean not null default false,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

create index events_family_id_started_at_idx on public.events (family_id, started_at desc);
create index events_baby_id_idx on public.events (baby_id);

alter table public.events enable row level security;
alter table public.events force row level security;

-- ---------------------------------------------------------------------------
-- sleep plan: Coach writes, App reads. plan_fields carries a stable `key`
-- (Coach's mock already had one; family app's didn't) so future edits can
-- target a field without relying on label text.
-- ---------------------------------------------------------------------------
create table public.plan_versions (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  coach_id uuid references public.profiles (id),
  version_label text not null,
  published_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index plan_versions_family_id_idx on public.plan_versions (family_id, published_at desc);

alter table public.plan_versions enable row level security;
alter table public.plan_versions force row level security;

create table public.plan_fields (
  id uuid primary key default gen_random_uuid(),
  plan_version_id uuid not null references public.plan_versions (id) on delete cascade,
  key text not null,
  label text not null,
  value text not null,
  position int not null default 0
);

create index plan_fields_plan_version_id_idx on public.plan_fields (plan_version_id);

alter table public.plan_fields enable row level security;
alter table public.plan_fields force row level security;

-- ---------------------------------------------------------------------------
-- RLS policies
-- ---------------------------------------------------------------------------

-- profiles: see your own row, or a co-caregiver/coach's row if you share a family.
create policy profiles_select on public.profiles
  for select to authenticated
  using (
    id = (select auth.uid())
    or exists (
      select 1 from public.family_members mine
      join public.family_members theirs on theirs.family_id = mine.family_id
      where mine.user_id = (select auth.uid())
        and theirs.user_id = profiles.id
    )
  );

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- families: visible to members only. Creation goes through create_family().
create policy families_select on public.families
  for select to authenticated
  using (private.is_family_member(id));

-- family_members: members can see their family's roster.
create policy family_members_select on public.family_members
  for select to authenticated
  using (private.is_family_member(family_id));

-- babies / events: any family member (permission tiers beyond read access
-- are enforced at the write-policy level as those flows get built).
create policy babies_select on public.babies
  for select to authenticated
  using (private.is_family_member(family_id));

create policy babies_insert on public.babies
  for insert to authenticated
  with check (private.is_family_member(family_id));

create policy babies_update on public.babies
  for update to authenticated
  using (private.is_family_member(family_id))
  with check (private.is_family_member(family_id));

create policy events_select on public.events
  for select to authenticated
  using (private.is_family_member(family_id));

create policy events_insert on public.events
  for insert to authenticated
  with check (private.is_family_member(family_id));

create policy events_update on public.events
  for update to authenticated
  using (private.is_family_member(family_id))
  with check (private.is_family_member(family_id));

create policy events_delete on public.events
  for delete to authenticated
  using (private.is_family_member(family_id));

-- plan_versions / plan_fields: every family member can read; only the
-- linked coach can publish. Caregiver-side editing is never allowed.
create policy plan_versions_select on public.plan_versions
  for select to authenticated
  using (private.is_family_member(family_id));

create policy plan_versions_insert on public.plan_versions
  for insert to authenticated
  with check (
    private.is_family_member(family_id)
    and exists (select 1 from public.profiles where id = (select auth.uid()) and role = 'coach')
  );

create policy plan_fields_select on public.plan_fields
  for select to authenticated
  using (
    exists (
      select 1 from public.plan_versions pv
      where pv.id = plan_fields.plan_version_id
        and private.is_family_member(pv.family_id)
    )
  );

create policy plan_fields_insert on public.plan_fields
  for insert to authenticated
  with check (
    exists (
      select 1 from public.plan_versions pv
      join public.profiles p on p.id = (select auth.uid()) and p.role = 'coach'
      where pv.id = plan_fields.plan_version_id
        and private.is_family_member(pv.family_id)
    )
  );
