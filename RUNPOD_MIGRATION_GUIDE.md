# Migration Guide: Thunder Compute → RunPod Serverless

**Save 60-90% on your Wan2.2-S2V-14B deployment costs!**

This guide helps you migrate from Thunder Compute's expensive always-on instances to RunPod's cost-effective serverless platform.

## 💰 Cost Comparison

### Thunder Compute (Current)
- **H100 80GB**: ~$3.50-4.00/hour
- **Always running**: ~$2,520-2,880/month
- **Idle time costs**: You pay even when not generating videos
- **Minimum billing**: Usually 1-hour increments

### RunPod Serverless (New)
- **RTX 4090**: ~$0.0012/second (~$4.32/hour when active)
- **A100 40GB**: ~$0.0018/second (~$6.48/hour when active)  
- **Pay per use**: Only pay for actual inference time
- **No idle costs**: $0 when not in use
- **Sub-second billing**: Pay for exactly what you use

### Real-World Savings Example
**Scenario**: 20 videos per day, 5 minutes generation each

| Platform | Daily Cost | Monthly Cost | Annual Cost |
|----------|------------|--------------|-------------|
| Thunder Compute | $84-96 | $2,520-2,880 | $30,240-34,560 |
| RunPod Serverless | $3.60-5.40 | $108-162 | $1,296-1,944 |
| **Savings** | **$80-91** | **$2,358-2,718** | **$28,296-32,616** |

**Savings: 85-95%** 🎉

## 🚀 Quick Migration Steps

### Step 1: Setup RunPod Account
1. Sign up at [RunPod Console](https://console.runpod.io/)
2. Add payment method
3. Generate API key from Settings
4. Install runpodctl: `curl -sL https://runpod.io/install-runpodctl | bash`
5. Login: `runpodctl config --apiKey YOUR_API_KEY`

### Step 2: Deploy to RunPod
```bash
# In your project directory
chmod +x deploy_runpod.sh
./deploy_runpod.sh
```

The script will:
- Build your Docker container
- Guide you through registry setup
- Create the serverless endpoint
- Provide testing examples

### Step 3: Update Your Applications
Replace Thunder Compute API calls with RunPod endpoints:

**Before (Thunder Compute)**:
```python
# POST to http://your-instance-ip:5000/generate
files = {
    'audio_file': open('audio.wav', 'rb'),
    'image_file': open('image.jpg', 'rb')
}
response = requests.post(f"{instance_url}/generate", files=files, data=data)
```

**After (RunPod Serverless)**:
```python
# POST to https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync
import base64

with open('audio.wav', 'rb') as f:
    audio_b64 = base64.b64encode(f.read()).decode()
with open('image.jpg', 'rb') as f:
    image_b64 = base64.b64encode(f.read()).decode()

payload = {
    "input": {
        "audio_file": audio_b64,
        "image_file": image_b64,
        "prompt": "A person speaking",
        "resolution": "1024*704"
    }
}

response = requests.post(endpoint_url, json=payload, headers=headers)
```

### Step 4: Test and Validate
```bash
# Test your new endpoint
python runpod_client_examples.py
```

## 📋 Detailed Migration Checklist

### Pre-Migration
- [ ] Sign up for RunPod account
- [ ] Install Docker on your machine
- [ ] Get Hugging Face token (if model is gated)
- [ ] Choose Docker registry (Docker Hub recommended)
- [ ] Test current Thunder Compute setup one last time

### Migration Process
- [ ] Run `./deploy_runpod.sh`
- [ ] Build and test Docker image locally
- [ ] Push image to registry
- [ ] Create RunPod serverless endpoint
- [ ] Test endpoint with sample data
- [ ] Update client applications
- [ ] Run parallel testing (Thunder vs RunPod)

### Post-Migration
- [ ] Validate all functionality works
- [ ] Update monitoring/alerting
- [ ] Cancel Thunder Compute instances
- [ ] Document new endpoint URLs
- [ ] Train team on new API format

## 🔄 API Differences

### Input Format Changes

**Thunder Compute Flask API**:
```bash
curl -X POST http://instance:5000/generate \
  -F "audio_file=@audio.wav" \
  -F "image_file=@image.jpg" \
  -F "prompt=A person speaking"
```

**RunPod Serverless API**:
```bash
curl -X POST https://api.runpod.ai/v2/ENDPOINT_ID/runsync \
  -H "Authorization: Bearer API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "audio_file": "base64_audio_data",
      "image_file": "base64_image_data", 
      "prompt": "A person speaking"
    }
  }'
```

### Response Format Changes

**Thunder Compute Response**:
```json
{
  "success": true,
  "request_id": "uuid",
  "download_url": "/download/uuid"
}
```

**RunPod Response**:
```json
{
  "success": true,
  "request_id": "uuid",
  "video_base64": "base64_video_data",
  "generation_time_seconds": 287.5,
  "file_size_bytes": 15728640
}
```

## 🛠️ Troubleshooting

### Common Issues

**1. Model Download Fails**
```bash
# Set HF token during build
docker build --build-arg HF_TOKEN="your_token" -t wan2v-s2v-14b .
```

**2. Out of Memory**
- Switch to A100 40GB/80GB GPU
- Reduce batch size in model code
- Enable model offloading (already configured)

**3. Slow Cold Starts**
- Use RunPod's "Active Workers" feature
- Keep 1 worker warm: `"min_replicas": 1`
- Pre-warm with health checks

**4. Large Video Upload/Download**
- Videos are base64 encoded (33% size increase)
- Consider using signed URLs for large files
- Implement chunked transfer for >25MB videos

### Performance Optimization

**Reduce Costs**:
```bash
# Use smaller GPU for testing
--gpu "NVIDIA GeForce RTX 3090"

# Aggressive scaling
--scale-settings '{"min_replicas": 0, "max_replicas": 5, "idle_timeout": 15}'
```

**Improve Speed**:
```bash
# Keep workers warm
--scale-settings '{"min_replicas": 1, "max_replicas": 10}'

# Use faster GPU
--gpu "NVIDIA A100 80GB PCIe"
```

## 📊 Monitoring & Analytics

### RunPod Dashboard
- Real-time usage metrics
- Cost tracking
- Error rates and logs
- Performance analytics

### Cost Monitoring
```python
# Track your usage
import runpod

# Get usage stats
usage = runpod.get_usage_stats(endpoint_id="YOUR_ENDPOINT")
print(f"Monthly cost so far: ${usage['cost']}")
print(f"Total requests: {usage['requests']}")
print(f"Avg generation time: {usage['avg_time']}s")
```

## 🔄 Rollback Plan

If you need to rollback to Thunder Compute:

1. **Keep Thunder instance for 1 week** during migration
2. **Parallel testing**: Run both systems simultaneously
3. **Quick rollback**: Switch DNS/endpoint URLs back
4. **Data backup**: Ensure all generated content is backed up

### Emergency Rollback Script
```bash
#!/bin/bash
# emergency_rollback.sh

echo "🚨 Rolling back to Thunder Compute..."

# Update environment variables
export API_ENDPOINT="http://your-thunder-instance:5000"
export API_FORMAT="multipart"  # vs "json"

# Restart applications with old config
systemctl restart your-app

echo "✅ Rollback complete"
```

## 🎯 Advanced Features

### Auto-scaling Configuration
```bash
runpodctl project serverless create-endpoint \
  --name "wan2v-production" \
  --image "your-registry/wan2v:latest" \
  --gpu "NVIDIA A100 40GB PCIe" \
  --scale-settings '{
    "min_replicas": 1,
    "max_replicas": 10,
    "request_delay_threshold": 2,
    "idle_timeout": 60,
    "scale_up_delay": 30,
    "scale_down_delay": 300
  }'
```

### Multi-Region Deployment
```bash
# Deploy to multiple regions for lower latency
runpodctl project serverless create-endpoint \
  --name "wan2v-us-east" \
  --region "us-east-1" \
  --image "your-registry/wan2v:latest"

runpodctl project serverless create-endpoint \
  --name "wan2v-eu-west" \
  --region "eu-west-1" \
  --image "your-registry/wan2v:latest"
```

### A/B Testing Setup
```python
# Route traffic between different model versions
import random

if random.random() < 0.1:  # 10% traffic
    endpoint = "wan2v-experimental"
else:
    endpoint = "wan2v-production"
```

## 📚 Additional Resources

- **RunPod Documentation**: https://docs.runpod.io/
- **Pricing Calculator**: https://www.runpod.io/pricing
- **Discord Community**: https://discord.gg/pJ3P2DbUUq
- **Status Page**: https://status.runpod.io/

## ✅ Migration Complete!

Once migrated, you should see:
- ✅ **85-95% cost reduction**
- ✅ **No idle time charges** 
- ✅ **Automatic scaling**
- ✅ **Better reliability**
- ✅ **Simpler management**

## 🆘 Need Help?

- **RunPod Support**: support@runpod.io
- **Community Discord**: https://discord.gg/pJ3P2DbUUq  
- **Documentation**: https://docs.runpod.io/serverless/overview

---

**🎉 Congratulations on saving thousands per month with RunPod Serverless!**

*This migration typically pays for itself within the first week of usage.*
