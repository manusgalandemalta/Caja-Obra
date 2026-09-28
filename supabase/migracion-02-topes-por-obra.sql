-- Migración 02 · topes por categoría DENTRO de cada obra
-- Pegar en Supabase > SQL Editor > New query > Run (una sola vez).
-- Cada obra tiene su propio tope para cada categoría.
-- A las obras que ya existen les copia los topes generales que había, como punto de partida.

create table if not exists public.topes_obra (
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  categoria  text not null,
  tope       numeric(14,2) not null default 0 check (tope >= 0),
  primary key (cliente_id, categoria)
);

alter table public.topes_obra enable row level security;
drop policy if exists topes_obra_all on public.topes_obra;
create policy topes_obra_all on public.topes_obra
  for all to authenticated using (public.es_socio()) with check (public.es_socio());

do $$
begin
  begin alter publication supabase_realtime add table public.topes_obra; exception when duplicate_object then null; end;
end $$;

insert into public.topes_obra (cliente_id, categoria, tope)
select c.id, t.categoria, t.tope
from public.clientes c cross join public.topes t
where t.tope > 0
on conflict (cliente_id, categoria) do nothing;
