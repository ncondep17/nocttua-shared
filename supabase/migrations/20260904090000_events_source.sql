-- "source" distingue un registro medido de uno asumido. Hasta ahora no había
-- forma de saber si started_at/ended_at eran un timestamp real (cronómetro o
-- carga manual) o una hora copiada de "lo de siempre" sin que la usuaria
-- confirmara el dato real (el botón "Sí, todo normal" del rediseño de Hoy).
-- Sin esta columna, un registro asumido contaminaba los promedios de
-- diagnóstico (ventana media, latencia) como si fuera un dato medido.
alter table public.events add column source text not null default 'manual'
  check (source in ('manual', 'timer', 'assumed'));
