-- Log de pañales (pipí/popó) — clave en los primeros 3 meses para que el
-- pediatra vea si el bebé está bien alimentado e hidratado. Reutiliza la
-- misma tabla `events` que sueño/toma/extracción (mismo patrón: columnas
-- compartidas, significado distinto según `type`): `kind` guarda 'Pipí' /
-- 'Popó' / 'Pipí y popó', `note` queda libre para anotar algo puntual
-- (color, consistencia) si hace falta.
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

  alter table public.events add constraint events_type_check check (type in ('sleep', 'feed', 'pump', 'diaper'));
end $$;
