# Smart Civic Complaint Platform Backend Demo

This is a functional backend prototype for a Smart Civic Complaint Platform. It is built using Django REST Framework, SQLite, JWT authentication, and provides features such as complaint submission, upvoting, dashboard metrics, and basic image deduplication.

## Prerequisites

- Python 3.8+
- The dependencies are managed via standard `pip`. 

## How to Run

1. **Navigate to the application directory**

   Make sure your terminal is inside the `civic_demo` folder:
   ```bash
   cd path/to/civic_demo
   ```

2. **Install dependencies** (if you haven't already):

   ```bash
   pip install django djangorestframework djangorestframework-simplejwt pillow django-cors-headers imagehash geopy
   ```

3. **Database migrations & seeding**

   The project uses SQLite, and is currently pre-configured and seeded. If you need to rebuild the database, run:
   ```bash
   python manage.py makemigrations users
   python manage.py makemigrations complaints
   python manage.py migrate
   
   # Populate with dummy users and complaints
   python manage.py seed
   ```

4. **Start the Development Server**

   ```bash
   python manage.py runserver
   ```
   The backend will start at `http://127.0.0.1:8000/`.

## Users Created by `seed`

- **Admin/Authority**:
  - `admin` (Role: admin, Pass: `admin123`)
  - `authority1` (Role: authority, Pass: `auth123`)
- **Citizens**:
  - `citizen1`, `citizen2`, `citizen3` (Role: citizen, Pass: `pass123`)

---

## How to Test Functionality via API (Postman / CURL)

All standard API responses return JSON data.

### 1. Registration
- **Endpoint:** `POST /api/auth/register/`
- **Auth:** None required
- **Body (JSON):**
  ```json
  {
      "username": "new_user",
      "password": "mypassword123",
      "phone": "9876543210",
      "email": "user@test.com",
      "role": "citizen"
  }
  ```

### 2. Login (Get JWT Token)
- **Endpoint:** `POST /api/auth/login/`
- **Auth:** None required
- **Body (JSON):**
  ```json
  {
      "username": "citizen1",
      "password": "pass123"
  }
  ```
> **IMPORTANT:** Copy the `access` token from the response. Use it as a Bearer Token (`Authorization: Bearer <your_access_token>`) for all following endpoints.

### 3. Submit a Complaint
- **Endpoint:** `POST /api/complaints/submit/`
- **Auth:** Bearer Token (Any Citizen)
- **Format:** `multipart/form-data`
- **Body Fields:**
  - `images`: Select file(s) (Required)
  - `latitude`: `17.412345`
  - `longitude`: `78.412345`
  - `issue_type`: `pothole` (Options: pothole, garbage, streetlight, water_leak, drain, other)
  - `address`: `Sample Road`
  - `description`: `A very deep pothole`
  - `severity`: `moderate` (Options: low, moderate, critical)
  - `is_emergency`: `true` or `false`
> *Tip:* If you submit the exact same image with a nearby lat/lng (within 20m), it will mark the submission as a duplicate and boost the original complaint's priority instead.

### 4. View All Complaints
- **Endpoint:** `GET /api/complaints/`
- **Auth:** Bearer Token
- **Query Params (Optional):**
  - `?status=resolved`
  - `?issue_type=garbage`

### 5. View My Complaints
- **Endpoint:** `GET /api/complaints/mine/`
- **Auth:** Bearer Token (Matches logged-in user)

### 6. View Complaint Details
- **Endpoint:** `GET /api/complaints/<id>/` (replace `<id>` with the UUID of a complaint)
- **Auth:** Bearer Token
- **Note:** Contains the full image history, nested status history, and description.

### 7. Upvote a Complaint
- **Endpoint:** `POST /api/complaints/<id>/upvote/` (replace `<id>` with the UUID)
- **Auth:** Bearer Token
- **Status:** You can only upvote once. Severity score is dynamically recalculated!

### 8. Update Complaint Status (Authorities/Admins only)
- **Endpoint:** `PATCH /api/complaints/<id>/status/`
- **Auth:** Bearer Token (must be logged in as `authority1` or `admin`)
- **Body (JSON):**
  ```json
  {
      "status": "in_progress"
  }
  ```
> *Note:* Updating the status auto-generates a Notification for the complaint owner!

### 9. Dashboard Analytics
- **Endpoint:** `GET /api/dashboard/`
- **Auth:** Bearer Token
- **Description:** Returns JSON summary of total complaints, resolution rate, severity stats, and un-resolved complaint coordinates for heatmap plotting.

### 10. Notifications
- **Endpoint:** `GET /api/notifications/`
- **Auth:** Bearer Token (Get latest 20 notifications for the user)
- **Endpoint:** `PATCH /api/notifications/`
- **Auth:** Bearer Token (Mark all unread notifications as read)

## Development Notes
- This is a demo; database is SQLite.
- Images uploaded are saved perfectly to the `media/complaints/` folder. Ensure the local server is running to serve the resulting URLs. 


