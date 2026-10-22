-- Bug real encontrado en uso: alguien que pisó el bug de "Ya tengo cuenta"
-- (arreglado en la app, pero ya había gente afectada) terminaba con una
-- família propia accidental (de pasar por el onboarding de "sola" sin
-- querer) ANTES de canjear un código de invitación real. redeem_invite()
-- insertaba la membresía nueva sin tocar la vieja, así que la cuenta
-- quedaba con DOS family_members — y getMyFamilyId() (ORDER BY created_at
-- ASC LIMIT 1) devolvía la más vieja: la família accidental, no la
-- invitada. Resultado: "ningún registro coincide" con lo que cargó el
-- resto de la família real.
--
-- Mismo criterio que delete_my_account() para limpiar una família
-- huérfana: si soy el único miembro, se borra entera (cascade sobre
-- bebés/eventos, nadie más la puede perder); si no soy el único, solo se
-- quita MI membresía, sin tocar a nadie más.
create or replace function public.redeem_invite(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_invite record;
  stray record;
  stray_member_count int;
begin
  select * into target_invite
  from public.family_invites
  where code = upper(invite_code) and redeemed_at is null and (expires_at is null or expires_at > now())
  limit 1;

  if target_invite is null then
    raise exception 'Código inválido o vencido';
  end if;

  for stray in
    select family_id from public.family_members
    where user_id = (select auth.uid()) and family_id <> target_invite.family_id
  loop
    select count(*) into stray_member_count from public.family_members where family_id = stray.family_id;
    if stray_member_count <= 1 then
      delete from public.families where id = stray.family_id;
    else
      delete from public.family_members where family_id = stray.family_id and user_id = (select auth.uid());
    end if;
  end loop;

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
