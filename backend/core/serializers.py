from rest_framework import serializers
from .models import Company, Category, Product

class CompanySerializer(serializers.ModelSerializer):
    class Meta:
        model = Company
        fields = ['id', 'name', 'logo']

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']

class ProductSerializer(serializers.ModelSerializer):
    company = CompanySerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    images = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'ingredients', 'usage', 'warnings',
            'company', 'category', 'skin_type', 'target_audience',
            'product_type', 'price', 'images', 'is_featured', 'is_new_arrival',
            'created_at', 'updated_at'
        ]

    def get_images(self, obj):
        request = self.context.get('request')
        return [
            request.build_absolute_uri(img.image.url) if request else img.image.url 
            for img in obj.product_images.all()
        ]
