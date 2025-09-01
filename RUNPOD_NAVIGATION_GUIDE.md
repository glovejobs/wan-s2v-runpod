# 🎯 RunPod Console Navigation - Step by Step

**Current Page**: https://console.runpod.io/templates (should be open in your browser)

## Step 1: Create New Template
### Look for:
- 🔵 **Blue "New Template" button** (top right corner)
- Click it to start creating your template

---

## Step 2: Choose Template Type
### You'll see template options:
- ✅ **SELECT: "Build from GitHub"** (this is what we want!)
- ❌ Skip: "Import from Docker Hub"
- ❌ Skip: "Build from ZIP"

---

## Step 3: Basic Information
### Fill in these fields:

**Template Name:**
```
WAN-S2V-14B-Serverless
```

**Template Description:**
```
WAN 2.2 S2V model for speech-to-video generation - GitHub automated build
```

**Category:**
```
AI/ML (select from dropdown)
```

---

## Step 4: GitHub Configuration
### Repository Settings:

**GitHub Repository URL:**
```
https://github.com/glovejobs/wan-s2v-runpod
```

**Branch:**
```
main
```

**Dockerfile Path:**
```
Dockerfile
```
*(Use your existing Dockerfile - it's already optimized)*

**Build Context:** (usually auto-filled)
```
. 
```

---

## Step 5: Container Configuration
### Container Settings:

**Container Registry:**
```
Docker Hub (default)
```

**Repository Name:**
```
glovejobs/wan-s2v-14b-github
```

**Tag:**
```
latest
```

**Container Start Command:** (leave empty - uses Dockerfile CMD)

---

## Step 6: Ports Configuration
### Networking:

**Container Port:**
```
8000
```

**Expose Port:** (same as container)
```
8000
```

**Protocol:**
```
HTTP
```

---

## Step 7: Environment Variables
### Click "Add Environment Variable" for each:

**Variable 1:**
- Name: `PYTHONUNBUFFERED`
- Value: `1`

**Variable 2:**
- Name: `HF_HOME`
- Value: `/tmp`

**Variable 3:** (only if you need Hugging Face access)
- Name: `HF_TOKEN`
- Value: `your_huggingface_token_here`

---

## Step 8: Build Arguments (Optional)
### If your model needs Hugging Face access:

**Build Argument:**
- Name: `HF_TOKEN`
- Value: `your_huggingface_token_here`

---

## Step 9: Resource Configuration
### Recommended Settings:

**CPU:**
```
4 cores (minimum)
```

**Memory:**
```
16GB (minimum for 14B model)
```

**GPU:** (will be set when creating endpoint)
```
Leave as "Auto-detect"
```

---

## Step 10: Advanced Settings (Optional)
### You can usually skip these, but if needed:

**Volume Mounts:** (skip for now)
**Health Check:** (already in Dockerfile)
**Init Script:** (not needed)

---

## Step 11: Save Template
### Final Step:
- ✅ **Click "Save Template" button** (bottom of page)
- 🎉 **RunPod will now start building your image!**

---

# 📊 What Happens Next:

### Build Process:
1. ⏳ **Cloning**: RunPod clones your GitHub repo (5-10 seconds)
2. ⏳ **Building**: RunPod builds Docker image on their infrastructure (10-15 minutes)
3. ✅ **Complete**: Template becomes available for deployment

### You'll see build logs in real-time!

---

# 🚀 After Template is Built:

## Create Serverless Endpoint:
1. Go to **"Serverless"** tab in RunPod console
2. Click **"New Endpoint"**
3. Select your template: **"WAN-S2V-14B-Serverless"**
4. Choose GPU: **RTX 4090** (good price/performance)
5. Set scaling: **0 min, 3 max replicas**
6. Deploy!

---

# 🎯 Status Check:
- ✅ Code on GitHub: https://github.com/glovejobs/wan-s2v-runpod
- ⏳ **YOU ARE HERE**: Creating RunPod template
- ⏳ Next: Wait for build (10-15 minutes)
- ⏳ Final: Deploy serverless endpoint

**Need help?** Let me know which step you're on!
