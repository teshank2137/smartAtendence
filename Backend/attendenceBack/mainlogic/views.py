from accounts.models import Profile
from accounts import serializer
from django.contrib.auth.models import User
from mainlogic.serializer import CreateClassSerializer, CreateOrganizationSerializer, ShowOrganizationSerializer
from .models import Classroom, Organization
from django.shortcuts import render
from django.views import View
from rest_framework.views import APIView
import uuid
from rest_framework.response import Response
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt


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


@method_decorator(csrf_exempt, name='dispatch')
class CreateOrganizationView(APIView):
    def post(self, request):
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

        return Response(data)


# show oraganisations
class MyOrganizations(APIView):
    def get(self, request):
        orgs = Organization.objects.filter(hod=request.user)
        serializer = ShowOrganizationSerializer(orgs, many=True)
        return Response(serializer.data)

# Teachers join organization


class TeachersJoin(APIView):
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
class ShowClass(APIView):
    def get(self, request, code):
        org = Organization.objects.get(unique_code=code)
        classes = Classroom.objects.filter(organization=org)
        serializer = CreateClassSerializer(classes, many=True)
        return Response(serializer.data)


# Teachers create Classroom
class CreateClass(APIView):
    def post(self, request):
        code = request.data.pop("code")
        print("===>>>>", request)
        org = Organization.objects.get(unique_code=code)
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

        return Response(data)


# students mark present
# TODO face algorithm
class Present(APIView):
    def get(self, request, orgcode, classcode):
        user = request.user
        org = Organization.objects.get(unique_code=orgcode)
        students = org.students.all()
        data = {}
        data['response'] = "Student Marked Present"
        if user in students:
            cls = Classroom.objects.get(unique_code=classcode)
            if user not in cls.present_students.all():
                cls.present_students.add(user)
            else:
                data['response'] = "Student Already Marked Present"
        return Response(data)
