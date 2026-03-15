from rest_framework import serializers
from .models import Condition
from .models import Symptom
from .models import Dementia

class ConditionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Condition
        fields = ['id', 'name']

class SymptomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Symptom
        fields = ['id', 'name']

class DementiaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dementia
        fields = ['id', 'name']
