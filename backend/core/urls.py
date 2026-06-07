from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CompanyViewSet, CategoryViewSet, ProductViewSet, BannerViewSet

router = DefaultRouter()
router.register(r'companies', CompanyViewSet)
router.register(r'categories', CategoryViewSet)
router.register(r'products', ProductViewSet)
router.register(r'banners', BannerViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
