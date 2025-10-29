# Codemagic iOS Build Setup Guide

This guide will help you set up automated iOS builds using Codemagic CI/CD with your GitHub repository.

## Prerequisites

1. **Apple Developer Account** (Required for iOS builds)
   - Paid Apple Developer Program membership ($99/year)
   - Required for code signing and App Store distribution

2. **GitHub Repository**
   - Your code is already in: https://github.com/MaggieNoo/CFG.git

3. **Codemagic Account**
   - Sign up at: https://codemagic.io
   - Free tier available (500 build minutes/month for macOS)

## Step 1: Push Your Code to GitHub

```powershell
# Navigate to your project
cd d:\Xampp\htdocs\camalig\gym_project

# Add all files
git add .

# Commit your changes
git commit -m "Add Codemagic iOS build configuration"

# Push to GitHub
git push origin main
```

## Step 2: Set Up Codemagic

### 2.1 Create Codemagic Account
1. Go to https://codemagic.io
2. Click "Sign up with GitHub"
3. Authorize Codemagic to access your GitHub repositories

### 2.2 Add Your Repository
1. In Codemagic dashboard, click "Add application"
2. Select "GitHub" as the source
3. Choose your repository: **MaggieNoo/CFG**
4. Select the Flutter project type
5. Codemagic will detect the `codemagic.yaml` file

## Step 3: Configure iOS Code Signing

### 3.1 Apple Developer Certificates
You need to set up code signing in Codemagic:

1. **In Codemagic Dashboard:**
   - Go to "Teams" → "Team settings" → "Code signing identities"
   - Click "iOS certificates"

2. **Add Distribution Certificate:**
   - Upload your Apple Distribution certificate (.p12 file)
   - Or generate one through Codemagic's automatic code signing

3. **Add Provisioning Profile:**
   - Upload your App Store provisioning profile
   - Bundle ID: `com.camalig.camaligGym`

### 3.2 App Store Connect API Key
For automatic uploads to TestFlight/App Store:

1. **Generate API Key in App Store Connect:**
   - Go to https://appstoreconnect.apple.com
   - Users and Access → Keys → App Store Connect API
   - Create a new key with "App Manager" access
   - Download the `.p8` key file (only available once!)
   - Note the **Key ID** and **Issuer ID**

2. **Add to Codemagic:**
   - In Codemagic: Teams → Integrations → App Store Connect
   - Upload the `.p8` file
   - Enter Key ID and Issuer ID
   - Give it a reference name (e.g., "codemagic")

## Step 4: Configure Environment Variables

In your Codemagic app settings, add these environment variables:

1. `APP_STORE_APPLE_ID` - Your Apple ID email
2. `APP_STORE_CONNECT_PRIVATE_KEY` - Your .p8 key content
3. `APP_STORE_CONNECT_KEY_IDENTIFIER` - Your Key ID
4. `APP_STORE_CONNECT_ISSUER_ID` - Your Issuer ID

## Step 5: Update Configuration

Edit `codemagic.yaml` and update:

```yaml
environment:
  vars:
    APP_STORE_APPLE_ID: your.email@example.com # Your Apple ID

publishing:
  email:
    recipients:
      - your.email@example.com # Your notification email
```

## Step 6: Start Your First Build

1. **Automatic Builds:**
   - Push any commit to `main` branch
   - Codemagic will automatically detect and start building

2. **Manual Build:**
   - Go to Codemagic dashboard
   - Select your app
   - Click "Start new build"
   - Select workflow: `ios-workflow` or `ios-debug-workflow`
   - Click "Start new build"

## Workflows Explained

### `ios-workflow` (Production)
- Builds release IPA for App Store
- Requires code signing certificates
- Automatically uploads to TestFlight (if configured)
- Build time: ~15-20 minutes
- Uses: App Store distribution

### `ios-debug-workflow` (Testing)
- Builds debug version without code signing
- Faster builds for testing
- Runs `flutter analyze` and `flutter test`
- Build time: ~5-10 minutes
- Uses: Quick validation, testing

## Troubleshooting

### Build Fails: Code Signing Error
- **Solution:** Ensure certificates and provisioning profiles are correctly uploaded
- Check that Bundle ID matches: `com.camalig.camaligGym`
- Verify certificate hasn't expired

### Build Fails: Pod Install Error
- **Solution:** Update your `Podfile` or `pubspec.yaml`
- Codemagic will automatically run `pod install`

### Build Takes Too Long
- **Solution:** Use `ios-debug-workflow` for quick tests
- Production builds naturally take longer (15-20 min)

### No Automatic Builds
- **Solution:** Check webhook is enabled in GitHub repository settings
- Go to: Repository → Settings → Webhooks
- Should see Codemagic webhook

## Build Artifacts

After successful build, you'll get:

1. **IPA File** - iOS app package (in `build/ios/ipa/`)
2. **Build Logs** - Full Xcode build logs
3. **TestFlight Upload** - Automatic if configured

## Next Steps

1. **TestFlight Testing:**
   - Set `submit_to_testflight: true` in `codemagic.yaml`
   - Add beta testers in App Store Connect

2. **App Store Release:**
   - After TestFlight testing passes
   - Submit for App Store review through App Store Connect

3. **Automatic Versioning:**
   - Build number automatically increments: `1.0.$BUILD_NUMBER`
   - Edit in `codemagic.yaml` if needed

## Useful Links

- **Codemagic Docs:** https://docs.codemagic.io/flutter-configuration/flutter-projects/
- **iOS Code Signing:** https://docs.codemagic.io/code-signing-yaml/signing-ios/
- **App Store Connect:** https://appstoreconnect.apple.com/
- **Your GitHub Repo:** https://github.com/MaggieNoo/CFG

## Cost Estimate

**Codemagic Free Tier:**
- 500 build minutes/month (macOS)
- ~25-30 iOS builds per month
- Enough for small teams

**Paid Plans:**
- Standard: $49/month (3000 minutes)
- Professional: Custom pricing

## Support

If you encounter issues:
1. Check Codemagic build logs
2. Visit Codemagic Slack community
3. Review Flutter iOS docs: https://docs.flutter.dev/deployment/ios

---

**Bundle Identifier:** com.camalig.camaligGym  
**App Name:** camalig_gym  
**Current Version:** 1.0.0+1
