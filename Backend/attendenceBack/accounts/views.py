from accounts.models import Profile
from django.contrib.auth import login, logout

from rest_framework.views import APIView
from rest_framework.response import Response
from .serializer import ImageUserSerializer, ProfileSerializer, UserSerializer
from rest_framework.authtoken.models import Token
from rest_framework.authentication import TokenAuthentication

from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from rest_framework.permissions import AllowAny
from rest_framework.decorators import permission_classes
import face_recognition
# Create your views here.
# Sign Up


@method_decorator(csrf_exempt, name='dispatch')
@permission_classes((AllowAny, ))
class SignUp(APIView):
    authentication_classes = [TokenAuthentication]
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
            data["response"] = "success"
            data["username"] = user.username
            data["email"] = user.email
            data['token'] = Token.objects.get(user=user).key
        return Response(data)


class FaceRegistration(APIView):
    authentication_classes = [TokenAuthentication]

    def post(self, request):
        user = request.user
        prof = Profile.objects.get(user=user)
        serializer = ImageUserSerializer(prof, data=request.data)
        if serializer.is_valid():
            obj = serializer.save()
            image1 = obj.image1.path
            image2 = obj.image2.path
            try:
                known_1 = face_recognition.load_image_file(image1)
                known_2 = face_recognition.load_image_file(image2)

                encoded1 = face_recognition.face_encodings(known_1)[0]
                encoded2 = face_recognition.face_encodings(known_2)[0]
                print('done')
                return Response({"response": "success"})
            except:
                print('fail')
                return Response({"response": "Bad Picture"})
        print('Bad fail')
        return Response({"response": "error"})


# Logout
@method_decorator(csrf_exempt, name='dispatch')
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
    authentication_classes = [TokenAuthentication]

    def get(self, request):
        usr = request.user
        prof = Profile.objects.get(user=usr)
        return Response(ProfileSerializer(prof).data)
