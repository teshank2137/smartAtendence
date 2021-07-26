from accounts.models import Profile
from rest_framework import serializers
from django.contrib.auth.models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def save(self):
        user = User(
            username=self.validated_data['username'],
            email=self.validated_data['email'],
        )
        user.set_password(self.validated_data['password'])
        user.save()
        return user


class ImageUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ['image1', 'image2']


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ['is_hod', 'is_teacher', 'user']
