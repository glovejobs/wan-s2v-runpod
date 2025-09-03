# 🚀 RunPod WAN S2V Deployment Guide (Cost-Optimized)

## Prerequisites
- RunPod account: https://runpod.io
- Your code pushed to GitHub (or use our scripts)
- RunPod CLI configured

## 🛠️ Step 1: Configure RunPod CLI

Get your API key from: https://runpod.io/console/user/settings

```bash
runpodctl config --apiKey YOUR_RUNPOD_API_KEY
```

## 📦 Step 2: Check Your Deployment Files

Make sure you have these key files ready:

```bash
ls -la
# Should show:
# - runpod_handler.py
# - generate.py  
# - Dockerfile
# - requirements.txt
```

## 🚀 Step 3: Deploy with Cost Optimization

### Option A: CLI Deployment (Recommended)

```bash
# Deploy with correct scaling settings
runpodctl project deploy \
  --name wan-s2v-optimized \
  --cudaVersion 12.1 \
  --pythonVersion 3.11 \
  --containerDiskSize 50 \
  --ports "8000/http" \
  --env PYTHONUNBUFFERED=1 \
  --env MODEL_CACHE_SIZE=20GB
```

### Option B: Manual Console Deployment

1. Go to: https://runpod.io/console/serverless
2. Click "New Endpoint"
3. Choose "Build New"

**Critical Settings:**
```yaml
Container Image: From GitHub
Repository: YOUR_GITHUB_REPO
Branch: main
Container Start Command: python runpod_handler.py

# COST OPTIMIZATION SETTINGS (CRITICAL):
Min Workers: 0          # ⚠️  MUST BE 0!
Max Workers: 2          # Limit concurrent instances  
Idle Timeout: 30        # Scale down after 30 seconds
Scale to Zero: ✅ ON    # Enable automatic scaling
Always On: ❌ OFF       # Disable always-on mode

# GPU Settings:
GPU Type: RTX 4090      # Cost-effective for WAN S2V
Container Disk: 50GB    # Space for model
Memory: 32GB           # Sufficient for 14B model
```

## ⚙️ Step 4: Environment Variables

Set these in RunPod console:

```bash
PYTHONUNBUFFERED=1
HF_HUB_ENABLE_HF_TRANSFER=1
MODEL_PATH=/runpod-volume/models
FORCE_CPU_OFFLOAD=true
```

## 🧪 Step 5: Test Your Deployment

After deployment completes:

### Quick Health Check
```bash
curl -X GET "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/health"
```

### Test Generation
```bash
python test_runpod_endpoint.py YOUR_ENDPOINT_URL
```

Or use the HTML playground:
```bash
open wan_s2v_playground.html
# Update endpoint URL in the file
```

## 💰 Step 6: Monitor Costs

### Set Billing Alerts
1. Go to: https://runpod.io/console/billing
2. Set alert at $50/month
3. Monitor daily for first week

### Expected Costs
- **With proper scaling**: $10-100/month
- **If workers stay running**: $800+/month
- **First sign of trouble**: Daily cost >$25

## 🔧 Step 7: Troubleshooting

### If Workers Won't Scale Down:
```bash
# Check endpoint status
runpodctl get endpoint

# Force scale down (if needed)
curl -X POST "https://api.runpod.io/v2/YOUR_ENDPOINT_ID/scale" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"minWorkers": 0, "maxWorkers": 1}'
```

### If Generation Fails:
1. Check logs in RunPod console
2. Verify generate.py is accessible
3. Check model download status
4. Test with simpler payload first

## 📋 Complete Deployment Checklist

- [ ] RunPod CLI configured
- [ ] Code pushed to GitHub
- [ ] Endpoint created with correct settings
- [ ] **Min Workers = 0** ✅
- [ ] **Scale to Zero = ON** ✅  
- [ ] **Always On = OFF** ✅
- [ ] Billing alerts set
- [ ] Test endpoint working
- [ ] Cost monitoring active

## 🎯 Success Criteria

After 24 hours:
- ✅ Endpoint responds to requests
- ✅ Workers scale to zero when idle
- ✅ Daily cost under $5 (unless heavy usage)
- ✅ Video generation works

## 🆘 Emergency Cost Control

If costs spike:
1. **Immediately**: Set Max Workers to 0 in console
2. **Check**: Active workers count
3. **Investigate**: What's keeping workers alive
4. **Fix**: Scaling settings
5. **Resume**: Once identified and fixed

---

## 🎉 Expected Results

**With proper configuration:**
- Cold start: ~30 seconds
- Generation time: ~45-90 seconds  
- Cost per generation: ~$0.05-0.15
- Monthly cost (100 videos): ~$50-150
- Scale to zero: ✅ Actually works

**This saves you $600-700/month vs. broken scaling!**
