from django.shortcuts import render
from rest_framework import viewsets
from .models import Patient
from .serializer import PatientSerializer

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer

    def get_queryset(self):
        user = self.request.user

        if user.is_superuser or user.is_staff:
            return Patient.objects.all()

        return Patient.objects.filter(facility=user.facility)
    
    def perform_create(self, serializer):
        serializer.save(facility=self.request.user.facility)
