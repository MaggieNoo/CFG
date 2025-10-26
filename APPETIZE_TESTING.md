# 🍎 Testing iOS App with Appetize.io

## Free Testing Solution (No Mac Required!)

This guide shows you how to test the iOS app in your browser using Appetize.io - **completely free** for up to 100 minutes/month.

## Step 1: Get the Simulator Build

### **RECOMMENDED METHOD:**

1. Go to your GitHub repository: https://github.com/MaggieNoo/CFG
2. Click on **"Actions"** tab
3. Click on the latest workflow run
4. Scroll down to **"Artifacts"** section
5. Download: **`runner-app-folder`** ⭐ **USE THIS ONE**

### Alternative Method:
- Download `appetize-simulator-build` (contains pre-compressed versions)

## Step 2: Prepare the App for Upload

### Using runner-app-folder (RECOMMENDED):

1. **Extract** the downloaded `runner-app-folder.zip` from GitHub
2. You'll get a folder structure with **Runner.app** inside
3. **On Windows:**
   - Install 7-Zip if you don't have it
   - Right-click the `Runner.app` folder
   - Select "7-Zip" > "Add to archive"
   - Format: ZIP
   - Save as `Runner.zip`

4. **On Mac:**
   - Right-click the `Runner.app` folder
   - Select "Compress"
   - This creates `Runner.app.zip`

### Using pre-compressed files (Alternative):

If you downloaded `appetize-simulator-build`:
- Extract it and try uploading `camalig_gym_simulator.tar.gz`

## Step 3: Upload to Appetize.io

1. Visit: https://appetize.io
2. Click **"Upload App"** or **"Try Demo"**
3. Upload the ZIP file you created (e.g., `Runner.zip`)
4. Choose platform: **iOS**
5. Wait for upload to complete (~1-2 minutes)

### Troubleshooting Upload Issues:

**If you see "No app folder found":**
- ✅ Make sure you're zipping the `Runner.app` **folder itself**, not its contents
- ✅ The ZIP should contain: `Runner.app/` at the root
- ✅ Try using the `runner-app-folder` artifact and compress it yourself
- ✅ Use 7-Zip or native compression (don't use WinRAR with special options)

## Step 4: Test Your App

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
