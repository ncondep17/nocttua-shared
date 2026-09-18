-- Saldo inicial del banco de leche: una mamá que ya usaba un banco antes de
-- empezar con Nocttua no tiene esa reserva registrada como extracciones
-- reales — sin este número, el balance calculado (extraído − consumido)
-- arranca en 0 aunque en el freezer ya haya litros. Se carga una sola vez
-- (o se ajusta a mano si hace falta) y se suma al balance calculado.
alter table public.families add column milk_bank_starting_ml numeric not null default 0;
