import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ucp_backend.settings')
django.setup()

from core.models import Company, Category, Product

def populate():
    # Create Companies
    c1, _ = Company.objects.get_or_create(name="Beautify", logo="https://via.placeholder.com/150")
    c2, _ = Company.objects.get_or_create(name="Natura", logo="https://via.placeholder.com/150")
    
    # Create Categories
    cat1, _ = Category.objects.get_or_create(name="عناية بالبشرة")
    cat2, _ = Category.objects.get_or_create(name="عطور")
    
    # Create Products
    Product.objects.get_or_create(
        name="كريم مرطب يومي",
        description="كريم مرطب عالي الجودة",
        price=45.0,
        company=c1,
        category=cat1,
        images=["https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=400&q=80"]
    )
    
    Product.objects.get_or_create(
        name="سيروم فيتامين سي",
        description="سيروم لتفتيح البشرة",
        price=120.0,
        company=c2,
        category=cat1,
        images=["https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=400&q=80"]
    )
    
    Product.objects.get_or_create(
        name="عطر زهري منعش",
        description="عطر مميز يدوم طويلا",
        price=250.0,
        company=c1,
        category=cat2,
        images=["https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=400&q=80"]
    )

    print("Data populated successfully!")

if __name__ == '__main__':
    populate()
