from rest_framework import viewsets
from .models import Recording
from .serializers import RecordingSerializer
from rest_framework.response import Response
from rest_framework import status

class RecordingViewSet(viewsets.ModelViewSet):
    queryset = Recording.objects.all()
    serializer_class = RecordingSerializer

    def get_queryset(self):
        user = self.request.user

        if user.is_superuser or user.is_staff:
            return Recording.objects.all()

        return Recording.objects.filter(patient__facility=user.facility)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def destroy(self, request, *args, **kwargs):
        if not request.user.is_superuser and not request.user.is_staff:
            return Response({"detail": "削除は禁止されています"}, status=status.HTTP_403_FORBIDDEN)
        
        return super().destroy(request, *args, **kwargs)