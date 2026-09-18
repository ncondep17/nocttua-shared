-- Apple exige que si la cuenta se puede crear desde la app, también se
-- pueda borrar desde la app (Guideline 5.1.1(v)) — no alcanza con "escribinos
-- para borrar tu cuenta".
--
-- Si la persona es la ÚNICA integrante de una família, esa família entera
-- (bebés, eventos, medicinas, notas — todo cuelga de `families` con
-- `on delete cascade`) se borra con ella: nadie más la puede ver ni
-- recuperar. Si comparte família con alguien más (pareja, niñera), la
-- família sigue existiendo para esa otra persona — solo se va la
-- membresía de quien se borra (cascade normal de `family_members`).
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  my_id uuid := (select auth.uid());
  fam record;
  remaining_members int;
begin
  if my_id is null then
    raise exception 'No hay sesión activa';
  end if;

  for fam in select family_id from public.family_members where user_id = my_id loop
    select count(*) into remaining_members from public.family_members where family_id = fam.family_id;
    if remaining_members <= 1 then
      delete from public.families where id = fam.family_id;
    end if;
  end loop;

  delete from auth.users where id = my_id;
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
