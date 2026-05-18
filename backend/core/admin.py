from django.contrib import admin
from django.utils.html import format_html
from .models import Company, Category, Product, ProductImage

class ProductImageInline(admin.TabularInline):
    model = ProductImage
    extra = 1

@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    list_display = ('name', 'show_logo', 'id')
    search_fields = ('name',)

    def show_logo(self, obj):
        if obj.logo:
            return format_html('<img src="{}" style="width: 50px; height: 50px; border-radius: 5px;" />', obj.logo.url)
        return "لا يوجد شعار"
    show_logo.short_description = 'الشعار'

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'id')
    search_fields = ('name',)

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('show_image', 'name', 'company', 'category', 'price', 'is_featured', 'is_new_arrival')
    list_filter = ('company', 'category', 'is_featured', 'is_new_arrival', 'skin_type')
    search_fields = ('name', 'description', 'ingredients')
    list_editable = ('price', 'is_featured', 'is_new_arrival')
    inlines = [ProductImageInline]
    
    fieldsets = (
        ('المعلومات الأساسية', {
            'fields': ('name', 'description', 'company', 'category', 'price')
        }),
        ('التفاصيل الفنية', {
            'fields': ('ingredients', 'usage', 'warnings')
        }),
        ('التصنيف والخصائص', {
            'fields': ('skin_type', 'target_audience', 'product_type')
        }),
        ('الظهور', {
            'fields': ('is_featured', 'is_new_arrival')
        }),
    )

    def show_image(self, obj):
        first_image = obj.product_images.first()
        if first_image and first_image.image:
            return format_html('<img src="{}" style="width: 50px; height: 50px; border-radius: 5px; object-fit: cover;" />', first_image.image.url)
        return "لا توجد صورة"
    show_image.short_description = 'صورة المنتج'
