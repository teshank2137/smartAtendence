# Generated by Django 3.1.1 on 2021-04-24 14:16

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('mainlogic', '0003_auto_20210424_1925'),
    ]

    operations = [
        migrations.AlterField(
            model_name='organization',
            name='hod',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterField(
            model_name='organization',
            name='students',
            field=models.ManyToManyField(related_name='Students', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AlterField(
            model_name='organization',
            name='teachers',
            field=models.ManyToManyField(related_name='Teachers', to=settings.AUTH_USER_MODEL),
        ),
    ]
