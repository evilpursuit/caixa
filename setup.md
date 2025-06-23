# 🚀 Setup Rápido - SaaS Caixa

## Passo a Passo para Deixar o Sistema 100% Funcional

### 1. 📦 Instalar Dependências
```bash
npm install
```

### 2. 🔧 Configurar Variáveis de Ambiente
Crie o arquivo `.env.local` na raiz do projeto:

```env
NEXT_PUBLIC_SUPABASE_URL=https://ydorrxsfwxymhlchonvp.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlkb3JyeHNmd3h5bWhsY2hvbnZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MDgxNzIsImV4cCI6MjA2NjE4NDE3Mn0.rG89FPc7_gXYjRU16ySgggxkGeQWjACL7caSvDTNg5Y
```

### 3. 🗄️ Configurar Banco de Dados

#### 3.1 Acesse o Supabase
1. Vá para [https://app.supabase.com](https://app.supabase.com)
2. Acesse o projeto: `ydorrxsfwxymhlchonvp`

#### 3.2 Execute o SQL
1. No menu lateral, clique em "SQL Editor"
2. Clique em "New query"
3. Cole todo o conteúdo do arquivo `supabase-setup.sql`
4. Clique em "Run" para executar

### 4. 👤 Criar SuperAdmin

#### 4.1 Criar Usuário no Auth
1. No Supabase, vá para "Authentication" > "Users"
2. Clique em "Add user"
3. Preencha:
   - **Email**: `admin@saascaixa.com`
   - **Password**: `admin123` (ou sua senha preferida)
4. Clique em "Create user"
5. **Copie o ID do usuário criado** (você precisará dele no próximo passo)

#### 4.2 Registrar como SuperAdmin
1. Volte ao "SQL Editor"
2. Execute o comando (substitua `SEU_USER_ID_AQUI` pelo ID copiado):

```sql
insert into usuarios (id, email, role)
values ('SEU_USER_ID_AQUI', 'admin@saascaixa.com', 'SuperAdmin');
```

### 5. 🏃‍♂️ Executar o Projeto
```bash
npm run dev
```

### 6. 🌐 Acessar o Sistema
1. Abra [http://localhost:3000](http://localhost:3000)
2. Faça login com:
   - **Email**: `admin@saascaixa.com`
   - **Senha**: `admin123` (ou a senha que você definiu)

## ✅ Verificação do Setup

### ✅ Sistema Funcionando
- [ ] Login funciona
- [ ] Redirecionamento para SuperAdmin
- [ ] Dashboard carrega sem erros
- [ ] Pode criar novas lojas

### ✅ Banco de Dados
- [ ] Tabelas criadas corretamente
- [ ] Políticas RLS ativas
- [ ] SuperAdmin pode acessar tudo
- [ ] Dados isolados por loja

### ✅ Funcionalidades
- [ ] Criação de lojas
- [ ] Criação de administradores
- [ ] Registro de vendas
- [ ] Gestão de despesas
- [ ] Exportação Excel

## 🔧 Próximos Passos

### 1. Criar Primeira Loja
1. No painel SuperAdmin, clique em "Nova Loja"
2. Preencha os dados da loja
3. Crie o primeiro administrador

### 2. Testar Fluxo Completo
1. Faça login como administrador da loja
2. Crie alguns colaboradores
3. Registre algumas vendas
4. Teste a gestão de despesas

### 3. Personalizar
- Ajuste as taxas em `lib/utils.ts`
- Personalize cores em `tailwind.config.js`
- Adicione logo da empresa

## 🐛 Problemas Comuns

### Erro: "Cannot find module"
```bash
npm install
```

### Erro: "Supabase connection failed"
- Verifique o arquivo `.env.local`
- Confirme se as credenciais estão corretas

### Erro: "User not found"
- Verifique se o usuário foi criado no Auth
- Confirme se o registro na tabela `usuarios` está correto

### Erro: "Permission denied"
- Execute novamente o SQL de setup
- Verifique se as políticas RLS estão ativas

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs do console
2. Confirme se todos os passos foram seguidos
3. Verifique a documentação completa no `README.md`

---

**🎉 Parabéns! Seu SaaS Caixa está 100% funcional!** 