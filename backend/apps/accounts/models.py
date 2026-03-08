from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _
from django.core.exceptions import ValidationError

from apps.facilities.models import Facility


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
