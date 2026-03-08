from django.db import models
from django.utils.translation import gettext_lazy as _

from apps.facilities.models import Facility


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
