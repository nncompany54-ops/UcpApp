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

class ProductViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['company', 'category', 'skin_type', 'target_audience', 'is_featured', 'is_new_arrival']
    search_fields = ['name', 'description', 'company__name', 'category__name']
