# 🚀 RunPod Template Setup (Final Step!)

Your code is now on GitHub: **https://github.com/glovejobs/wan-s2v-runpod**

## Quick RunPod Template Creation

### 1. Go to RunPod Console
**URL**: https://console.runpod.io/templates

### 2. Create New Template
- Click **"New Template"**
- Select **"Build from GitHub"**

### 3. Template Configuration
```
Template Name: WAN-S2V-14B-Serverless
Description: WAN 2.2 S2V model for speech-to-video generation

GitHub Repository: https://github.com/glovejobs/wan-s2v-runpod
Branch: main
Dockerfile Path: Dockerfile.runpod

Container Configuration:
- Container Registry: Docker Hub
- Repository Name: glovejobs/wan-s2v-14b-auto
- Tag: latest

Environment Variables:
- PYTHONUNBUFFERED=1
- HF_HOME=/tmp
- (Add HF_TOKEN if you need access to gated models)

Ports:
- Container Port: 8000
- Expose Port: 8000
- Protocol: HTTP
```

### 4. Build Settings
```
Build Arguments: (if needed)
- HF_TOKEN=your_hugging_face_token

Resource Limits:
- CPU: 4 cores
- RAM: 16GB
- GPU: Auto-detect from code
```

### 5. Save Template
Click **"Save Template"**

RunPod will now:
1. ✅ Clone your GitHub repo (seconds)
2. ✅ Build Docker image on their infrastructure (10-15 minutes)
3. ✅ Create the template for serverless deployment

## Next: Create Serverless Endpoint

Once template is built, deploy with:

```bash
runpodctl project serverless create-endpoint \
  --name "wan2v-s2v-14b" \
  --template-id "TEMPLATE_ID_FROM_CONSOLE" \
  --gpu "NVIDIA GeForce RTX 4090" \
  --idle-timeout 30 \
  --scale-settings '{"request_delay_threshold": 1, "min_replicas": 0, "max_replicas": 3}'
```

## 🎉 You're Done!
- **No more Docker push issues**
- **No more 26.8GB uploads**
- **Total time: ~15 minutes instead of days**
