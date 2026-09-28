-- =====================================================================
-- Caja de obra · esquema para Supabase
-- Pegá TODO este archivo en Supabase > SQL Editor > New query > Run.
-- Los mails de los socios ya están cargados en la sección 6.
-- =====================================================================

-- 1. Socios habilitados (solo estos mails pueden ver y cargar datos)
create table if not exists public.socios (
  email  text primary key,
  nombre text not null unique check (nombre in ('DARIO', 'TOMAS'))
);

-- 2. Clientes / obras
create table if not exists public.clientes (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  presupuesto numeric(14,2) not null default 0 check (presupuesto >= 0),
  created_at  timestamptz not null default now()
);

-- 3. Topes por categoría (por obra)
create table if not exists public.topes (
  categoria text primary key,
  tope      numeric(14,2) not null default 0 check (tope >= 0)
);

-- 4. Movimientos
create table if not exists public.movimientos (
  id           uuid primary key default gen_random_uuid(),
  tipo         text not null check (tipo in ('gasto', 'ingreso', 'comp')),
  monto        numeric(14,2) not null check (monto > 0),
  categoria    text not null,
  subcategoria text,
  fecha        date not null,
  nota         text,
  socio        text not null check (socio in ('DARIO', 'TOMAS')),
  cliente_id   uuid references public.clientes(id) on delete restrict,
  creado_por   text default (auth.jwt() ->> 'email'),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint ingreso_con_cliente check (tipo <> 'ingreso' or cliente_id is not null)
);
create index if not exists movimientos_fecha_idx on public.movimientos (fecha);
create index if not exists movimientos_cliente_idx on public.movimientos (cliente_id);

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists movimientos_touch on public.movimientos;
create trigger movimientos_touch before update on public.movimientos
  for each row execute function public.touch_updated_at();

-- 5. Seguridad: solo los socios pueden leer y escribir
create or replace function public.es_socio() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.socios
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

alter table public.socios      enable row level security;
alter table public.clientes    enable row level security;
alter table public.topes       enable row level security;
alter table public.movimientos enable row level security;

drop policy if exists socios_select on public.socios;
create policy socios_select on public.socios
  for select to authenticated using (public.es_socio());

drop policy if exists clientes_all on public.clientes;
create policy clientes_all on public.clientes
  for all to authenticated using (public.es_socio()) with check (public.es_socio());

drop policy if exists topes_all on public.topes;
create policy topes_all on public.topes
  for all to authenticated using (public.es_socio()) with check (public.es_socio());

drop policy if exists movimientos_all on public.movimientos;
create policy movimientos_all on public.movimientos
  for all to authenticated using (public.es_socio()) with check (public.es_socio());

-- Tiempo real: que cada uno vea al instante lo que carga el otro
do $$
begin
  begin alter publication supabase_realtime add table public.movimientos; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.clientes;    exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.topes;       exception when duplicate_object then null; end;
end $$;

-- 6. Datos iniciales (socios habilitados)
insert into public.socios (email, nombre) values
  ('darionolazco@gmail.com', 'DARIO'),
  ('tomasgdm@gmail.com', 'TOMAS')
on conflict (email) do update set nombre = excluded.nombre;

insert into public.topes (categoria, tope) values
  ('brian', 600000), ('changa', 300000), ('materiales', 1800000),
  ('viaticos', 200000), ('acopios', 600000)
on conflict (categoria) do nothing;
