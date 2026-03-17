from rest_framework import serializers
from .models import Recording, RecordingCondition, RecordingSymptom
from apps.patients.serializers import PatientSerializer
from apps.patients.models import Patient
from django.db import transaction


class RecordingConditionSerializer(serializers.ModelSerializer):
    condition_name = serializers.CharField(source='condition.name', read_only=True)

    class Meta:
        model = RecordingCondition
        fields = ['id', 'condition', 'condition_name', 'other_condition']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate(self, attrs):
        condition = attrs.get('condition')

        if condition is None:
            return attrs
        
        other_condition = attrs.get('other_condition')
        if other_condition:
            other_condition = other_condition.strip()
        attrs['other_condition'] = other_condition

        if condition.name == "その他" and not other_condition:
            raise serializers.ValidationError({
                'other_condition': "condition が『その他』のときは入力が必須です。"
            })

        if condition.name != "その他" and other_condition:
            raise serializers.ValidationError({
                'other_condition': "condition が『その他』以外のときは入力できません。"
            })
        
        attrs['other_condition'] = other_condition

        return attrs


class RecordingSymptomSerializer(serializers.ModelSerializer):
    symptom_name = serializers.CharField(source='symptom.name', read_only=True)

    class Meta:
        model = RecordingSymptom
        fields = ['id', 'symptom', 'symptom_name', 'other_symptom']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate(self, attrs):
        symptom = attrs.get('symptom')

        if symptom is None:
            return attrs
        
        other_symptom = attrs.get('other_symptom')
        if other_symptom:
            other_symptom = other_symptom.strip()
        attrs['other_symptom'] = other_symptom

        if symptom.name == "その他" and not other_symptom:
            raise serializers.ValidationError({
                'other_symptom': "symptom が『その他』のときは入力が必須です。"
            })

        if symptom.name != "その他" and other_symptom:
            raise serializers.ValidationError({
                'other_symptom': "symptom が『その他』以外のときは入力できません。"
            })
        
        attrs['other_symptom'] = other_symptom

        return attrs


class RecordingSerializer(serializers.ModelSerializer):
    patient = serializers.PrimaryKeyRelatedField(queryset=Patient.objects.all())
    patient_detail = PatientSerializer(source='patient', read_only=True)
    conditions = RecordingConditionSerializer(many=True, source='recording_conditions')
    symptoms = RecordingSymptomSerializer(many=True, source='recording_symptoms')
    dementia_name = serializers.CharField(source='dementia.name', read_only=True)

    class Meta:
        model = Recording
        fields = [
            'id',
            'user',
            'patient',
            'patient_detail',
            'conditions',
            'symptoms',
            'dementia',
            'dementia_name',
            'audio_url',
            'status',
            'recorded_at',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']

    def validate_patient(self, patient):
        user = self.context['request'].user

        if user.is_superuser or user.is_staff:
            return patient

        if patient.facility != user.facility:
            raise serializers.ValidationError("患者はユーザーと同じ施設に所属している必要があります。")

        return patient
    
    @transaction.atomic
    def create(self, validated_data):
        conditions_data = validated_data.pop('recording_conditions', [])
        symptoms_data = validated_data.pop('recording_symptoms', [])

        recording = Recording.objects.create(**validated_data)

        for condition_data in conditions_data:
            RecordingCondition.objects.create(
                recording=recording,
                **condition_data
            )

        for symptom_data in symptoms_data:
            RecordingSymptom.objects.create(
                recording=recording,
                **symptom_data
            )

        return recording
    
    @transaction.atomic
    def update(self, instance, validated_data):
        condition_data = validated_data.pop('recording_conditions', None)
        symptom_data = validated_data.pop('recording_symptoms', None)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if condition_data is not None:
            instance.recording_conditions.all().delete()
            for condition in condition_data:
                RecordingCondition.objects.create(
                    recording=instance,
                    **condition
                )
        
        if symptom_data is not None:
            instance.recording_symptoms.all().delete()
            for symptom in symptom_data:
                RecordingSymptom.objects.create(
                    recording=instance,
                    **symptom
                )
        
        return instance