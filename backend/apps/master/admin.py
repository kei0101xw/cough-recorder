from django.contrib import admin
from .models import Symptom, Condition, Dementia

@admin.register(Symptom)
class SymptomAdmin(admin.ModelAdmin):
    pass

@admin.register(Condition)
class ConditionAdmin(admin.ModelAdmin):
    pass

@admin.register(Dementia)
class DementiaAdmin(admin.ModelAdmin):
    pass