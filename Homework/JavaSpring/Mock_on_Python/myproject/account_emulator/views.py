from django.shortcuts import render

# Create your views here.

import datetime
import json
import random
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def account_info(request):
    if request.method == "POST":
        # Получаем JSON-данные из запроса
        data = json.loads(request.body)
        # Вычисляем дату запроса
        now = datetime.datetime.now()
        # Выводим лог в консоль
        print(f"\n{now}          ****** Reuqest ******\n")
        for k, v in data.items():
            print(f"{k} : {v}")
        print()
        
        # Извлекаем необходимые параметры
        rqUID = data.get("rqUID")
        clientId = data.get("clientId")
        account = data.get("account")

        # Определяем валюту и максимальный лимит
        if clientId.startswith("8"):
            currency = "US"
            max_limit = 2000.00
        elif clientId.startswith("9"):
            currency = "EU"
            max_limit = 1000.00
        else:
            currency = "RUB"
            max_limit = 10000.00

        # Генерируем баланс случайным числом до максимального лимита
        balance = round(random.uniform(0, max_limit), 2)

        # Формируем ответ
        response_data = {
            "rqUID": rqUID,
            "clientId": clientId,
            "account": account,
            "currency": currency,
            "balance": f"{balance:.2f}",
            "maxLimit": f"{max_limit:.2f}"
        }
            
        # Вычисляем дату ответа
        now = datetime.datetime.now()
        # Выводим лог в консоль
        print(f"\n{now}          ****** Response ******\n")
        for k, v in response_data.items():
            print(f"{k} : {v}")
        print()
            
            
        # Возвращаем JSON-ответ
        return JsonResponse(response_data)

    # Если метод запроса не POST, возвращаем ошибку
    return JsonResponse({"error": "Only POST requests are allowed"}, status=405)
