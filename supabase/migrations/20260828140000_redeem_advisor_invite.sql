-- redeem_advisor_invite: re-vincula a una asesora que generó su código con
-- create_client_family (família vacía, sin bebés/plan) a la família REAL que
-- el cliente que canjea ya tiene, en vez de sumarle una segunda fila en
-- family_members apuntando a la família vacía. Ese era el bug: la família
-- "activa" para el usuario en getMyFamilyId() seguía siendo la real por
-- antigüedad, pero la asesora quedaba enganchada a la família vacía.
--
-- Solo acepta invites que pertenecen a una família creada por
-- create_client_family (exactamente una fila family_members con
-- relationship='Asesora' ahí). Un invite normal (de create_invite, para
-- sumar niñera/mamá/papá a una família existente) se rechaza — para eso
-- sigue estando redeem_invite, sin cambios.
create function public.redeem_advisor_invite(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_invite record;
  advisor_member record;
  my_family_id uuid;
  shell_member_count int;
  shell_baby_count int;
begin
  select * into target_invite
  from public.family_invites
  where code = upper(trim(invite_code))
    and redeemed_at is null
    and (expires_at is null or expires_at > now())
  limit 1
  for update;

  if target_invite is null then
    raise exception 'Código inválido o vencido';
  end if;

  select * into advisor_member
  from public.family_members
  where family_id = target_invite.family_id
    and relationship = 'Asesora'
  limit 1;

  if advisor_member is null then
    raise exception 'Este código no corresponde a una asesora';
  end if;

  select family_id into my_family_id
  from public.family_members
  where user_id = (select auth.uid())
  order by created_at asc
  limit 1;

  if my_family_id is null then
    raise exception 'Todavía no tienes una família propia para vincular';
  end if;

  if my_family_id = target_invite.family_id then
    raise exception 'Este código no corresponde a una asesora';
  end if;

  insert into public.family_members (family_id, user_id, permission_level, relationship)
  values (my_family_id, advisor_member.user_id, advisor_member.permission_level, 'Asesora')
  on conflict (family_id, user_id) do nothing;

  update public.family_invites
  set redeemed_at = now(), redeemed_by = (select auth.uid())
  where id = target_invite.id;

  select count(*) into shell_member_count from public.family_members where family_id = target_invite.family_id;
  select count(*) into shell_baby_count from public.babies where family_id = target_invite.family_id;

  if shell_member_count = 1 and shell_baby_count = 0 then
    delete from public.families where id = target_invite.family_id;
  end if;

  return my_family_id;
end;
$$;

revoke execute on function public.redeem_advisor_invite(text) from public, anon;
grant execute on function public.redeem_advisor_invite(text) to authenticated;
