from rest_framework import routers
from .views import ConditionViewSet, SymptomViewSet, DementiaViewSet

router = routers.DefaultRouter()
router.register('conditions', ConditionViewSet)
router.register('symptoms', SymptomViewSet)
router.register('dementias', DementiaViewSet)
urlpatterns = router.urls
