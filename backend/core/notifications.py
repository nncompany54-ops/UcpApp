import os
import logging
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings

logger = logging.getLogger(__name__)

def initialize_firebase():
    """Initializes Firebase Admin SDK if not already initialized."""
    if not firebase_admin._apps:
        cred_path = os.path.join(settings.BASE_DIR, 'firebase-service-account.json')
        if os.path.exists(cred_path):
            try:
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin successfully initialized using service account.")
            except Exception as e:
                logger.error(f"Error initializing Firebase Admin with service account: {e}")
        else:
            logger.warning("firebase-service-account.json file not found. Push notifications will be logged to console.")

def send_push_notification(title, body, image_url=None):
    """Sends multicast push notifications to all registered device tokens."""
    # Lazy import to avoid circular dependency issues
    from .models import FCMDevice
    
    devices = FCMDevice.objects.all()
    tokens = [device.token for device in devices]
    
    if not tokens:
        logger.info("No registered FCM tokens found.")
        print(f"[Mock Notification] Title: {title} | Body: {body} | Image: {image_url} (No devices registered)")
        return

    initialize_firebase()
    
    if not firebase_admin._apps:
        logger.warning("Firebase app not initialized. Mocking push notification sending.")
        print(f"[Mock Notification] Target Tokens count: {len(tokens)}")
        print(f"[Mock Notification] Title: {title} | Body: {body} | Image: {image_url}")
        return

    # Construct the message
    # If image_url is relative, we can prefix it with standard host or keep it as is
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body,
            image=image_url
        ),
        tokens=tokens,
    )
    
    try:
        response = messaging.send_each_for_multicast(message)
        logger.info(f"Successfully sent notifications: {response.success_count} success, {response.failure_count} failure")
        print(f"FCM Multicast result: {response.success_count} succeeded, {response.failure_count} failed")
        
        # Clean up invalid tokens from the database to keep it clean
        if response.failure_count > 0:
            tokens_to_delete = []
            for idx, resp in enumerate(response.responses):
                if not resp.success:
                    # Check if failure is due to unregistered or invalid token
                    tokens_to_delete.append(tokens[idx])
            
            if tokens_to_delete:
                deleted_count, _ = FCMDevice.objects.filter(token__in=tokens_to_delete).delete()
                logger.info(f"Cleaned up {deleted_count} invalid FCM tokens from database.")
                print(f"Cleaned up {deleted_count} invalid FCM tokens.")
    except Exception as e:
        logger.error(f"Error sending multicast push notifications: {e}")
        print(f"FCM error: {e}")
