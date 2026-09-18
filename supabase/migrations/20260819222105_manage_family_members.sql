-- TeamScreen's roster is read-only today: family_members has a select
-- policy but no way to change a member's permission level or remove them.
-- Both mutations go through security-definer functions (same pattern as
-- create_invite/redeem_invite), not direct table policies, so a member
-- can't grant themselves more access than they started with.

create function public.update_member_permission(target_user_id uuid, new_level public.permission_level)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_family_id uuid;
begin
  if target_user_id = (select auth.uid()) then
    raise exception 'No podés cambiar tu propio nivel de acceso desde acá';
  end if;

  select family_id into caller_family_id
  from public.family_members
  where user_id = (select auth.uid()) and permission_level = 'full'
  limit 1;

  if caller_family_id is null then
    raise exception 'Solo un miembro con acceso total puede cambiar permisos';
  end if;

  update public.family_members
  set permission_level = new_level
  where family_id = caller_family_id and user_id = target_user_id;

  if not found then
    raise exception 'Esa persona no es parte de tu família';
  end if;
end;
$$;

revoke execute on function public.update_member_permission(uuid, public.permission_level) from public, anon;
grant execute on function public.update_member_permission(uuid, public.permission_level) to authenticated;

create function public.remove_family_member(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_family_id uuid;
begin
  if target_user_id = (select auth.uid()) then
    raise exception 'No podés quitarte a vos mismo del equipo desde acá';
  end if;

  select family_id into caller_family_id
  from public.family_members
  where user_id = (select auth.uid()) and permission_level = 'full'
  limit 1;

  if caller_family_id is null then
    raise exception 'Solo un miembro con acceso total puede quitar a alguien';
  end if;

  delete from public.family_members
  where family_id = caller_family_id and user_id = target_user_id;

  if not found then
    raise exception 'Esa persona no es parte de tu família';
  end if;
end;
$$;

revoke execute on function public.remove_family_member(uuid) from public, anon;
grant execute on function public.remove_family_member(uuid) to authenticated;
