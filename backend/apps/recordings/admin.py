from django.contrib import admin
from .models import Recording

@admin.register(Recording)
class RecordingAdmin(admin.ModelAdmin):
    model = Recording
    list_display = ("id", "user", "patient", "dementia", "status", "recorded_at", "created_at", "updated_at")
