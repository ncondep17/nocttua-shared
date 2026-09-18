-- Necesaria para que el copy dinámico (Hoy, moods de sueño/toma) pueda
-- hablar en masculino/femenino/plural según cada bebé en vez de asumir
-- siempre femenino, que es lo que hacía todo el copy hasta ahora.
-- Nullable a propósito: los bebés ya creados no tienen este dato y no hay
-- forma honesta de adivinarlo — se le pide a la usuaria que lo complete en
-- Ajustes, y mientras tanto el copy sigue leyendo como femenino (mismo
-- comportamiento que tenía la app antes de esta columna).
alter table public.babies add column gender text check (gender in ('niño', 'niña'));
