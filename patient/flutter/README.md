# Dosezy Flutter

This directory is the beginning of the Flutter patient app, alongside the
existing Android application in `../android`.

The first migration slice contains the Dosezy theme, bottom navigation, and a
functional home-screen prototype. Medication entries currently live only in
memory. SQLite persistence, profiles, medication scheduling, Android alarms,
and notification permissions have not yet been ported; this prototype does
not schedule reminders.

After installing the Flutter SDK, generate the platform folders from this
directory with `flutter create --platforms android,ios .`, then run:

```sh
flutter pub get
flutter run
```
