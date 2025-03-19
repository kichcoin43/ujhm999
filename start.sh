#!/bin/bash

# Скрипт для запуска приложения на Render.com

echo "🚀 Запуск приложения на Render.com..."

# Проверяем наличие директории для данных
echo "🔍 Проверка доступности директории /data..."
if [ -d "/data" ] && [ -w "/data" ]; then
  echo "✅ Директория /data найдена и доступна для записи"
  
  # Создаем подкаталоги в /data если их нет
  mkdir -p /data/backup
  mkdir -p /data/backup/json
  mkdir -p /data/backup/sql
  mkdir -p /data/backup/zip
  
  # Используем /data как основную директорию для данных
  export DATA_DIR="/data"
else
  echo "⚠️ Директория /data не найдена или недоступна для записи"
  echo "ℹ️ Используем локальную директорию ./data вместо /data"
  
  # Создаем локальные директории для данных
  mkdir -p ./data
  mkdir -p ./data/backup
  mkdir -p ./data/backup/json
  mkdir -p ./data/backup/sql
  mkdir -p ./data/backup/zip
  
  # Используем локальную директорию для данных
  export DATA_DIR="./data"
fi

echo "📂 Используется директория для данных: $DATA_DIR"

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
export DATABASE_PATH="$DATA_DIR/sqlite.db"

# Проверяем наличие базы данных
if [ ! -f "$DATA_DIR/sqlite.db" ]; then
  echo "📝 База данных не найдена, создаем новую..."
  touch "$DATA_DIR/sqlite.db" || echo "⚠️ Не удалось создать базу данных, проверьте права доступа"
fi

# Если есть локальная база данных, копируем её в постоянное хранилище
if [ -f "./sqlite.db" ] && [ ! -s "$DATA_DIR/sqlite.db" ]; then
  echo "🔄 Копирование локальной базы данных в хранилище $DATA_DIR..."
  cp ./sqlite.db "$DATA_DIR/sqlite.db" || echo "⚠️ Ошибка копирования"
elif [ -f "$DATA_DIR/sqlite.db" ] && [ ! -f "./sqlite.db" ]; then
  echo "🔄 Копирование базы данных из хранилища в локальную..."
  cp "$DATA_DIR/sqlite.db" ./sqlite.db || echo "⚠️ Ошибка копирования"
fi

# Создаем резервную копию базы данных
DATE=$(date +"%Y%m%d_%H%M%S")
if [ -f "$DATA_DIR/sqlite.db" ]; then
  echo "💾 Создание резервной копии базы данных..."
  cp "$DATA_DIR/sqlite.db" "$DATA_DIR/backup/sqlite_$DATE.db" || echo "⚠️ Не удалось создать резервную копию"
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
