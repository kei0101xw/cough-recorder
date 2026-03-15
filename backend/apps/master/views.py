from rest_framework import viewsets
from .models import Condition
from .serializers import ConditionSerializer
from .models import Symptom
from .serializers import SymptomSerializer
from .models import Dementia
from .serializers import DementiaSerializer

class ConditionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Condition.objects.all()
    serializer_class = ConditionSerializer

class SymptomViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Symptom.objects.all()
    serializer_class = SymptomSerializer

class DementiaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Dementia.objects.all()
    serializer_class = DementiaSerializer
