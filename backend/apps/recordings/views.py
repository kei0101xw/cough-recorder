from rest_framework import viewsets
from .models import Recording
from .serializers import RecordingSerializer

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