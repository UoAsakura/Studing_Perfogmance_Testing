#!/bin/bash

# Переходим в директорию, где расположен сам скрипт
cd "$(dirname "${BASH_SOURCE[0]}")"

# Создаем 24 папки.
for hour in {0..23}; do
  folder="dir_${hour}h"
  mkdir -p "$folder"
done

# Определяем текущий час и выбираем соответствующую папку.
current_hour=$(date +'%H')   # Получаем час в 24-часовом формате.
current_hour=$((10#$current_hour)) # Убираем ведущий ноль.
folder="dir_${current_hour}h"

# Переходим в нужную папку.
cd "$folder"

# Скачиваем 10+ изображений в текущую папку.
# Пример: скачиваем изображения с https://picsum.photos.
for i in {1..10}; do
  wget -q "https://picsum.photos/200/300?random=$i" -O "image_${i}.jpg"
done

# Возвращаемся в начальную директорию.
cd ..

# Проверка на конец суток: архивируем все папки, если текущий час — 0 (полночь).
if [ "$current_hour" -eq 00 ]; then
  tar -czf images_$(date +'%Y-%m-%d').tar.gz dir_*h
  echo "Архив all_images_$(date +'%Y-%m-%d').tar.gz создан."
fi
