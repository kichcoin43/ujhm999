#!/bin/bash

# Скрипт для запуска приложения на Render.com

echo "🚀 Запуск приложения на Render.com..."

# Проверяем наличие директории для данных
if [ ! -d "/data" ]; then
  echo "⚠️ Директория /data не найдена. Создаем..."
  mkdir -p /data
  mkdir -p /data/backup
fi

# Проверяем наличие переменных окружения
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "⚠️ Предупреждение: TELEGRAM_BOT_TOKEN не задан, функциональность Telegram бота будет ограничена"
fi

if [ -z "$RENDER_EXTERNAL_URL" ] && [ -z "$WEBAPP_URL" ]; then
  echo "⚠️ Предупреждение: URL приложения не задан, некоторые функции могут работать некорректно"
  export WEBAPP_URL="http://localhost:3000"
else
  if [ -n "$RENDER_EXTERNAL_URL" ]; then
    export WEBAPP_URL="$RENDER_EXTERNAL_URL"
  fi
fi

# Устанавливаем переменные окружения
export NODE_ENV=production
export RENDER=true
export DATABASE_PATH=/data/sqlite.db

# Проверяем наличие базы данных
if [ ! -f "/data/sqlite.db" ]; then
  echo "📝 База данных не найдена, создаем новую..."
  touch /data/sqlite.db
fi

# Если есть локальная база данных, копируем её в постоянное хранилище
if [ -f "./sqlite.db" ] && [ ! -s "/data/sqlite.db" ]; then
  echo "🔄 Копирование локальной базы данных в постоянное хранилище..."
  cp ./sqlite.db /data/sqlite.db
elif [ -f "/data/sqlite.db" ] && [ ! -f "./sqlite.db" ]; then
  echo "🔄 Копирование базы данных из постоянного хранилища в локальную..."
  cp /data/sqlite.db ./sqlite.db
fi

# Создаем резервную копию базы данных
DATE=$(date +"%Y%m%d_%H%M%S")
if [ -f "/data/sqlite.db" ]; then
  echo "💾 Создание резервной копии базы данных..."
  cp /data/sqlite.db "/data/backup/sqlite_$DATE.db" || echo "⚠️ Не удалось создать резервную копию"
fi

# Обновляем права на скрипты
chmod +x setup-telegram.js || echo "⚠️ Не удалось обновить права на setup-telegram.js"

# Настраиваем Telegram бота
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$WEBAPP_URL" ]; then
  echo "🤖 Настройка Telegram бота..."
  node setup-telegram.js || echo "⚠️ Не удалось настроить Telegram бота"
else
  echo "⚠️ Пропускаем настройку Telegram бота из-за отсутствия необходимых переменных окружения"
fi

# Запускаем приложение
echo "🌐 Запуск веб-сервера..."
node dist/server/index.js || node server/index.js
