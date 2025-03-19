#!/bin/bash

# Скрипт для сборки приложения на Render.com

echo "🏗️ Запуск сборки проекта для Render.com..."

# Создаем директории для хранения данных и резервных копий
echo "📁 Создание директорий для данных..."
mkdir -p /data
mkdir -p /data/backup
mkdir -p /data/backup/json
mkdir -p /data/backup/sql
mkdir -p /data/backup/zip

# Проверяем наличие базы данных
if [ ! -f "/data/sqlite.db" ]; then
  echo "🔄 База данных не найдена, будет создана новая..."
else
  echo "✅ База данных найдена: /data/sqlite.db"
fi

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
npm install

# Создаем production сборку
echo "🔨 Компиляция TypeScript..."
npx tsc

echo "🚀 Сборка клиентской части..."
npm run build

echo "✅ Сборка проекта завершена!"