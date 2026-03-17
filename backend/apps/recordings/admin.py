from django.contrib import admin
from .models import Recording, RecordingCondition, RecordingSymptom

class RecordingConditionInline(admin.TabularInline):
    model = RecordingCondition
    extra = 0

class RecordingSymptomInline(admin.TabularInline):
    model = RecordingSymptom
    extra = 0

@admin.register(Recording)
class RecordingAdmin(admin.ModelAdmin):
    model = Recording
    list_display = ("id", "user", "patient", "dementia", "status", "recorded_at", "created_at", "updated_at")
    inlines = [RecordingConditionInline, RecordingSymptomInline]