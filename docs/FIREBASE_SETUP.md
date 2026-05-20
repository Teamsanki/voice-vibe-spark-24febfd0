# Heartable — Firebase Console Setup

## 1. Authentication → Sign-in method

Enable:
- **Email/Password**
- **Google** (set project support email)
- **Anonymous**

Add authorized domains: your `.lovable.app` preview + production URLs.

## 2. Realtime Database → Rules

Paste contents of `firebase-rtdb-rules.json` (next file).

## 3. Storage → Rules

Paste contents of `firebase-storage-rules.txt`.

## 4. Admin

Admin email is hardcoded: `schoudhary11256@gmail.com`. Sign up with this email
(Google or Email/Password) and you'll get access to `/admin` automatically.

## 5. Cloud Messaging (later — for browser push notifications)

- Project Settings → Cloud Messaging → Web Push certificates → "Generate key pair"
- Paste the **public VAPID key** in chat so I can wire FCM up.