-- Ejecutar en SQL Editor de Supabase, proyecto nuevo.
-- Las publicaciones se reciben sin sesión, pero solo se leen públicamente al aprobarse.
create extension if not exists pgcrypto;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  place_name text not null check (char_length(trim(place_name)) between 2 and 120),
  display_name text not null default 'Anónimo' check (char_length(display_name) <= 80),
  genre text not null check (genre in ('Poema','Crónica','Cuento breve','Relato','Reflexión','Otro')),
  category text not null check (category in ('Literatura','Música','Teatro','Artes visuales','Naturaleza','Vida cotidiana','Memoria','Arquitectura')),
  title text not null default '' check (char_length(title) <= 160),
  body text not null check (char_length(trim(body)) between 40 and 12000),
  description text not null default '' check (char_length(description) <= 500),
  latitude double precision not null check (latitude between 6.0 and 6.5),
  longitude double precision not null check (longitude between -75.9 and -75.3),
  photo_path text not null check (photo_path ~ '^[0-9a-f-]{36}\.(jpg|png|webp)$'),
  consent boolean not null check (consent = true),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create index if not exists submissions_status_idx on public.submissions(status,created_at desc);

create or replace function public.is_editor() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.admins a where a.user_id = (select auth.uid()));
$$;

alter table public.admins enable row level security;
alter table public.submissions enable row level security;

create policy "Only editors see editor membership" on public.admins
for select to authenticated using (user_id = (select auth.uid()));

create policy "Anyone can submit pending content" on public.submissions
for insert to anon, authenticated with check (status='pending' and reviewed_at is null);

create policy "Approved entries are public, editors see all" on public.submissions
for select to anon, authenticated using (status='approved' or public.is_editor());

create policy "Only editors can moderate" on public.submissions
for update to authenticated using (public.is_editor()) with check (public.is_editor());

-- Almacenamiento privado. Las imágenes solo se pueden leer cuando
-- su publicación está aprobada o cuando un editor está autenticado.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('contribuciones','contribuciones',false,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=false,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];

create policy "Anyone can upload an image for review" on storage.objects
for insert to anon, authenticated with check (
  bucket_id='contribuciones' and
  (storage.extension(name) in ('jpg','png','webp'))
);

create policy "Read only approved photos or editor" on storage.objects
for select to anon, authenticated using (
  bucket_id='contribuciones' and (
    public.is_editor() or exists (
      select 1 from public.submissions s
      where s.photo_path = storage.objects.name and s.status='approved'
    )
  )
);

-- PASO MANUAL tras crear el primer usuario en Authentication > Users:
-- insert into public.admins (user_id) values ('UUID-DEL-USUARIO');
-- Ejecutar la inserción desde SQL Editor con permisos de propietario.
