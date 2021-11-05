# Generated by Django 3.1.1 on 2021-04-23 02:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='profile',
            name='image1',
            field=models.ImageField(blank=True, null=True, upload_to='faces'),
        ),
        migrations.AddField(
            model_name='profile',
            name='image2',
            field=models.ImageField(blank=True, null=True, upload_to='faces'),
        ),
        migrations.AlterField(
            model_name='profile',
            name='id',
            field=models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID'),
        ),
    ]