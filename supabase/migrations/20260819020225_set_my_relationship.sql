-- Actualiza SOLO relationship de la fila propia en family_members. No se
-- abre un update policy directo en la tabla porque también tiene
-- permission_level — un update de cliente sin restricción de columna
-- dejaría a cualquiera escalar su propio nivel de acceso.
create function public.set_my_relationship(target_relationship text)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.family_members
  set relationship = target_relationship
  where user_id = (select auth.uid());
$$;

revoke execute on function public.set_my_relationship(text) from public, anon;
grant execute on function public.set_my_relationship(text) to authenticated;
