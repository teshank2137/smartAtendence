from django.contrib.auth.models import User
from rest_framework import serializers
from .models import Organization, Classroom, Verification
import uuid


class CreateOrganizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Organization
        fields = ['title']


class ShowOrganizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Organization
        fields = ['title', 'unique_code', 'teacher_code']


class StudentOganizationViewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Organization
        fields = ['title', 'unique_code']


class CreateClassSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classroom
        fields = ['title']


class ViewClassSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classroom
        fields = ['title', 'unique_code', 'date',
                  'startTime', 'present_students']


class PresentSerializer(serializers.Serializer):
    orgcode = serializers.SlugField()
    classcode = serializers.SlugField()
    image = serializers.ImageField()


class studentViewSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email']


class MarkPresentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Verification
        fields = ['image', 'orgcode', 'classcode']
