from django.contrib import admin
from .models import CustomUser, Role

@admin.register(CustomUser)
class CustomUserAdmin(admin.ModelAdmin):
    model = CustomUser
    list_display = ('email', 'name', 'role', 'facility', 'is_staff', 'is_superuser')


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    pass
