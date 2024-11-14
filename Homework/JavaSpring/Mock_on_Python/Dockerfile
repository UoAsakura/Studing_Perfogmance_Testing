# Основа для нашего имаджа.
FROM python:3.9-alpine3.16
# Копируем наш файл с зависимостями.
COPY requirements.txt /temp/requirements.txt
# Копируем директорию с нашим приложением.
COPY myproject /myproject
# Рабочая директория в которой будут запускаться команды, которые мы передаём внутри контейнера.
WORKDIR /myproject
# Открываем порт.
EXPOSE 8000
# Устанавливаем зависимости.
RUN pip install -r /temp/requirements.txt
# Создаст пользователя в операционной системе ()без пароля).
RUN adduser --disabled-password service-user
# Пользователь под которым мы будем запускать все программы.
USER service-user
