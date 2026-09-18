-- Ajuste manual del banco de leche (se derramó un biberón, venció, etc.):
-- no es una toma real del bebé (no encaja en `feed`) ni una extracción
-- nueva (no encaja en `pump`) — es leche que sale del banco sin que nadie
-- la haya tomado. `volume_ml` es cuánto se resta; `note` el motivo, libre.
do $$
declare
  chk_name text;
begin
  select con.conname into chk_name
  from pg_constraint con
  join pg_class rel on rel.oid = con.conrelid
  join pg_namespace nsp on nsp.oid = rel.relnamespace
  where nsp.nspname = 'public' and rel.relname = 'events' and con.contype = 'c'
    and pg_get_constraintdef(con.oid) ilike '%''sleep''%'
  limit 1;

  if chk_name is not null then
    execute format('alter table public.events drop constraint %I', chk_name);
  end if;

  alter table public.events add constraint events_type_check check (type in ('sleep', 'feed', 'pump', 'diaper', 'bank_adjustment'));
end $$;
