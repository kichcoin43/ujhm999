#!/bin/bash

# Скрипт для запуска приложения на Render.com

echo "🚀 Запуск приложения на Render.com..."

# Проверяем наличие переменных окружения
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "⚠️ Предупреждение: TELEGRAM_BOT_TOKEN не задан, функциональность Telegram бота будет ограничена"
fi

if [ -z "$RENDER_EXTERNAL_URL" ]; then
  echo "⚠️ Предупреждение: RENDER_EXTERNAL_URL не задан, некоторые функции могут работать некорректно"
fi

# Устанавливаем переменные окружения
export NODE_ENV=production
export RENDER=true
export DATABASE_PATH=/data/sqlite.db

# Проверяем наличие базы данных
if [ ! -f "/data/sqlite.db" ]; then
  echo "📝 База данных не найдена, создаем новую..."
fi

# Обновляем права на скрипты
chmod +x setup-telegram.js

# Настраиваем Telegram бота
echo "🤖 Настройка Telegram бота..."
node setup-telegram.js

# Запускаем приложение
echo "🌐 Запуск веб-сервера..."
node dist/server/index.js