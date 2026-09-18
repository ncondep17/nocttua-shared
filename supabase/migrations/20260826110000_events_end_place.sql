-- "Noche" ahora puede terminar en un lugar distinto de donde empezó (ej. se
-- durmió en su cuna, terminó en la cama de los papás) — place/contact ya
-- describen el INICIO de la noche, esto describe el final. Nullable: solo
-- tiene sentido para session='night' y solo una vez completado.
alter table public.events add column end_place text;
