from django.contrib import admin
from .models import CustomUser, Role
from django.contrib.auth.admin import UserAdmin

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('username', 'email', 'name', 'role', 'facility', 'is_staff', 'is_superuser')
    readonly_fields = ('groups', 'user_permissions', 'date_joined', 'last_login', 'created_at', 'updated_at')

    ordering = ('username',)

    fieldsets = (
        (None, {
            'fields': ('username', 'email', 'name', 'password', 'role', 'facility', 'is_staff', 'is_superuser'),
        }),
    )

    add_fieldsets = (
        (None, {
            'fields': ('username', 'email', 'name', 'password1', 'password2', 'role', 'facility', 'is_staff', 'is_superuser'),
        }),
    )

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    pass
