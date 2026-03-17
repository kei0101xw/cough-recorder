from django.db import models
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

from apps.accounts.models import CustomUser
from apps.patients.models import Patient
from apps.master.models import Condition, Symptom, Dementia


class Recording(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", _("送信前")
        SENDING = "sending", _("送信中")
        SUCCESS = "success", _("送信成功")
        FAILED = "failed", _("送信失敗")

    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    dementia = models.ForeignKey(Dementia, on_delete=models.CASCADE)
    audio_url = models.URLField()
    status = models.CharField(max_length=20, choices=Status.choices)
    recorded_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Recording: {self.patient} - {self.recorded_at}"


class RecordingCondition(models.Model):
    recording = models.ForeignKey(Recording, on_delete=models.CASCADE, related_name='recording_conditions')
    condition = models.ForeignKey(Condition, on_delete=models.CASCADE)
    other_condition = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['recording', 'condition'], name='unique_recording_condition'),
        ]

    def clean(self):
        if self.condition.name != "その他" and self.other_condition:
            raise ValidationError("other_condition should be empty when condition is not 'その他'")
        if self.condition.name == "その他" and not self.other_condition:
            raise ValidationError("other_condition should be filled when condition is 'その他'")
    
    def __str__(self):
        return f"RecordingCondition: {self.recording} - {self.condition}"
    


class RecordingSymptom(models.Model):
    recording = models.ForeignKey(Recording, on_delete=models.CASCADE, related_name='recording_symptoms')
    symptom = models.ForeignKey(Symptom, on_delete=models.CASCADE)
    other_symptom = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['recording', 'symptom'], name='unique_recording_symptom'),
        ]

    def clean(self):
        if self.symptom.name != "その他" and self.other_symptom:
            raise ValidationError("other_symptom should be empty when symptom is not 'その他'")
        if self.symptom.name == "その他" and not self.other_symptom:
            raise ValidationError("other_symptom should be filled when symptom is 'その他'")

    def __str__(self):
        return f"RecordingSymptom: {self.recording} - {self.symptom}"
