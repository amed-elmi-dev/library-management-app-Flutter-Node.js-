# G Library Management App

This repository contains a simple library management app prototype with two main parts:

- `backend/` — Node.js/Express backend (API and controllers).
- `frontend/` — Flutter app (mobile/web) for the client UI.

Quick start

Backend

1. Open a terminal and go to the backend folder:

```bash
cd backend
```

2. Install dependencies and run:

```bash
npm install
npm start
```

The backend listens on the port configured in `backend/app.js` or the `PORT` environment variable.

Frontend (Flutter)

1. Ensure Flutter is installed and on your PATH.
2. From the project root, open the `frontend` folder:

```bash
cd frontend
flutter pub get
```

3. Run the app on an available device or emulator:

```bash
flutter run
```

Run tests

- Flutter widget tests:

```bash
cd frontend
flutter test
```

Notes

- The current Flutter app contains a placeholder welcome screen. Replace it with the real UI as you implement features.
- Update backend `README` or `package.json` scripts if you change start/test commands.

Environment

- Copy the example files to create your local `.env` files and set secrets/URLs:

```bash
cp .env.example .env
cp backend/.env.example backend/.env
```

- Ensure sensitive values (like `JWT_SECRET` or database credentials) are not checked into source control.

License

Proprietary — internal project skeleton.
