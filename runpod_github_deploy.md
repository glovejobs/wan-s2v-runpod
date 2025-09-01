# FastTrack: Deploy WAN S2V to RunPod via GitHub Integration

## 🚀 Fastest Method: Build Directly on RunPod

Instead of pushing 26.8GB images, let RunPod build directly from your code!

### Step 1: Push Code to GitHub (Not Docker Image!)

```bash
# Initialize git repo if not already done
git init
git add .
git commit -m "WAN S2V model for RunPod deployment"

# Push to GitHub (much faster than Docker push!)
git remote add origin https://github.com/yourusername/wan-s2v-runpod.git
git push -u origin main
```

### Step 2: Use RunPod's GitHub Integration

1. **Go to RunPod Console**: https://console.runpod.io/
2. **Templates → Create Template**
3. **Select "Build from GitHub"**
4. **Repository**: `yourusername/wan-s2v-runpod`
5. **Dockerfile Path**: `./Dockerfile`
6. **Build Arguments**: Add your HF_TOKEN if needed

### Step 3: RunPod Builds for You

- RunPod's servers download your code (seconds, not hours!)
- They build the Docker image on their infrastructure (fast GPUs + bandwidth)
- No 26.8GB upload from your machine!

### Step 4: Deploy Serverless Endpoint

```bash
runpodctl project serverless create-endpoint \
  --name "wan2v-s2v-14b-github" \
  --template-id "YOUR_TEMPLATE_ID_FROM_STEP_2" \
  --gpu "NVIDIA GeForce RTX 4090" \
  --idle-timeout 30 \
  --scale-settings '{"request_delay_threshold": 1, "min_replicas": 0, "max_replicas": 3}' \
  --env PYTHONUNBUFFERED=1
```

## ⚡ Benefits
- **Build time**: 10-15 minutes vs days of uploading
- **Uses RunPod's fast internet**: Their bandwidth, not yours
- **Version control**: Easy updates via git push
- **No local Docker issues**: No daemon crashes or EOF errors

## 🔧 Prerequisites
1. GitHub account
2. RunPod account with API key
3. `runpodctl` installed
