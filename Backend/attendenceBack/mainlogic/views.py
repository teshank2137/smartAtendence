from accounts.models import Profile
from accounts import serializer
from django.contrib.auth.models import User
from mainlogic.serializer import CreateClassSerializer, CreateOrganizationSerializer, MarkPresentSerializer, PresentSerializer, ShowOrganizationSerializer, StudentOganizationViewSerializer, ViewClassSerializer, studentViewSerializer
from .models import Classroom, Organization
from django.shortcuts import render
from django.views import View
from rest_framework.views import APIView
import uuid
from rest_framework.response import Response
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
import face_recognition
from itertools import chain

from django.conf import settings


from rest_framework.authentication import TokenAuthentication


def codes():
    orgs = Organization.objects.all()
    orgs_code = [org.unique_code for org in orgs]
    orgs_Tcode = [org.teacher_code for org in orgs]
    code = uuid.uuid4().hex[:6]
    while code in orgs_code:
        code = uuid.uuid4().hex[:6]
        # code = uuid.uuid4().hex[:6]
    Tcode = uuid.uuid4().hex[:6]
    while Tcode in orgs_Tcode or Tcode == code:
        Tcode = uuid.uuid4().hex[:6]
    return code, Tcode
# Create your views here.
# create organization

# require title


@method_decorator(csrf_exempt, name='dispatch')
class CreateOrganizationView(APIView):
    authentication_classes = [TokenAuthentication]

    def post(self, request):
        prof = Profile.objects.get(user=request.user)
        if prof.is_hod == False:
            return Response({'response': 'Unauthorized'})
        code, Tcode = codes()
        obj = Organization(
            hod=request.user,
            unique_code=code,
            teacher_code=Tcode
        )

        serializer = CreateOrganizationSerializer(obj, data=request.data)
        data = {}
        data['response'] = "error"
        if serializer.is_valid():
            obj = serializer.save()
            data['response'] = 'SUCESS'
            data['title'] = obj.title
            data['unique_code'] = obj.unique_code
            data['teacher_code'] = obj.teacher_code
            obj2 = Organization.objects.get(teacher_code=Tcode)
            obj2.teachers.add(request.user)
            obj2.save()

        return Response(data)


class isHod(APIView):
    authentication_classes = [TokenAuthentication]

    def get(self, request, code):
        org = Organization.objects.filter(
            unique_code=code).filter(hod=request.user)
        if len(org) > 0:
            return Response({'response': True, 'teacher_code': org[0].teacher_code})
        else:
            return Response({'response': False})

# show oraganisations


class MyOrganizations(APIView):
    authentication_classes = [TokenAuthentication]

    def get(self, request):
        orgs = Organization.objects.filter(hod=request.user)
        serializer = ShowOrganizationSerializer(orgs, many=True)
        return Response(serializer.data)


# Joined Organization View
class JoinedOrganizationView(APIView):
    authentication_classes = [TokenAuthentication]

    def get(self, request):
        usr_prof = Profile.objects.get(user=request.user)
        orgs = usr_prof.joined_organizations.all()
        orgs2 = Organization.objects.filter(hod=request.user)
        orgs = chain(orgs, orgs2)
        serializer = StudentOganizationViewSerializer(orgs, many=True)
        return Response(serializer.data)


# Teachers join organization
class TeachersJoin(APIView):
    authentication_classes = [TokenAuthentication]

    def get(self, request, code):
        data = {}
        try:
            obj = Organization.objects.get(teacher_code=code)
            obj.teachers.add(request.user)
            usr = Profile.objects.get(user=request.user)
            usr.is_teacher = True
            usr.joined_organizations.add(obj)
            obj.save()
            usr.save()
            data['response'] = 'Sucess'
            data['hod'] = obj.hod.username
            data['Org'] = obj.title
            data['student_code'] = obj.unique_code
        except:
            data['response'] = 'Invalid Code'
        return Response(data)


# Students join organization
class StudentsJoin(APIView):
    authentication_classes = [TokenAuthentication]

    def get(self, request, code):
        data = {}
        try:
            obj = Organization.objects.get(unique_code=code)
            obj.students.add(request.user)
            usr = Profile.objects.get(user=request.user)
            usr.joined_organizations.add(obj)
            obj.save()
            usr.save()
            data['response'] = 'Sucess'
            data['Org'] = obj.title
        except:
            data['response'] = 'Invalid Code'
        return Response(data)


# show classrooms under organization
# Organization DetailView
class ShowClass(APIView):
    authentication_classes = [TokenAuthentication]

    def get(self, request, code):
        org = Organization.objects.get(unique_code=code)
        classes = Classroom.objects.filter(organization=org)
        serializer = ViewClassSerializer(classes, many=True)
        return Response(serializer.data)


# Teachers create Classroom
#
class CreateClass(APIView):
    authentication_classes = [TokenAuthentication]

    def post(self, request):
        code = request.data["code"]
        print("===>>>>", request)
        org = Organization.objects.get(unique_code=code)
        teachers = org.teachers.all()
        if request.user not in teachers:
            return Response({'response': 'unauthorized'})
        codes = Classroom.objects.filter(organization=org)
        codes = [cls.unique_code for cls in codes]
        thiscode = uuid.uuid4().hex[:5]
        while thiscode in codes:
            thiscode = uuid.uuid4().hex[:5]

        obj = Classroom(
            teacher=request.user,
            organization=org,
            unique_code=thiscode
        )
        serializer = CreateClassSerializer(obj, data=request.data)
        data = {}
        data['response'] = "Invalid Code"
        if serializer.is_valid():
            obj = serializer.save()
            data['title'] = obj.title
            data['unique_code'] = obj.unique_code
            data['time'] = obj.startTime
            data['response'] = "Sucess"

        return Response(data)


# students mark present
class Present(APIView):
    authentication_classes = [TokenAuthentication]

    def post(self, request):
        data = {}
        serializer = MarkPresentSerializer(data=request.data)
        if serializer.is_valid():
            obj = serializer.save()
            orgcode = obj.orgcode
            classcode = obj.classcode
            unImage = obj.image.path
            user = request.user
            org = Organization.objects.get(unique_code=orgcode)
            students = org.students.all()
            data['response'] = "Student doesn't belong to this organization"
            if user in students:
                prof = Profile.objects.get(user=user)
                # get classroom
                try:
                    cls = Classroom.objects.get(unique_code=classcode)
                except:
                    data['response'] = 'Invalid Code'
                    return Response(data)

                # get Images
                try:
                    image1 = prof.image1.path
                    image2 = prof.image2.path
                except:
                    data['response'] = 'Facial Recognition Not Set'
                    return Response(data)

                # Facial Authentication
                known_1 = face_recognition.load_image_file(image1)
                known_2 = face_recognition.load_image_file(image2)
                unknown = face_recognition.load_image_file(unImage)

                encoded1 = face_recognition.face_encodings(known_1)[0]
                encoded2 = face_recognition.face_encodings(known_2)[0]
                unknown_encoding = face_recognition.face_encodings(unknown)[0]
                results = face_recognition.compare_faces(
                    [encoded1, encoded2], unknown_encoding)
                if True not in results:
                    data['response'] = 'Facial Recognition Failed'
                    return Response(data)

                if user not in cls.present_students.all():
                    cls.present_students.add(user)
                    data['response'] = "Student Marked Present"
                else:
                    data['response'] = "Student Already Marked Present"
        print(data)
        return Response(data)


class DetailClassView(APIView):
    authentication_classes = [TokenAuthentication]

    def post(self, request):
        orgcode = request.data['orgcode']
        classcode = request.data['classcode']
        org = Organization.objects.get(unique_code=orgcode)
        if request.user in org.teachers.all():
            cls = Classroom.objects.get(unique_code=classcode)
            students = cls.present_students.all()
            serializer = studentViewSerializer(students, many=True)
            return Response(serializer.data)
        return Response({'response': 'Not Authorized'})
