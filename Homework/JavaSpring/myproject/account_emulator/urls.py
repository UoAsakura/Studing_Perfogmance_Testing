from django.urls import path
from .views import account_info

urlpatterns = [
    path('api/account-info/', account_info, name='account_info'),
]

