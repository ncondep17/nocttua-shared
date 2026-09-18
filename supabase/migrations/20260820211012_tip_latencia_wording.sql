-- "Latencia" es jerga de sueño que no todos los papás conocen — se reemplaza
-- por "tarda en dormirse" en todo el copy de la app (Analíticas, el log de
-- sueño, este tip). Solo el título cambia: el hook y el cuerpo de t06 ya
-- decían "tarda en dormirse", nunca usaron la palabra "latencia".
update public.guide_tips
set title = 'Cuánto tarda en dormirse te dice si la hora está bien'
where id = 't06';
