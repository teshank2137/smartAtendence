from django.shortcuts import redirect, render
from django.views import View
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth import login, logout
from django.http import HttpResponse

from rest_framework.views import APIView
from rest_framework.response import Response
from .serializer import UserSerializer
from rest_framework.authtoken.models import Token

from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
# Create your views here.
# Sign Up


@method_decorator(csrf_exempt, name='dispatch')
class SignUp(APIView):
    # def get(self, request):

    #     form = UserCreationForm()
    #     return HttpResponse(form)

    def post(self, request):
        # form = UserCreationForm(request.POST)
        serializer = UserSerializer(data=request.data)
        data = {}
        if serializer.is_valid():
            user = serializer.save()
            login(request, user)
            # return redirect('list:home')
            data["response"] = "sucess"
            data["username"] = user.username
            data["email"] = user.email
            data['token'] = Token.objects.get(user=user).key
        return Response(data)

# todo face registeration

# Login
# class user_login(APIView):
#     # def get(self, request):
#     #     form = AuthenticationForm()
#     #     return render(request, 'accounts/login.html', {'form': form})

#     def post(self, request):
#         # form = AuthenticationForm(data=request.POST)
#         serializer = UserSerializer(data=request.data)
#         if form.is_valid():
#             user = form.get_user()
#             login(request, user)
#             # return redirect('list:home')
#         return


# Logout

class user_logout(APIView):
    def post(self, request):
        data = {}
        try:
            logout(request)
            data['response'] = "sucess"
        except:
            data['response'] = "error"

        return Response(data)


class Me(APIView):
    def get(self, request):
        usr = request.user
        return Response(UserSerializer(usr).data)
