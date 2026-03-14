from rest_framework import serializers
from .models import Patient

class PatientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patient
        fields = [
            "id",
            "research_id",
            "patient_code",
            "biological_sex",
            "birth_date",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']