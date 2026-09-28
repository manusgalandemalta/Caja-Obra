-- Migración 01 · dos presupuestos por obra + tope de Nafta
-- Pegar en Supabase > SQL Editor > New query > Run (una sola vez).
-- "presupuesto" (el que ya existía) pasa a ser lo que se le COBRA al cliente.
alter table public.clientes
  add column if not exists presupuesto_gastos numeric(14,2) not null default 0
  check (presupuesto_gastos >= 0);

insert into public.topes (categoria, tope) values ('nafta', 300000)
on conflict (categoria) do nothing;
