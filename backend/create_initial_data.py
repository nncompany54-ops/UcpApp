import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ucp_backend.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import Company, Category, Product

# Create superuser
email = 'moha85awad@gmail.com'
password = 'moha773836693'
username = email.split('@')[0]  # moha85awad

if not User.objects.filter(username=username).exists():
    user = User.objects.create_superuser(username=username, email=email, password=password)
    print(f"Superuser {username} created successfully!")
else:
    user = User.objects.get(username=username)
    user.email = email
    user.set_password(password)
    user.is_superuser = True
    user.is_staff = True
    user.save()
    print(f"Superuser {username} updated successfully!")

# Create Company
company, created = Company.objects.get_or_create(name='شركة الجمال المتحدة (TYA)')
if created:
    print(f"Company {company.name} created successfully!")
else:
    print(f"Company {company.name} already exists!")

# Create Category
category, created = Category.objects.get_or_create(name='العناية بالبشرة')
if created:
    print(f"Category {category.name} created successfully!")
else:
    print(f"Category {category.name} already exists!")

# Create Product
product, created = Product.objects.get_or_create(
    name='منتج تجريبي 1',
    defaults={
        'description': 'وصف المنتج التجريبي',
        'company': company,
        'category': category,
        'price': 100.00
    }
)
if created:
    print(f"Product {product.name} created successfully!")
else:
    print(f"Product {product.name} already exists!")
