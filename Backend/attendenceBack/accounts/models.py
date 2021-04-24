from mainlogic.models import Organization
from django.db import models

from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token


# Create your models here.
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    joined_organizations = models.ManyToManyField(
        Organization, null=True, blank=True)
    is_teacher = models.BooleanField(default=False)
    is_hod = models.BooleanField(default=False)
    image1 = models.ImageField(blank=True, null=True, upload_to='faces')
    image2 = models.ImageField(blank=True, null=True, upload_to='faces')


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)
        Token.objects.create(user=instance)


@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()
