revoke all on public.incidents,public.confirmations,public.categories,public.saved_places from anon,authenticated;
grant select on public.categories to anon,authenticated;
grant select(id,category,longitude,latitude,description,created_at,expires_at,last_confirmation_at,status,road_segment) on public.incidents to anon,authenticated;
grant insert(category,author_id,longitude,latitude,description) on public.incidents to authenticated;
grant select on public.confirmations to authenticated;
grant insert(incident_id,user_id,kind) on public.confirmations to authenticated;
grant select,insert,update,delete on public.saved_places to authenticated;
