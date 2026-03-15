from django.shortcuts import render
from rest_framework import viewsets
from .models import Facility
from .serializers import FacilitySerializer

class FacilityViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Facility.objects.all()
    serializer_class = FacilitySerializer