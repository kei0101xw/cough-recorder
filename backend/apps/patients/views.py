from rest_framework import viewsets
from .models import Patient
from .serializers import PatientSerializer
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status

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
    
    def destroy(self, request, *args, **kwargs):
        if not request.user.is_superuser and not request.user.is_staff:
            return Response({"detail": "削除は禁止されています"}, status=status.HTTP_403_FORBIDDEN)
        
        return super().destroy(request, *args, **kwargs)

    # TODO: adminユーザーがデータを取得する際に複数患者データが取れる問題を修正する
    @action(detail = False, methods=['get'], url_path='search')
    def search_by_patient_code(self, request):
        patient_code = request.query_params.get("patient_code", None)

        if patient_code is None:
            return Response(
                {"detail": "patient_code is required."},
                status = status.HTTP_400_BAD_REQUEST
            )
        
        patient = self.get_queryset().filter(patient_code = patient_code).first()

        if patient is None:
            return Response(
                {"detail": "Patient not found."},
                status = status.HTTP_404_NOT_FOUND
            )
        
        serializer: PatientSerializer = self.get_serializer(patient)
        return Response(serializer.data)
