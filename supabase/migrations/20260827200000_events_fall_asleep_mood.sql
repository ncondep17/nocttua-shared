-- Cómo fue el proceso de dormirse (tranquila / con berrinche / costó mucho),
-- distinto de wake_mood (cómo despertó). Deja ver si un despertar nocturno o
-- un berrinche a la hora de dormir se explica por sobrecansancio (costó
-- mucho / berrinche) o si el bebé simplemente no le tocaba esa ventana
-- todavía. Nullable: solo tiene sentido para eventos de sueño, y ninguno
-- viejo lo tiene cargado.
alter table public.events add column fall_asleep_mood text;
