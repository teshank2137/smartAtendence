# Generated by Django 3.1.1 on 2021-04-25 16:40

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('mainlogic', '0006_classroom_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='organization',
            name='hod',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL),
        ),
    ]
