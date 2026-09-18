-- Nocttua Coach's "Nuevo cliente" (create_client_family) creates a real
-- shell family + invite right away, so testing that button leaves behind
-- família fantasma with no real client attached. There was no way to undo
-- that — this lets the coach who created an unredeemed invite delete it,
-- which also removes the shell família (cascade), not just the invite row.

create function public.revoke_client_invite(target_invite_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_family_id uuid;
begin
  select family_id into target_family_id
  from public.family_invites
  where id = target_invite_id
    and created_by = (select auth.uid())
    and redeemed_at is null;

  if target_family_id is null then
    raise exception 'Esa invitación no existe, ya se canjeó, o no es tuya';
  end if;

  -- Borra la família entera: family_members y family_invites cuelgan de
  -- families con "on delete cascade", y una família creada por
  -- create_client_family no tiene nada más (sin bebés, sin plan) hasta que
  -- se canjea — no hay riesgo de perder datos reales de una família.
  delete from public.families where id = target_family_id;
end;
$$;

revoke execute on function public.revoke_client_invite(uuid) from public, anon;
grant execute on function public.revoke_client_invite(uuid) to authenticated;
