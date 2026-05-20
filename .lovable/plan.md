# Heartable — Bada Update Plan

Bahut saare features ek saath maange hain. Main inhe **4 phases** me todunga taaki har phase test ho sake. Aap "ha shuru kro" bolenge to phase 1 se start karunga, ya specific phase chunenge.

---

## Phase 1 — Foundation Fixes (chhoti but zaroori cheezein)

1. **Guest quota timezone-safe**
   - `todayKey()` me user ke local timezone ka YYYY-MM-DD use hoga (abhi bhi local hai but explicit karunga)
   - Quota UI me midnight ke baad auto-refresh (poll har 15s already hai — date change detect karunga)
   - Server-side rule bhi date-key ke saath enforce hoga

2. **Guest 7-day expiry — live timer + disable**
   - Profile page me bada countdown card ("6d 4h 22m baaki")
   - Home header me chhota chip
   - Expiry hote hi auto sign-out + `/login` pe "Account expire ho gaya — rebind karein" CTA
   - Login page pe naya **"Continue with Google to restore"** button (anonymous → Google link agar same browser me session ho)

3. **Mobile UI polish (pura app)**
   - Sab routes ko `max-w-[460px]` se hata kar fluid responsive (mobile-first, tablet/desktop pe center column)
   - Bottom nav: safe-area inset, active glow, FAB Mic ko proper raise
   - Stories bar: snap-scroll, larger touch targets
   - Recorder card: full-width on mobile, big tap zone
   - Feed cards: edge-to-edge on <400px

---

## Phase 2 — Short-Voice Social Layer (TikTok-style for voice)

Yeh main feature hai. Concept: vertical swipeable feed of short voice posts (≤60s) with caption, like, comment, share, follow.

### New routes / components
- `/reels` ya `/home` ko convert — **vertical full-screen voice cards**, swipe up/down (touch + keyboard)
- Each card: big artwork (user photo blurred bg + waveform), caption/shayari text overlay, play/pause tap-anywhere
- Action rail (right side): ❤ like count, 💬 comment count, ↗ share, • follow button

### Data model additions (Firebase RTDB)
```
feed/{postId}
  ├─ uid, name, photo, url, filter, caption, durationSec
  ├─ category: "song" | "shayari" | "story" | "other"
  ├─ likes: { uid: true }          # count via .size
  ├─ likeCount: number              # denormalized
  ├─ commentCount: number
  └─ shareCount: number

comments/{postId}/{commentId}
  └─ uid, name, text, createdAt

follows/{followerUid}/{followeeUid}: true
followers/{followeeUid}/{followerUid}: true
userStats/{uid}: { followers, following, totalLikes, totalShares }
```

### UI work
- Comment sheet (bottom drawer) with realtime list
- Share: Web Share API + copy-link fallback (`/p/{postId}` public route)
- Follow button on cards + profile
- Profile page redesign: stats row (Followers · Following · Likes · Shares), grid of own posts
- Category selector on recorder (Song / Shayari / Story / Other)

### Guest restrictions
- Guest can like + comment (limited?) — confirm: abhi default **like haa, comment 5/day, follow nahi, share haa**

---

## Phase 3 — Daily Streak Browser Notifications

- Service worker register (`/sw.js`) for push
- `Notification.requestPermission()` on first home visit (soft prompt card first)
- Local scheduled reminder via SW + IndexedDB timestamp (every evening 8pm local if streak risk)
- Admin broadcast push (Phase 4 se connect)
- FCM Web Push setup using existing Firebase project (requires VAPID key — aap Firebase Console → Cloud Messaging → Web Push certs se generate karenge, mujhe paste karenge)

---

## Phase 4 — Admin Panel + Support System

Admin: **schoudhary11256@gmail.com** (hardcoded check in admin route guard)

### `/admin` route (only for admin email)
- **Dashboard**: total users, active today, voices posted, guest vs full breakdown
- **Users tab**: search, view profile, disable account, delete posts, promote
- **Broadcast tab**:
  - Title + message input → send to all users (in-app banner + browser push)
  - Stored in `broadcasts/{id}` — clients listen and show
- **Tickets tab**:
  - List of open support tickets
  - Click → chat thread with user
  - Mark resolved
  - **Admin online indicator** — admin presence at `admin/presence` (RTDB onDisconnect)

### User-side support
- Profile → "Help / Support" button → opens chat
- If admin online → realtime chat
- If offline → "Aap queue me hain, ticket #123. Admin online hote hi jawaab milega" — store at `tickets/{ticketId}/messages`
- Ticket creation auto on first message

### Data model
```
admin/presence: { online: bool, lastSeen }
broadcasts/{id}: { title, body, createdAt, sentBy }
tickets/{ticketId}: { uid, name, status: "open"|"resolved", createdAt, lastMsgAt }
tickets/{ticketId}/messages/{msgId}: { from: "user"|"admin", text, createdAt }
```

---

## Firebase Console — Aapka Manual Kaam

Phase 1 ke baad confirm karunga ki yeh sab apply hua:

### 1. Authentication → Sign-in method
- Email/Password: **Enable**
- Google: **Enable** (project support email select karein)
- Anonymous: **Enable**

### 2. Realtime Database → Rules
Main exact JSON dunga jo paste karna hai. Includes:
- `voice/{uid}` — sirf owner write
- `voice/{uid}/quota/{date}` — increment-only, max 4 for guest
- `feed/{postId}` — auth read, owner write, likes/comments append rules
- `comments`, `follows`, `tickets`, `broadcasts`, `admin/presence` — per-feature rules
- Admin override via `auth.token.email == 'schoudhary11256@gmail.com'`

### 3. Storage → Rules
- `/voice/{uid}/**` — sirf owner upload, max 10MB, audio/* only

### 4. Cloud Messaging
- Web Push certificates → generate VAPID key pair → public key mujhe dena

### 5. Custom Claims (admin)
- Console me admin user ke liye custom claim set karna hoga — main aapko Firebase Functions ya gcloud command dunga. (Ya simpler: email-based check, jo low-security but quick hai. **Recommend: email check + RTDB rules me email match** — confirm karein.)

---

## Recommended Order

Main suggest karta hoon: **Phase 1 → 2 → 4 → 3** (push notifications last kyunki VAPID key chahiye).

**Aap kya chahte hain?**

A) Yes, plan accept — Phase 1 abhi shuru karo
B) Pehle Phase 2 (short-voice feed) — wahi sabse important hai
C) Sirf admin panel pehle banao
D) Sab ek saath ek hi mega-commit me (risky, but possible — 30+ files change honge)
