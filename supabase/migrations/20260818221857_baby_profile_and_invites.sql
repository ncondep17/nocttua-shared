-- Onboarding survey needs a real baseline per baby (name/birth_date already
-- existed; current_naps is the new self-reported starting point).
alter table public.babies add column current_naps int;

-- Team invites: one mechanism used both by TeamScreen ("Invitar a alguien")
-- and by JoinWithCodeScreen / 09_AccountTypeScreen's code path (a person
-- redeeming a code joins the inviting family with the granted permission
-- level). Mutations go through the two functions below, not direct table
-- writes, so there is no insert/update policy on the table itself.
create table public.family_invites (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  code text not null unique,
  permission_level public.permission_level not null default 'full',
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  redeemed_by uuid references public.profiles (id),
  redeemed_at timestamptz
);

create index family_invites_family_id_idx on public.family_invites (family_id);

alter table public.family_invites enable row level security;
alter table public.family_invites force row level security;

create policy family_invites_select on public.family_invites
  for select to authenticated
  using (private.is_family_member(family_id));

create function public.create_invite(target_permission_level public.permission_level default 'full')
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_family_id uuid;
  new_code text;
begin
  select family_id into target_family_id
  from public.family_members
  where user_id = (select auth.uid()) and permission_level = 'full'
  limit 1;

  if target_family_id is null then
    raise exception 'Solo un miembro con acceso total puede invitar';
  end if;

  new_code := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));

  insert into public.family_invites (family_id, code, permission_level, created_by)
  values (target_family_id, new_code, target_permission_level, (select auth.uid()));

  return new_code;
end;
$$;

revoke execute on function public.create_invite(public.permission_level) from public, anon;
grant execute on function public.create_invite(public.permission_level) to authenticated;

create function public.redeem_invite(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_invite record;
begin
  select * into target_invite
  from public.family_invites
  where code = upper(invite_code) and redeemed_at is null and (expires_at is null or expires_at > now())
  limit 1;

  if target_invite is null then
    raise exception 'Código inválido o vencido';
  end if;

  insert into public.family_members (family_id, user_id, permission_level)
  values (target_invite.family_id, (select auth.uid()), target_invite.permission_level)
  on conflict (family_id, user_id) do nothing;

  update public.family_invites set redeemed_at = now(), redeemed_by = (select auth.uid())
  where id = target_invite.id;

  return target_invite.family_id;
end;
$$;

revoke execute on function public.redeem_invite(text) from public, anon;
grant execute on function public.redeem_invite(text) to authenticated;
