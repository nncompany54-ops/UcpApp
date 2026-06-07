from django.db import models

class Company(models.Model):
    name = models.CharField(max_length=255)
    logo = models.ImageField(upload_to='company_logos/', blank=True, null=True)  # File upload to local media/Supabase

    def __str__(self):
        return self.name

class Category(models.Model):
    name = models.CharField(max_length=255)
    companies = models.ManyToManyField(
        'Company',
        related_name='categories',
        blank=True,
        verbose_name='الشركات المرتبطة'
    )

    def __str__(self):
        return self.name

class Product(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    ingredients = models.TextField(blank=True, null=True)
    usage = models.TextField(blank=True, null=True)
    warnings = models.TextField(blank=True, null=True)
    company = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='products')
    skin_type = models.CharField(max_length=100, blank=True, null=True)
    target_audience = models.CharField(max_length=200, blank=True, null=True)
    product_type = models.CharField(max_length=100, blank=True, null=True)
    is_featured = models.BooleanField(default=False)
    is_new_arrival = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class ProductImage(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='product_images')
    image = models.ImageField(upload_to='product_images/')

    def __str__(self):
        return f"صورة لـ {self.product.name}"

class Banner(models.Model):
    title = models.CharField(max_length=255, verbose_name="العنوان")
    image = models.ImageField(upload_to='banners/', verbose_name="الصورة")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="تاريخ الإنشاء")
    expires_at = models.DateTimeField(blank=True, null=True, verbose_name="تاريخ الانتهاء", help_text="اتركه فارغاً ليكون العرض مفتوحاً/مستمراً")

    class Meta:
        verbose_name = "صورة سلايدر"
        verbose_name_plural = "صور السلايدر"
        ordering = ['-created_at']

    def __str__(self):
        return self.title
