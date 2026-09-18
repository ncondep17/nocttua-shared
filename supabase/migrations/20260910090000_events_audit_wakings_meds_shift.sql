-- Fase 1 de la auditoría contra design_handoff_nocttua_ux: integridad de
-- datos. Ver plan en /Users/nataliaconde/.claude/plans/resilient-booping-dawn.md.

-- Regla "nada de sobrescribir" del README: editar un evento debe dejar
-- rastro de qué cambió y cuándo, no pisar el valor en silencio.
alter table public.events add column edited_at timestamptz;

create table public.event_edits (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  field text not null,
  previous_value jsonb,
  edited_at timestamptz not null default now(),
  edited_by uuid references public.profiles (id)
);

create index event_edits_event_id_idx on public.event_edits (event_id);

alter table public.event_edits enable row level security;
alter table public.event_edits force row level security;

create policy event_edits_select on public.event_edits
  for select to authenticated
  using (exists (
    select 1 from public.events e
    where e.id = event_edits.event_id and private.is_family_member(e.family_id)
  ));

create policy event_edits_insert on public.event_edits
  for insert to authenticated
  with check (exists (
    select 1 from public.events e
    where e.id = event_edits.event_id and private.is_family_member(e.family_id)
  ));

-- Despertares granulares — reemplaza wake_count/wake_minutes (que quedan,
-- pero pasan a ser mantenidos por la app junto con wakings, no la única
-- fuente) para que Mañana pueda dibujar cada despertar en su posición real
-- en vez de una barra plana. Forma: [{at: ISO, durationMin: number,
-- method: 'alone'|'patted'|'held'|'fed'|null}].
alter table public.events add column wakings jsonb not null default '[]'::jsonb;

comment on column public.events.wakings is
  'Despertares de esta noche con hora exacta — fuente de verdad para noches nuevas. wake_count/wake_minutes se siguen escribiendo en paralelo por compatibilidad con el puntaje ya existente.';

-- last_wake_method pasa de guardar la etiqueta en español (CONTACTS) a la
-- clave estable — mismo problema que ya se corrigió una vez para
-- baselines.fall_asleep_method: cambiar de bebé o de idioma no debe borrar
-- la respuesta. 'touched' (Mano encima) es una quinta clave que no está en
-- el README (que solo define alone|patted|held|fed para la línea base del
-- assessment) porque el registro real de Modo Noche/SleepLogSheet tiene 5
-- opciones, no 4 — ver CONTACT_KEYS en data/profiles.js.
alter table public.events drop constraint if exists events_last_wake_method_check;
alter table public.events add constraint events_last_wake_method_check
  check (last_wake_method is null or last_wake_method in ('alone', 'patted', 'touched', 'held', 'fed'));

-- Medicinas: foto de la receta + recordatorio previo a cada dosis + misma
-- auditoría de ediciones que events (la indicación del médico es justo el
-- tipo de dato donde la asesora necesita ver qué cambió y cuándo).
alter table public.med_prescriptions add column photo_url text;
alter table public.med_prescriptions add column remind_minutes_before int not null default 5;
alter table public.med_prescriptions add column edited_at timestamptz;

create table public.med_prescription_edits (
  id uuid primary key default gen_random_uuid(),
  prescription_id uuid not null references public.med_prescriptions (id) on delete cascade,
  field text not null,
  previous_value jsonb,
  edited_at timestamptz not null default now(),
  edited_by uuid references public.profiles (id)
);

create index med_prescription_edits_prescription_id_idx on public.med_prescription_edits (prescription_id);

alter table public.med_prescription_edits enable row level security;
alter table public.med_prescription_edits force row level security;

create policy med_prescription_edits_select on public.med_prescription_edits
  for select to authenticated
  using (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_edits.prescription_id and private.is_family_member(p.family_id)
  ));

create policy med_prescription_edits_insert on public.med_prescription_edits
  for insert to authenticated
  with check (exists (
    select 1 from public.med_prescriptions p
    where p.id = med_prescription_edits.prescription_id and private.has_full_access(p.family_id)
  ));

-- Duración declarada del tratamiento (cuándo empezó, cuántos días dijo el
-- pediatra) — la "próxima dosis" en sí NO se pre-genera como cronograma
-- fijo: medPlan() ya la recalcula en vivo desde la última dosis real
-- (lastDose + everyHours), y un cronograma rígido se desincroniza de la
-- realidad apenas una dosis se da tarde o temprano — peor que no tenerlo.
alter table public.med_prescriptions add column active_from timestamptz;
alter table public.med_prescriptions add column duration_days int check (duration_days > 0);

-- Turno de noche — Equipo necesita mostrar "turno de noche hoy" y, más
-- adelante, dirigir notificaciones a quien esté de turno.
alter table public.family_members add column night_shift_dates date[] not null default '{}';

-- Turno de noche: mismo patrón que update_member_permission/remove_family_member
-- (security-definer, family_members no tiene policy de update directa) — pero
-- sin las restricciones de esas dos (marcarse a uno mismo de turno es normal,
-- no es un cambio de permisos sensible).
create function public.set_night_shift_today(target_user_id uuid, on_duty boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller_family_id uuid;
  today date := current_date;
begin
  select family_id into caller_family_id
  from public.family_members
  where user_id = (select auth.uid())
  limit 1;

  if caller_family_id is null then
    raise exception 'No pertenecés a ninguna família';
  end if;

  update public.family_members
  set night_shift_dates = case
    when on_duty then array(select distinct unnest(night_shift_dates || array[today]))
    else array(select unnest(night_shift_dates) except select today)
  end
  where family_id = caller_family_id and user_id = target_user_id;

  if not found then
    raise exception 'Esa persona no es parte de tu família';
  end if;
end;
$$;

revoke execute on function public.set_night_shift_today(uuid, boolean) from public, anon;
grant execute on function public.set_night_shift_today(uuid, boolean) to authenticated;

-- siblingType a nivel família (antes solo vivía en el borrador del
-- assessment) — Hoy lo necesita para decidir si el desfase entre mellizas
-- es una anomalía a resolver ('multiple') o algo que ni corresponde
-- calcular. 'staggered' sigue fuera de alcance (ver el plan), por eso el
-- check solo admite las dos que ya soporta el resto de la app.
alter table public.families add column sibling_type text not null default 'single'
  check (sibling_type in ('single', 'multiple'));

-- maxPerDay pasa de aviso a tope duro: si el cuidador insiste después del
-- límite, queda marcado (no se bloquea del todo — puede ser una indicación
-- real del pediatra para un caso puntual, pero la asesora necesita verlo).
alter table public.med_doses add column insisted_past_limit boolean not null default false;

-- Acción "Saltar" de la notificación de dosis: queda una fila para que el
-- historial no tenga un hueco silencioso, distinta de una dosis realmente dada.
alter table public.med_doses add column skipped boolean not null default false;

-- Bucket privado para la foto de la receta — RLS igual que med_prescriptions
-- (cualquier miembro de la família la ve, solo acceso total la sube/borra).
-- El path de cada objeto es `${family_id}/${prescription_id}/...`, así el
-- primer segmento del path sirve para filtrar sin otra tabla.
insert into storage.buckets (id, name, public) values ('prescription-photos', 'prescription-photos', false)
  on conflict (id) do nothing;

create policy prescription_photos_select on storage.objects
  for select to authenticated
  using (bucket_id = 'prescription-photos' and private.is_family_member((storage.foldername(name))[1]::uuid));

create policy prescription_photos_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'prescription-photos' and private.has_full_access((storage.foldername(name))[1]::uuid));

create policy prescription_photos_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'prescription-photos' and private.has_full_access((storage.foldername(name))[1]::uuid));
