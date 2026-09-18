-- Guide content (GuideScreen / GuideCategoryScreen): shared reference
-- content, not scoped to a family. Read-only for clients; writes go through
-- the dashboard/service_role until a content-editing tool exists.

create table public.guide_categories (
  id text primary key,
  label text not null,
  position int not null default 0
);

alter table public.guide_categories enable row level security;
alter table public.guide_categories force row level security;

create policy guide_categories_select on public.guide_categories
  for select to authenticated
  using (true);

create table public.guide_tips (
  id text primary key,
  category_id text not null references public.guide_categories (id) on delete cascade,
  title text not null,
  body text not null,
  how text[],
  position int not null default 0
);

create index guide_tips_category_id_idx on public.guide_tips (category_id);

alter table public.guide_tips enable row level security;
alter table public.guide_tips force row level security;

create policy guide_tips_select on public.guide_tips
  for select to authenticated
  using (true);

insert into public.guide_categories (id, label, position) values
  ('ventanas', 'Ventanas de sueño', 1),
  ('noche', 'Noches y despertares', 2),
  ('lactancia', 'Lactancia y extracción', 3),
  ('sincronia', 'Sincronizar a dos bebés', 4),
  ('equipo', 'Repartir turnos', 5);

insert into public.guide_tips (id, category_id, title, body, how, position) values
  ('t1', 'ventanas', '¿Cuánto puede estar despierta a las 19 semanas?',
   'Entre 1h 45m y 2h 15m. Pasado ese punto cuesta el doble dormirla y la siesta sale más corta.',
   array['Anotá la hora del despertar en cuanto abre los ojos.', 'Empezá la rutina de dormir 15 minutos antes del final de la ventana.'],
   1),
  ('t2', 'sincronia', 'Despertar al segundo bebé para alinear la toma',
   'Cuando el desfase pasa de 30 minutos, la noche se parte en dos. Alinear la toma nocturna suele devolver un bloque entero de sueño a quien esté de turno.',
   array['Cuando el primero pida, ofrecé al segundo en los 15 minutos siguientes.', 'No fuerces si el segundo lleva menos de 2 h dormido.'],
   1),
  ('t3', 'noche', 'Un despertar no significa hambre',
   'Registrá qué pasó antes de ofrecer comida: ruido, pañal, calor, final de ciclo. El patrón aparece a los pocos días.',
   null, 1),
  ('t4', 'lactancia', 'Extracción doble antes de la noche larga',
   'La extracción de la tarde suele dar el volumen que cubre la toma de madrugada sin despertar a quien duerme.',
   array['Bloque de 15-20 min con doble extractor.', 'Etiquetá con hora y volumen antes de guardar.'],
   1);
