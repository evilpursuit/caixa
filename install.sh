#!/bin/bash

echo "🚀 Instalando SaaS Caixa..."

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale o Node.js 18+ primeiro."
    exit 1
fi

# Verificar versão do Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js 18+ é necessário. Versão atual: $(node -v)"
    exit 1
fi

echo "✅ Node.js $(node -v) encontrado"

# Instalar dependências
echo "📦 Instalando dependências..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências"
    exit 1
fi

echo "✅ Dependências instaladas"

# Criar arquivo .env.local se não existir
if [ ! -f .env.local ]; then
    echo "🔧 Criando arquivo .env.local..."
    cat > .env.local << EOF
NEXT_PUBLIC_SUPABASE_URL=https://ydorrxsfwxymhlchonvp.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlkb3JyeHNmd3h5bWhsY2hvbnZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MDgxNzIsImV4cCI6MjA2NjE4NDE3Mn0.rG89FPc7_gXYjRU16ySgggxkGeQWjACL7caSvDTNg5Y
EOF
    echo "✅ Arquivo .env.local criado"
else
    echo "✅ Arquivo .env.local já existe"
fi

echo ""
echo "🎉 Instalação concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Execute o SQL do arquivo 'supabase-setup.sql' no Supabase"
echo "2. Crie um usuário SuperAdmin seguindo o guia em 'setup.md'"
echo "3. Execute 'npm run dev' para iniciar o projeto"
echo ""
echo "📖 Consulte o arquivo 'setup.md' para instruções detalhadas"
echo "📖 Consulte o arquivo 'README.md' para documentação completa" 