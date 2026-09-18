-- MilkScreen needs to distinguish extractions kept for the freezer reserve
-- from milk used immediately (FeedLogSheet's "Va a la reserva" toggle).
alter table public.events add column to_reserve boolean not null default false;
