#!/usr/bin/env python3
"""Send FCM test notification to a single device.

Usage:
  python3 send_notification.py <paper_id> [fcm_token]

Setup (once):
  pip3 install google-auth requests
  Download service account key from Firebase Console →
  Project Settings → Service Accounts → Generate new private key
  Save as ~/sa.json
"""

import sys
import json
import subprocess

SA_KEY = "./sa.json"
DEFAULT_TOKEN = "cxE82rVw_0-HlBViGNuklW:APA91bEGY7H85GA5-83_9ePtjvRvoEiOlp0y_3N1CBEkmF1AehNd4q1hysvry461psRwp3c0cVqwIH_7N08_scD9g0awxJT8N4jNYmG7hzclUuk2TnXkH5E"

def main():
    paper_id = sys.argv[1] if len(sys.argv) > 1 else "a1000000-0000-0000-0000-000000000001"
    token = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_TOKEN

    try:
        import google.auth.transport.requests
        import google.oauth2.service_account
        import requests
    except ImportError:
        print("Installing deps...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "google-auth", "requests", "-q"])
        import google.auth.transport.requests
        import google.oauth2.service_account
        import requests

    import os
    sa_path = os.path.expanduser(SA_KEY)
    if not os.path.exists(sa_path):
        print(f"ERROR: Service account key not found at {sa_path}")
        print("Download from: Firebase Console → Project Settings → Service Accounts → Generate new private key")
        sys.exit(1)

    with open(sa_path) as f:
        project_id = json.load(f)["project_id"]

    creds = google.oauth2.service_account.Credentials.from_service_account_file(
        sa_path,
        scopes=["https://www.googleapis.com/auth/firebase.messaging"]
    )
    creds.refresh(google.auth.transport.requests.Request())

    r = requests.post(
        f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send",
        headers={"Authorization": f"Bearer {creds.token}"},
        json={"message": {
            "token": token,
            "notification": {"title": "New paper for you", "body": "Tap to view details"},
            "data": {"paper_id": paper_id}
        }}
    )

    if r.status_code == 200:
        print(f"✓ Sent paper_id={paper_id} to device")
    else:
        print(f"✗ {r.status_code}: {r.json()}")

if __name__ == "__main__":
    main()
