-- `active` ya significa "sigue siendo una indicación válida del médico, no
-- se retiró" — pero eso obligaba a activar el modo enfermedad entero para
-- ver el plan de dosis de UNA medicina puntual, aunque el catálogo completo
-- (Panadol, Flogobron, Gravol, Aerobom...) ya estuviera cargado de antes.
-- `in_use` es la marca de "la estamos dando ahora" — independiente de si
-- hay un episodio de enfermedad activo, y es lo que decide qué aparece en
-- el plan de dosis y en las notificaciones.
alter table public.med_prescriptions add column in_use boolean not null default false;
