-- Modo noche pregunta "¿Cómo se durmió?" para CADA despertar de la noche,
-- distinto de `contact` (cómo se durmió a la hora de acostarse) y de
-- `fall_asleep_mood` — pisar cualquiera de esos dos con el dato de un
-- despertar de las 3am borraría la info real de la hora de dormir. Se guarda
-- aparte y siempre representa el despertar MÁS RECIENTE, no un historial.
-- Mismos valores que CONTACTS (profiles.js) para poder comparar a futuro.
alter table public.events add column last_wake_method text
  check (last_wake_method in ('No necesitó contacto', 'Palmaditas', 'Mano encima', 'Cargada', 'Con la toma'));
