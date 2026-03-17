from rest_framework import routers
from .views import RecordingViewSet

router = routers.DefaultRouter()
router.register('recordings', RecordingViewSet)
urlpatterns = router.urls