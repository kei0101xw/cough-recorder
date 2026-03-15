from rest_framework import routers
from .views import FacilityViewSet

router = routers.DefaultRouter()
router.register('facilities', FacilityViewSet)
urlpatterns = router.urls