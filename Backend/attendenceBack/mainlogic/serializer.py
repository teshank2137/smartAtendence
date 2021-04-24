from rest_framework import serializers
from .models import Organization, Classroom
import uuid


class CreateOrganizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Organization
        fields = ['title']


class ShowOrganizationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Organization
        fields = ['title', 'unique_code', 'teacher_code']


class CreateClassSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classroom
        fields = ['title']
