from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Company, Category, Product, Banner, FCMDevice
from .serializers import CompanySerializer, CategorySerializer, ProductSerializer, BannerSerializer, FCMDeviceSerializer


class CompanyViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Company.objects.all()
    serializer_class = CompanySerializer

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

    def get_queryset(self):
        company_id = self.request.query_params.get('company', None)
        if company_id is not None:
            # أقسام مرتبطة بهذه الشركة + الأقسام العامة (غير مرتبطة بأي شركة)
            from django.db.models import Q
            return Category.objects.filter(
                Q(companies__id=company_id) | Q(companies__isnull=True)
            ).distinct()
        return Category.objects.all()

class ProductViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['company', 'category', 'skin_type', 'target_audience', 'is_featured', 'is_new_arrival']
    search_fields = ['name', 'description', 'company__name', 'category__name']

from django.utils import timezone
from django.db.models import Q

class BannerViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Banner.objects.all()
    serializer_class = BannerSerializer

    def get_queryset(self):
        now = timezone.now()
        # Return only active (not expired) banners
        return Banner.objects.filter(
            Q(expires_at__isnull=True) | Q(expires_at__gt=now)
        ).order_by('-created_at')

from rest_framework import status
from rest_framework.response import Response
from rest_framework import permissions
class FCMDeviceViewSet(viewsets.ModelViewSet):
    queryset = FCMDevice.objects.all()
    serializer_class = FCMDeviceSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        token = request.data.get('token')
        if not token:
            return Response({'error': 'رمز الجهاز (token) مطلوب'}, status=status.HTTP_400_BAD_REQUEST)
        
        device, created = FCMDevice.objects.get_or_create(token=token)
        serializer = self.get_serializer(device)
        status_code = status.HTTP_201_CREATED if created else status.HTTP_200_OK
        return Response(serializer.data, status=status_code)

