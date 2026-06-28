# Google-authenticated browsing from a VPS

Use this note when the user wants Hermes to browse as a logged-in Google user from a self-hosted VPS.

## Core framing

A Google account helps as an **identity layer inside browser automation**. It can enable access to Gmail, Drive, Docs, YouTube, and third-party sites using "Continue with Google". It does **not** by itself turn Hermes into a full desktop/GUI-machine operator across arbitrary native apps.

## Operator guidance

1. **Set expectations early.**
   - Distinguish:
     - web search / extraction
     - browser automation as a logged-in web user
     - full desktop / computer-use control
   - Say clearly which layer the account enables.

2. **Treat Google sign-in friction as an account-trust problem, not only a headless-browser problem.**
   - Even with stealth/fingerprint reduction, Google may still gate on:
     - IP reputation
     - VPS/datacenter origin
     - account age and trust
     - device consistency
     - phone/recovery requirements
     - CAPTCHA / suspicious-login review

3. **Do not recommend or operationalize CAPTCHA-bypass tactics for Google.**
   - Avoid advising use of CAPTCHA-solving services or other anti-abuse bypass tooling for Google account access.
   - It is acceptable to explain, at a high level, that stealth plugins, residential proxies, and cookie persistence exist and may affect detection, but do not present them as the approved path for Google login.

4. **Prefer legitimate account completion on a trusted device.**
   - Best path:
     - user completes sign-in / phone verification / recovery steps on a normal trusted device
     - then Hermes reuses a valid authenticated browser session if available
   - Reusing a legitimate logged-in session is usually more viable than first-time Google login from a VPS browser.

5. **Be careful with phone-number guidance.**
   - If the user hits "This phone number has been used too many times", do not promise reset or cooldown recovery.
   - Google Account Community guidance indicates the count cannot be reset; a different acceptable number is often required.
   - Alternate signup paths (e.g. YouTube sign-up or third-party mail-client add-account flows) are anecdotal and should be described as non-guaranteed.

## Practical response pattern

When the user asks whether giving a Google account will let Hermes do "anything a GUI machine can do":

- answer **No, not by itself**
- explain the account enables **logged-in browser workflows**
- explain full desktop control requires separate computer-use / desktop-control capabilities

When the user asks Hermes to send a Gmail test email and Google blocks login:

- report what step succeeded (opened Gmail, entered email, reached verification)
- identify the blocker precisely (CAPTCHA, suspicious-login review, phone requirement)
- avoid pretending the credential itself is sufficient
- recommend the trusted-device completion + session reuse path

## Sources worth citing

- Google Account Community thread on "This phone number has been used too many times" (summary: count cannot be reset; different number often required)
- Internal session summary in Knowledge Base documenting the headless Gmail attempt and verification gate
