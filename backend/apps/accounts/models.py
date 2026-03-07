from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _
from django.core.exceptions import ValidationError


class Facility(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name


class Role(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name


'''
・password
・is_superuser
・is_staff
・is_active
・last_login
・date_joined
はAbstractUserに含まれているため、CustomUserには定義しない
'''
class CustomUser(AbstractUser):
    username = None
    first_name = None
    last_name = None
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    role = models.ForeignKey(Role, on_delete=models.CASCADE)
    facility = models.ForeignKey(Facility, on_delete=models.CASCADE, blank=True, null=True) # superuserやstaffは施設に所属しないため、blank,null=Trueにする
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["name"] # createsuperuserコマンドで必要なフィールド

    def clean(self):
        if not self.is_superuser and not self.is_staff:
            if self.facility is None:
                raise ValidationError({
                    "facility": "Regular users must belong to a facility"
                })

    def __str__(self):
        return self.name + " (" + self.email + ")"


class Patient(models.Model):
    class BiologicalSex(models.TextChoices):
        MAN = "man", _("男性")
        WOMAN = "woman", _("女性")
        OTHER = "other", _("その他")
    
    research_id = models.CharField(max_length=100, unique=True, blank=True, null=True)
    patient_code = models.CharField(max_length=100)
    biological_sex = models.CharField(max_length=10, choices=BiologicalSex.choices)
    birth_date = models.DateField()
    facility = models.ForeignKey(Facility, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['patient_code', 'facility'], name='unique_patient_code_per_facility'),
        ]
    
    def __str__(self):
        return self.patient_code + " (" + self.facility.name + ")"


class Condition(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
    

class Symptom(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name


class Dementia(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name


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
    recording = models.ForeignKey(Recording, on_delete=models.CASCADE)
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
    recording = models.ForeignKey(Recording, on_delete=models.CASCADE)
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