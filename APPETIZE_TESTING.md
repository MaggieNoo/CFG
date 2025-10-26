# 🍎 Testing iOS App with Appetize.io

## Free Testing Solution (No Mac Required!)

This guide shows you how to test the iOS app in your browser using Appetize.io - **completely free** for up to 100 minutes/month.

## Step 1: Get the Simulator Build

1. Go to your GitHub repository: https://github.com/MaggieNoo/CFG
2. Click on **"Actions"** tab
3. Click on the latest workflow run
4. Scroll down to **"Artifacts"** section
5. Download: **`appetize-simulator-build`** (contains `camalig_gym_simulator.zip`)

## Step 2: Upload to Appetize.io

1. Visit: https://appetize.io
2. Click **"Upload App"** or **"Try Demo"**
3. Select the downloaded `camalig_gym_simulator.zip` file
4. Choose platform: **iOS**
5. Wait for upload to complete (~1-2 minutes)

## Step 3: Test Your App

Once uploaded, you'll get:
- ✅ Interactive iOS simulator in your browser
- ✅ Touch/gesture simulation
- ✅ Ability to test all app features
- ✅ Shareable link for team testing

## 💰 Pricing (as of 2025)

### Free Tier:
- ✅ 100 minutes per month
- ✅ All features available
- ✅ No credit card required

### Paid Plans (if needed):
- Start at $40/month for 300 minutes
- Ideal for team testing

## 📝 Tips

- Each session counts against your monthly minutes
- Close the simulator when done to save time
- You can upload new versions anytime
- Share the link with team members for testing

## Alternative: Download Other Builds

If you need the unsigned IPA for other testing tools:
- Download **`camalig-gym-ios-ipa`** artifact
- This contains `camalig_gym_unsigned.ipa`
- Can be used with services like Diawi for team distribution
- ⚠️ Cannot be installed on physical devices without signing

## Need Help?

- Appetize.io Docs: https://docs.appetize.io
- GitHub Actions: Check the Actions tab for build status
