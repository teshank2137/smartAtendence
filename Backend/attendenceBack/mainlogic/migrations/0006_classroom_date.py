# Generated by Django 3.1.1 on 2021-04-24 18:48

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('mainlogic', '0005_auto_20210424_2018'),
    ]

    operations = [
        migrations.AddField(
            model_name='classroom',
            name='date',
            field=models.DateField(default=datetime.date.today),
        ),
    ]
