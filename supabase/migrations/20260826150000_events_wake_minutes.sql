-- wake_count ya dice CUÁNTAS veces se despertó de noche; esto agrega CUÁNTO
-- duró en total despierta esos despertares (ej. una hora a las 3am puede
-- afectar todo el día siguiente, no es lo mismo que un despertar de 5 min).
alter table public.events add column wake_minutes int;
