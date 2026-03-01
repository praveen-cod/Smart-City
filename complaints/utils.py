import imagehash
from PIL import Image
from geopy.distance import geodesic
from .models import Complaint

def compute_image_hash(image_file):
    return str(imagehash.phash(Image.open(image_file)))

def find_duplicate(lat, lng, new_hash):
    complaints = Complaint.objects.filter(is_duplicate=False)
    for complaint in complaints:
        try:
            dist = geodesic((lat, lng), (complaint.latitude, complaint.longitude)).meters
            if dist <= 20:
                if complaint.image_hash and new_hash:
                    # Convert hex string back to ImageHash object to calculate hamming distance
                    hamming = imagehash.hex_to_hash(new_hash) - imagehash.hex_to_hash(complaint.image_hash)
                    if hamming < 15:
                        return complaint
        except Exception:
            pass
    return None

def compute_severity_score(upvotes, severity, is_emergency):
    base = {'low': 20, 'moderate': 50, 'critical': 80}
    score = base.get(severity, 20)
    score += min(upvotes * 2, 20)
    if is_emergency:
        score += 20
    return min(float(score), 100.0)
