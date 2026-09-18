-- Rol de cada miembro dentro de la família (Papá/Mamá/Niñera/Otro), para no
-- mostrarle "asesora" a alguien que se sumó como cuidador vía código.
alter table public.family_members add column relationship text;

-- Siesta vs. sueño de noche: hoy el registro de sueño no distingue, lo que
-- fuerza a cargar bloques de 8-11h a los tramos de un stepper de 5 minutos.
alter table public.events add column session text check (session in ('nap', 'night'));

-- Despertares breves durante la noche (se levanta a consolar, <5 min): un
-- contador, no un registro con hora exacta por cada uno — ver conversación.
alter table public.events add column wake_count int;
