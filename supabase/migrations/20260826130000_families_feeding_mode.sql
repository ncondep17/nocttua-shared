-- Familias que solo usan biberón (fórmula o leche ya extraída por fuera de
-- rutina) no tienen extracción ni banco que trackear — Leche necesita saber
-- esto para no mostrar esa sección como si fuera parte del día a día.
alter table public.families add column feeding_mode text not null default 'breastfeeding'
  check (feeding_mode in ('breastfeeding', 'bottle_only'));

-- No existía ninguna policy de update en families (solo select) — hacía
-- falta para que un miembro pueda cambiar esta preferencia.
create policy families_update on public.families
  for update to authenticated
  using (private.is_family_member(id))
  with check (private.is_family_member(id));
