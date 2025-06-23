-- =====================================================
-- SISTEMA SAAS CAIXA - ESTRUTURA COMPLETA DO BANCO
-- =====================================================

-- Tabela de Lojas (Multi-tenant)
create table if not exists lojas (
  id uuid primary key default gen_random_uuid(),
  nome_loja text not null,
  url_logo text,
  dados_empresariais jsonb,
  status_assinatura text not null default 'ATIVA' check (status_assinatura in ('ATIVA', 'INATIVA', 'SUSPENSA')),
  data_criacao timestamp with time zone default now()
);

-- Tabela de Usuários (vinculada ao auth.users)
create table if not exists usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null check (role in ('SuperAdmin', 'Administrador', 'Colaborador')),
  loja_id uuid references lojas(id),
  created_at timestamp with time zone default now()
);

-- Tabela de Vendas
create table if not exists vendas (
  id uuid primary key default gen_random_uuid(),
  data_venda date not null,
  numero_pedido integer not null,
  valor_bruto numeric(12,2) not null,
  tipo_venda text not null check (tipo_venda in ('IFOOD', 'PRESENCIAL', 'WHATSAPP')),
  forma_pagamento text not null check (forma_pagamento in ('PIX', 'DINHEIRO', 'CARTÃO DE DÉBITO', 'CARTÃO DE CRÉDITO', 'IFOOD PAGAMENTO ONLINE', 'PICPAY')),
  desconto_percentual numeric(5,2),
  desconto_fixo numeric(12,2),
  valor_descontos numeric(12,2) not null default 0,
  taxa_plataforma_percentual numeric(5,2) not null default 0,
  taxa_plataforma_fixa numeric(12,2) not null default 0,
  valor_taxas numeric(12,2) not null default 0,
  valor_liquido numeric(12,2) not null,
  criado_em timestamp with time zone default now(),
  colaborador_id uuid references usuarios(id),
  loja_id uuid not null references lojas(id)
);

-- Tabela de Fornecedores
create table if not exists fornecedores (
  id uuid primary key default gen_random_uuid(),
  nome_fornecedor text not null,
  cnpj_cpf text,
  contato_principal text,
  email text,
  telefone text,
  data_cadastro timestamp with time zone default now(),
  loja_id uuid not null references lojas(id)
);

-- Tabela de Despesas
create table if not exists despesas (
  id uuid primary key default gen_random_uuid(),
  descricao text not null,
  valor numeric(12,2) not null,
  data_vencimento date not null,
  data_pagamento date,
  status_pagamento text not null check (status_pagamento in ('PAGO', 'PENDENTE', 'ATRASADO')),
  categoria text not null,
  fornecedor_id uuid references fornecedores(id),
  colaborador_id uuid references usuarios(id),
  numero_nota_fiscal text,
  anexo_comprovante text,
  loja_id uuid not null references lojas(id),
  criado_em timestamp with time zone default now()
);

-- Índices para performance
create index if not exists idx_vendas_loja_id on vendas(loja_id);
create index if not exists idx_vendas_data_venda on vendas(data_venda);
create index if not exists idx_despesas_loja_id on despesas(loja_id);
create index if not exists idx_despesas_data_vencimento on despesas(data_vencimento);
create index if not exists idx_fornecedores_loja_id on fornecedores(loja_id);
create index if not exists idx_usuarios_loja_id on usuarios(loja_id);
create index if not exists idx_usuarios_role on usuarios(role);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) - ISOLAMENTO MULTI-TENANT
-- =====================================================

-- Ativar RLS em todas as tabelas
alter table vendas enable row level security;
alter table despesas enable row level security;
alter table fornecedores enable row level security;
alter table usuarios enable row level security;
alter table lojas enable row level security;

-- Políticas para VENDAS
create policy "Vendas: SuperAdmin vê tudo" on vendas
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() and u.role = 'SuperAdmin'
    )
  );

create policy "Vendas: Usuários veem apenas da sua loja" on vendas
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() 
      and u.role in ('Administrador', 'Colaborador')
      and vendas.loja_id = u.loja_id
    )
  );

-- Políticas para DESPESAS
create policy "Despesas: SuperAdmin vê tudo" on despesas
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() and u.role = 'SuperAdmin'
    )
  );

create policy "Despesas: Usuários veem apenas da sua loja" on despesas
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() 
      and u.role in ('Administrador', 'Colaborador')
      and despesas.loja_id = u.loja_id
    )
  );

-- Políticas para FORNECEDORES
create policy "Fornecedores: SuperAdmin vê tudo" on fornecedores
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() and u.role = 'SuperAdmin'
    )
  );

create policy "Fornecedores: Usuários veem apenas da sua loja" on fornecedores
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() 
      and u.role in ('Administrador', 'Colaborador')
      and fornecedores.loja_id = u.loja_id
    )
  );

-- Políticas para USUARIOS
create policy "Usuarios: SuperAdmin vê tudo" on usuarios
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() and u.role = 'SuperAdmin'
    )
  );

create policy "Usuarios: Administrador vê usuários da sua loja" on usuarios
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() 
      and u.role = 'Administrador'
      and usuarios.loja_id = u.loja_id
    )
  );

create policy "Usuarios: Usuário vê seus próprios dados" on usuarios
  for select using (auth.uid() = id);

-- Políticas para LOJAS
create policy "Lojas: SuperAdmin vê tudo" on lojas
  for all using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() and u.role = 'SuperAdmin'
    )
  );

create policy "Lojas: Usuários veem apenas sua loja" on lojas
  for select using (
    exists (
      select 1 from usuarios u
      where u.id = auth.uid() 
      and u.role in ('Administrador', 'Colaborador')
      and lojas.id = u.loja_id
    )
  );

-- =====================================================
-- FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para atualizar status de despesas atrasadas
create or replace function atualizar_status_despesas()
returns trigger as $$
begin
  if new.data_vencimento < current_date and new.status_pagamento = 'PENDENTE' then
    new.status_pagamento := 'ATRASADO';
  end if;
  return new;
end;
$$ language plpgsql;

-- Trigger para atualizar status de despesas
create trigger trigger_atualizar_status_despesas
  before insert or update on despesas
  for each row
  execute function atualizar_status_despesas();

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

-- Inserir primeira loja (para migração)
insert into lojas (id, nome_loja, status_assinatura, data_criacao)
values (
  '550e8400-e29b-41d4-a716-446655440000',
  'Loja Padrão',
  'ATIVA',
  now()
) on conflict do nothing;

-- Inserir SuperAdmin (você deve criar este usuário manualmente no auth.users primeiro)
-- Substitua 'SEU_USER_ID_AQUI' pelo ID do usuário criado no auth.users
-- insert into usuarios (id, email, role)
-- values ('SEU_USER_ID_AQUI', 'admin@saascaixa.com', 'SuperAdmin'); 