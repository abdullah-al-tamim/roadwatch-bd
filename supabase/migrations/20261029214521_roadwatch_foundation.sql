create extension if not exists postgis with schema extensions;
create schema if not exists private;
create table public.categories (
 id smallint primary key, name text not null, ttl_minutes integer not null check(ttl_minutes between 10 and 10080), enabled boolean not null default true
);
insert into public.categories values (0,'Roadside activity',30,true),(1,'Accident',60,true),(2,'Road closure',240,true),(3,'Congestion',20,true),(4,'Road damage',10080,true),(5,'Waterlogging',120,true),(6,'Broken-down vehicle',60,true),(7,'Other hazard',120,true);
alter table public.categories enable row level security;
create policy read_categories on public.categories for select using(true);
grant select on public.categories to anon, authenticated;
create table public.incidents (
 id uuid primary key default gen_random_uuid(),
 category smallint not null references public.categories,
 author_id uuid not null references auth.users on delete cascade,
 longitude double precision not null check(longitude between -180 and 180),
 latitude double precision not null check(latitude between -85 and 85),
 location extensions.geography(Point,4326) generated always as (extensions.st_setsrid(extensions.st_makepoint(longitude,latitude),4326)::extensions.geography) stored,
 description text not null default '' check(length(description)<=280),
 created_at timestamptz not null default now(),
 expires_at timestamptz not null,
 last_confirmation_at timestamptz,
 status text not null default 'awaiting_confirmation' check(status in ('awaiting_confirmation','community_confirmed','disputed','expired','removed')),
 road_segment text
);
create index incidents_location_idx on public.incidents using gist(location);
create index incidents_expiry_idx on public.incidents(expires_at);
create index incidents_author_created_idx on public.incidents(author_id,created_at);
alter table public.incidents enable row level security;
create policy current_incidents on public.incidents for select using(expires_at>now() and status not in ('removed','expired'));
create policy own_insert on public.incidents for insert to authenticated with check(author_id=(select auth.uid()) and not coalesce(((select auth.jwt())->>'is_anonymous')::boolean,false));
grant select(id,category,longitude,latitude,description,created_at,expires_at,last_confirmation_at,status,road_segment) on public.incidents to anon,authenticated;
grant insert(category,author_id,longitude,latitude,description) on public.incidents to authenticated;
create function private.prepare_report() returns trigger language plpgsql security definer set search_path='' as $$
declare ttl integer;
begin
 if auth.uid() is null or new.author_id<>auth.uid() then raise exception 'Sign in required'; end if;
 perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text,0));
 if (select count(*) from public.incidents where author_id=auth.uid() and created_at>now()-interval '1 hour')>=6 then raise exception 'Reporting limit reached. Try later.'; end if;
 select ttl_minutes into ttl from public.categories where id=new.category and enabled;
 if ttl is null then raise exception 'Category unavailable'; end if;
 if exists(select 1 from public.incidents where category=new.category and expires_at>now() and status not in ('removed','expired') and extensions.st_dwithin(location,extensions.st_setsrid(extensions.st_makepoint(new.longitude,new.latitude),4326)::extensions.geography,50)) then raise exception 'A similar nearby report exists. Confirm it instead.'; end if;
 new.created_at=now(); new.expires_at=now()+make_interval(mins=>ttl); new.status='awaiting_confirmation';
 return new;
end $$;
revoke all on function private.prepare_report() from public;
create trigger prepare_report before insert on public.incidents for each row execute function private.prepare_report();
create table public.confirmations (
 incident_id uuid not null references public.incidents on delete cascade,
 user_id uuid not null references auth.users on delete cascade,
 kind text not null check(kind in ('confirm','gone','flag')),
 created_at timestamptz not null default now(),
 primary key(incident_id,user_id)
);
create index confirmations_user_idx on public.confirmations(user_id);
alter table public.confirmations enable row level security;
create policy own_confirmations on public.confirmations for select to authenticated using(user_id=(select auth.uid()));
create policy insert_confirmation on public.confirmations for insert to authenticated with check(user_id=(select auth.uid()) and not coalesce(((select auth.jwt())->>'is_anonymous')::boolean,false));
grant select on public.confirmations to authenticated;
grant insert(incident_id,user_id,kind) on public.confirmations to authenticated;
create function private.validate_confirmation() returns trigger language plpgsql security definer set search_path='' as $$
declare target public.incidents;
begin
 if auth.uid() is null or new.user_id<>auth.uid() then raise exception 'Sign in required'; end if;
 perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text,1));
 if (select count(*) from public.confirmations where user_id=auth.uid() and created_at>now()-interval '1 hour')>=30 then raise exception 'Confirmation limit reached'; end if;
 select * into target from public.incidents where id=new.incident_id for update;
 if target.id is null or target.expires_at<=now() or target.status in ('removed','expired') then raise exception 'Report is no longer current'; end if;
 if target.author_id=auth.uid() then raise exception 'You cannot confirm your own report'; end if;
 new.created_at=now();
 -- Confirmation count alone never establishes truth. Moderation promotes verified reports.
 update public.incidents set status=case when new.kind in ('flag','gone') then 'disputed' else status end,last_confirmation_at=case when new.kind='confirm' then now() else last_confirmation_at end where id=new.incident_id;
 return new;
end $$;
revoke all on function private.validate_confirmation() from public;
create trigger validate_confirmation before insert on public.confirmations for each row execute function private.validate_confirmation();
create table public.saved_places(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users on delete cascade,name text not null check(length(name) between 1 and 80),longitude double precision not null check(longitude between -180 and 180),latitude double precision not null check(latitude between -85 and 85));
create index saved_places_user_idx on public.saved_places(user_id);
alter table public.saved_places enable row level security;
create policy own_places on public.saved_places for all to authenticated using(user_id=(select auth.uid())) with check(user_id=(select auth.uid()));
grant select,insert,update,delete on public.saved_places to authenticated;
