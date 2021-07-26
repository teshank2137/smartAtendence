from accounts.views import SignUp
from django.urls import path
from .views import FaceRegistration, Me, SignUp,  user_logout
from rest_framework.authtoken.views import obtain_auth_token
from django.views.decorators.csrf import csrf_exempt

APP_NAME = 'accounts'
urlpatterns = [
    path('signup/', SignUp.as_view(), name='signup'),
    path('login', csrf_exempt(obtain_auth_token), name='login'),
    path('logout/', user_logout.as_view(), name='logout'),
    path('me/', Me.as_view(), name="me"),
    path('facereg/', FaceRegistration.as_view(), name="faceReg")
]
