-- Notas de relevo (Hoy, sección "Notas de relevo"): lo que un cuidador le
-- deja al siguiente turno. CLAUDE.md la marca como la pieza que hace que la
-- app funcione en una casa con niñera — no es decorativa.
create table public.shift_notes (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  author_id uuid references public.profiles (id),
  text text not null,
  created_at timestamptz not null default now()
);

create index shift_notes_family_id_created_at_idx on public.shift_notes (family_id, created_at desc);

alter table public.shift_notes enable row level security;
alter table public.shift_notes force row level security;

create policy shift_notes_select on public.shift_notes
  for select to authenticated
  using (private.is_family_member(family_id));

create policy shift_notes_insert on public.shift_notes
  for insert to authenticated
  with check (private.is_family_member(family_id) and author_id = (select auth.uid()));
