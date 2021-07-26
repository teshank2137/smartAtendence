from mainlogic.views import CreateClass, CreateOrganizationView, DetailClassView, JoinedOrganizationView, MyOrganizations, Present, ShowClass, StudentsJoin, TeachersJoin, isHod
from django.urls import path

urlpatterns = [
    # path('api/',)
    path('createorg/', CreateOrganizationView.as_view(), name="createOrganization"),
    path('myorgs/', MyOrganizations.as_view(), name="createdOrgs"),
    path('allmyorgs/', JoinedOrganizationView.as_view(), name="allmyOrgs"),
    path('tjoin/<slug:code>/', TeachersJoin.as_view(), name="teacherJoin"),
    path('sjoin/<slug:code>/', StudentsJoin.as_view(), name="studentJoin"),
    path('listclass/<slug:code>/', ShowClass.as_view(), name="classListView"),
    path('createclass/', CreateClass.as_view(), name="createClass"),
    path('markpresent/', Present.as_view(), name="present"),
    path('classdetail/', DetailClassView.as_view(), name="presentStudents"),
    path('ishod/<slug:code>/', isHod.as_view(), name='isHodChecker'),
]
