from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _
from django.core.exceptions import ValidationError

from apps.facilities.models import Facility


class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Users must have an email address")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)


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
    role = models.ForeignKey(Role, on_delete=models.CASCADE, blank=True, null=True)
    facility = models.ForeignKey(Facility, on_delete=models.CASCADE, blank=True, null=True) # superuserやstaffは施設に所属しないため、blank,null=Trueにする
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["name"] # createsuperuserコマンドで必要なフィールド

    objects = CustomUserManager()

    def clean(self):
        if not self.is_superuser and not self.is_staff:
            if self.facility is None:
                raise ValidationError({
                    "facility": "Regular users must belong to a facility"
                })
            if self.role is None:
                raise ValidationError({
                    "role": "Regular users must have a role"
                })

    def __str__(self):
        return self.name + " (" + self.email + ")"
