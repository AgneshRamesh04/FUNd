# Troubleshooting

## Creation failed, path = `.dart_tool` (OS Error: Permission denied, errno = 13)

This error means your user account cannot write to the project directory, or `.dart_tool` is owned by another user (commonly after running Flutter/Dart with `sudo`).

### Steps to fix

1. Go to the Flutter app directory:

```bash
cd "/Users/agnesh/Hobby Projects/FUNd/fund_app"
pwd
```

2. Check ownership and permissions:

```bash
ls -ld .
ls -ld .dart_tool 2>/dev/null || echo ".dart_tool does not exist"
id -un
```

3. If `.dart_tool` exists and is owned by `root` or another user, fix it:

```bash
sudo chown -R "$(id -un)":staff .dart_tool
chmod -R u+rwX .dart_tool
```

4. If the app directory is not writable by your user, fix the entire app folder:

```bash
cd "/Users/agnesh/Hobby Projects/FUNd"
sudo chown -R "$(id -un)":staff fund_app
chmod -R u+rwX fund_app
```

5. Remove stale generated folders (safe to regenerate):

```bash
cd "/Users/agnesh/Hobby Projects/FUNd/fund_app"
rm -rf .dart_tool build
```

6. Recreate Flutter/Dart generated state:

```bash
flutter clean
flutter pub get
```

7. Run the app again:

```bash
flutter run
```

### Prevention

- Do not run Flutter/Dart commands with `sudo` (for example `sudo flutter run` or `sudo dart ...`).

### If it still fails

Run this and inspect/share output:

```bash
ls -ld "/Users/agnesh/Hobby Projects/FUNd" "/Users/agnesh/Hobby Projects/FUNd/fund_app" ".dart_tool"
```
