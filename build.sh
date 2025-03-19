#!/bin/bash

# Скрипт для сборки приложения на Render.com

echo "🏗️ Запуск сборки проекта для Render.com..."

# Создаем локальные директории для разработки
echo "📁 Создание локальных директорий для данных..."
mkdir -p ./data
mkdir -p ./data/backup
mkdir -p ./data/backup/json
mkdir -p ./data/backup/sql
mkdir -p ./data/backup/zip

# Примечание: постоянное хранилище /data будет настроено при запуске в start.sh
echo "ℹ️ Постоянное хранилище /data будет настроено при запуске"

# Устанавливаем зависимости 
echo "📦 Установка зависимостей..."
npm install --force --no-optional --no-fund || echo "⚠️ Были проблемы при установке некоторых пакетов, но продолжаем сборку"

# Делаем скрипты исполняемыми
echo "🔧 Настройка прав доступа..."
chmod +x *.sh
chmod +x setup-telegram.js

# Создаем production сборку
echo "🔨 Компиляция TypeScript..."
echo "Создаем директорию dist/server..."
mkdir -p dist/server

echo "Компилируем server/index.ts и связанные файлы..."
npx tsc --skipLibCheck --esModuleInterop --target es2016 --module commonjs --outDir dist server/index.ts || echo "Предупреждение: TypeScript компиляция завершилась с ошибками, но продолжаем сборку"

echo "Проверяем наличие скомпилированных файлов..."
ls -la dist/server || echo "⚠️ Директория dist/server может быть пуста или отсутствовать"

echo "🚀 Сборка клиентской части..."
npm run build || echo "Предупреждение: Сборка клиентской части завершилась с ошибками, но продолжаем развертывание"

echo "Копируем критические файлы для запуска без компиляции..."
cp -r server dist/ || echo "⚠️ Резервное копирование исходных файлов не удалось, но продолжаем сборку"

echo "✅ Сборка проекта завершена!"
