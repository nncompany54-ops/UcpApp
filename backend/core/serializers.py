from rest_framework import serializers
from .models import Company, Category, Product, Banner

class CompanySerializer(serializers.ModelSerializer):
    logo = serializers.SerializerMethodField()

    class Meta:
        model = Company
        fields = ['id', 'name', 'logo']

    def get_logo(self, obj):
        if not obj.logo:
            return None
        url = obj.logo.url
        if url.startswith('/'):
            return f"https://ucp.moha85awad.site{url}"
        elif not url.startswith('http'):
            return f"https://ucp.moha85awad.site/{url}"
        return url

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
            'product_type', 'images', 'is_featured', 'is_new_arrival',
            'created_at', 'updated_at'
        ]

    def get_images(self, obj):
        urls = []
        for img in obj.product_images.all():
            if not img.image:
                continue
            url = img.image.url
            if url.startswith('/'):
                url = f"https://ucp.moha85awad.site{url}"
            elif not url.startswith('http'):
                url = f"https://ucp.moha85awad.site/{url}"
            urls.append(url)
        return urls

class BannerSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()

    class Meta:
        model = Banner
        fields = ['id', 'title', 'image', 'expires_at', 'created_at']

    def get_image(self, obj):
        if not obj.image:
            return None
        url = obj.image.url
        if url.startswith('/'):
            return f"https://ucp.moha85awad.site{url}"
        elif not url.startswith('http'):
            return f"https://ucp.moha85awad.site/{url}"
        return url
