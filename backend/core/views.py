from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Company, Category, Product
from .serializers import CompanySerializer, CategorySerializer, ProductSerializer

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
