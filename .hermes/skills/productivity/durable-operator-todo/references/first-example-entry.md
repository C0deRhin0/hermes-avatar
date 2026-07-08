# Example: Deferred OAuth Test User

---
**Date created:** 2026-06-29  
**Title:** Add/Verify Google OAuth Test User
**Status:** Deferred (Pending user access to Google credentials/phone)
**Overview:** Google OAuth Device Login integration was interrupted; app cannot be verified due to inaccessibility to test-user registration.
**Problem:** Cannot proceed until user can access Google account and register as OAuth test user (needs new SIM/phone for 2FA or verification).
**Actions Taken:**
- Attempted device code auth; error 403 access_denied ("Hermes YouTube Integration has not completed the Google verification process").
- Identified cause: test user (e.g., knowledge_base.scrawler@gmail.com) not added to GCP 'Test users' on the OAuth consent screen.
- Collected 'how to add as test user' URL and steps.
**Actions Next:**
- When able, access: https://console.cloud.google.com/apis/credentials/consent
- Log into correct project and add test user email.
- Resume OAuth workflow after test user is accepted by Google.
**Notes:**
- No action required until next attempt is possible
---
