-- Agregar/quitar un bebé (dentro del máximo de 2 que ya impone el check de
-- tone) es una acción estructural, no un ajuste del día a día — se restringe
-- a quien tiene acceso total, mismo criterio que las recetas y los cambios
-- de permisos del equipo. babies_update (editar nombre/fecha) se deja como
-- estaba: cualquier miembro de la família puede corregir un dato existente.
alter policy babies_insert on public.babies
  with check (private.has_full_access(family_id));

create policy babies_delete on public.babies
  for delete to authenticated
  using (private.has_full_access(family_id));
