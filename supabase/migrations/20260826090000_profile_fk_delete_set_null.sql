-- Deleting a user from Authentication → Users failed with a foreign key
-- violation the moment that person had authored anything: `events.created_by`,
-- `plan_versions.coach_id`, `family_invites.created_by`/`redeemed_by`,
-- `telemetry_events.user_id`, `med_episodes.created_by`,
-- `med_prescriptions.created_by` and `med_doses.given_by` all reference
-- `profiles` with the Postgres default (no action), which blocks the
-- cascade from auth.users → profiles.
--
-- Fix: on delete set null for all of these. The row itself is real history
-- (a sleep event, a published plan, a dose given) and should survive; only
-- who-did-it gets blanked once that account is gone. This is different from
-- `family_members.user_id`, which stays `on delete cascade` on purpose —
-- membership has no meaning without the member.

do $$
declare
  t record;
  fk_name text;
begin
  for t in
    select * from (values
      ('events', 'created_by'),
      ('plan_versions', 'coach_id'),
      ('family_invites', 'created_by'),
      ('family_invites', 'redeemed_by'),
      ('telemetry_events', 'user_id'),
      ('med_episodes', 'created_by'),
      ('med_prescriptions', 'created_by'),
      ('med_doses', 'given_by'),
      ('shift_notes', 'author_id')
    ) as cols(table_name, column_name)
  loop
    select con.conname into fk_name
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    join pg_namespace nsp on nsp.oid = rel.relnamespace
    join pg_attribute att on att.attrelid = rel.oid and att.attnum = any(con.conkey)
    where nsp.nspname = 'public'
      and rel.relname = t.table_name
      and att.attname = t.column_name
      and con.contype = 'f'
    limit 1;

    if fk_name is not null then
      execute format('alter table public.%I drop constraint %I', t.table_name, fk_name);
    end if;

    execute format(
      'alter table public.%I add constraint %I foreign key (%I) references public.profiles (id) on delete set null',
      t.table_name, t.table_name || '_' || t.column_name || '_fkey', t.column_name
    );
  end loop;
end $$;
