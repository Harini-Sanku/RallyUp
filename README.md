# RallyUp – Flutter Sports Community

A solo Flutter web application for discovering sports matches, joining games, creating matches, managing demo court bookings, and viewing a sample leaderboard.

## Features
- Responsive dark premium dashboard
- Multi-sport discovery: badminton, cricket, football, tennis, basketball, pickleball and volleyball
- Create matches with sport, venue, skill level, player capacity and fee
- Join open matches with player counts and capacity checks
- Demo court booking list
- Sample leaderboard and player profile
- Local persistence using `shared_preferences`

## Run locally
Install Flutter and enable web:
```bash
flutter doctor
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

## Build for web
```bash
flutter build web --release
```
The deployable website is generated in `build/web`.

## Deploy with GitHub Pages
1. Push this project to a GitHub repository.
2. In repository Settings → Pages, choose GitHub Actions.
3. Add a workflow that runs `flutter pub get`, `flutter build web --release --base-href /REPOSITORY_NAME/`, then uploads `build/web` and deploys it using GitHub Pages actions.
4. If using a custom domain or root domain, adjust `--base-href` accordingly.

## Important project notes
This is an academic prototype. Match listings, leaderboard values, venues, and booking options initially use sample data. User-created matches, joins, and bookings are saved in the current browser using local preferences. It does not process payments, provide live GPS matching, or implement real-time chat/backend authentication.
