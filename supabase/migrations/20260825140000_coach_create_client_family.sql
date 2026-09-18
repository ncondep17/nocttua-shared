-- Falta la pieza que `full_app_schema.sql` dejó pendiente para "cuando exista
-- un panel de asesora que lo publique": hoy `create_invite` solo lo puede
-- llamar alguien que YA es miembro `full` de una família (sirve para invitar
-- a una niñera, o para que la família invite a su asesora — ver
-- 09_AccountTypeScreen/AccountTypeScreen). No sirve para que una asesora
-- arranque un caso nuevo, porque todavía no es miembro de ninguna família.
--
-- `create_client_family` es la contraparte del lado de la asesora: crea la
-- família vacía, la deja como miembro con el nivel que ELLA propone (nunca
-- `full` automático — el acceso lo termina de decidir la família al canjear,
-- misma regla que en el resto del producto), y genera el código real de
-- `family_invites` con permiso `full` para quien lo canjee, porque quien
-- canjea es la família dueña de sus propios datos.
--
-- El canje en sí no cambia: sigue siendo `redeem_invite`, el mismo que ya
-- usa `09_AccountTypeScreen` en el teléfono.

create function public.create_client_family(coach_requested_level public.permission_level default 'reports')
returns table (family_id uuid, invite_code text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_family_id uuid;
  new_code text;
begin
  if not exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'coach'
  ) then
    raise exception 'Solo una cuenta de asesora puede crear un caso nuevo';
  end if;

  insert into public.families default values returning id into new_family_id;

  insert into public.family_members (family_id, user_id, permission_level, relationship)
  values (new_family_id, (select auth.uid()), coach_requested_level, 'Asesora');

  new_code := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));

  insert into public.family_invites (family_id, code, permission_level, created_by)
  values (new_family_id, new_code, 'full', (select auth.uid()));

  return query select new_family_id, new_code;
end;
$$;

revoke execute on function public.create_client_family(public.permission_level) from public, anon;
grant execute on function public.create_client_family(public.permission_level) to authenticated;
