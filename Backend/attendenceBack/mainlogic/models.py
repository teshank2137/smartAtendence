from django.db import models
from django.contrib.auth.models import User
from datetime import date

# Create your models here.


class Organization(models.Model):
    title = models.CharField(max_length=200, null=False)
    hod = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    teachers = models.ManyToManyField(
        User, related_name='Teachers', blank=True)
    students = models.ManyToManyField(
        User, related_name='Students', blank=True)
    unique_code = models.SlugField(max_length=10, unique=True)
    teacher_code = models.SlugField(max_length=10, unique=True)

    def __str__(self):
        return self.title


class Classroom(models.Model):
    title = models.CharField(max_length=150, null=False)
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE)
    teacher = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    present_students = models.ManyToManyField(
        User, related_name='PresentStudents', blank=True)
    unique_code = models.SlugField(max_length=12, unique=True)
    expire_time = models.IntegerField(default=5)
    startTime = models.TimeField(auto_now_add=True)
    date = models.DateField(default=date.today)

    def __str__(self):
        return self.title


class Verification(models.Model):
    image = models.ImageField(upload_to='verify/faces')
    orgcode = models.SlugField(max_length=10)
    classcode = models.SlugField(max_length=10)

    def __str__(self):
        return self.classcode
