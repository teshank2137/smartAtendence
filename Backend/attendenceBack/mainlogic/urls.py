from mainlogic.views import CreateClass, CreateOrganizationView, MyOrganizations, Present, ShowClass, StudentsJoin, TeachersJoin
from django.urls import path

urlpatterns = [
    # path('api/',)
    path('createorg/', CreateOrganizationView.as_view(), name="createOrganization"),
    path('myorgs/', MyOrganizations.as_view(), name="myOrgs"),
    path('tjoin/<slug:code>', TeachersJoin.as_view(), name="teacherJoin"),
    path('sjoin/<slug:code>', StudentsJoin.as_view(), name="studentJoin"),
    path('listclass/<slug:code>', ShowClass.as_view(), name="classListView"),
    path('createclass/', CreateClass.as_view(), name="createClass"),
    path('markpresent/<slug:orgcode>/<slug:classcode>',
         Present.as_view(), name="present"),
]
