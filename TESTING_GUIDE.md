# 🧪 Testing Your RunPod WAN S2V Deployment

## 📊 **Step 1: Check Deployment Status**

### Option A: RunPod Web Console (Recommended)
1. **Go to**: https://console.runpod.io/serverless
2. **Find**: Your `wan-s2v-runpod` endpoint
3. **Check Status**:
   - 🔄 **Building/Pending** = Still deploying (wait 5-10 more minutes)
   - ✅ **Active/Ready** = Ready to test!
   - ❌ **Failed** = Check build logs

### Option B: RunPod CLI
```bash
# Check if there are any project deployments
~/.local/bin/runpodctl project
```

---

## 🎯 **Step 2: Get Your Endpoint URL**

Once your endpoint shows as **"Active"** or **"Ready"**:

1. **Click on your endpoint** in the RunPod console
2. **Copy the endpoint URL** - it looks like:
   ```
   https://api.runpod.ai/v2/YOUR_ENDPOINT_ID
   ```
3. **Save this URL** - you'll need it for testing!

---

## 🧪 **Step 3: Test Your Endpoint**

### Quick Test with curl
```bash
# Replace YOUR_ENDPOINT_URL with your actual endpoint URL
curl -X POST "YOUR_ENDPOINT_URL/runsync" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_RUNPOD_API_KEY" \
  -d '{
    "input": {
      "prompt": "A person speaking in a professional setting",
      "resolution": "512*512",
      "audio_file": "data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=",
      "image_file": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="
    }
  }'
```

### Test with Python Script (if requests is available)
```bash
# First, install requests in a virtual environment
python3 -m venv test_env
source test_env/bin/activate
pip install requests

# Then edit and run the test script
python test_runpod_endpoint.py YOUR_ENDPOINT_URL
```

---

## 📋 **Expected Results**

### ✅ **SUCCESS Response**
```json
{
  "status": "COMPLETED",
  "output": {
    "video_url": "https://...",
    "video_base64": "...",
    "metadata": {...}
  }
}
```

### ⚠️ **Common Issues & Solutions**

#### 1. **Cold Start (First Request)**
- **Symptom**: Request takes 30-60 seconds
- **Solution**: This is normal! First request initializes the model
- **Action**: Wait and try again - subsequent requests will be faster

#### 2. **Timeout Errors**
- **Symptom**: Request times out after 5 minutes
- **Solution**: Model may still be loading
- **Action**: Check RunPod console for endpoint status

#### 3. **Authentication Errors**
- **Symptom**: `401 Unauthorized`
- **Solution**: Check your API key
- **Action**: Verify the Bearer token in your request

#### 4. **Model Loading Errors**
- **Symptom**: `500 Internal Server Error`
- **Solution**: Check build logs in RunPod console
- **Action**: May need to rebuild if dependencies failed

---

## 🎥 **Step 4: Testing with Real Files**

### Upload Your Own Audio/Image
```python
import base64

# Encode your audio file
with open("your_audio.wav", "rb") as f:
    audio_b64 = base64.b64encode(f.read()).decode()

# Encode your image file  
with open("your_image.jpg", "rb") as f:
    image_b64 = base64.b64encode(f.read()).decode()

# Use in your API request
payload = {
    "input": {
        "prompt": "Your custom prompt here",
        "audio_file": f"data:audio/wav;base64,{audio_b64}",
        "image_file": f"data:image/jpeg;base64,{image_b64}",
        "resolution": "512*512",
        "num_inference_steps": 25
    }
}
```

---

## 📊 **Step 5: Performance Monitoring**

### Check Endpoint Metrics
1. **Go to**: RunPod Console → Your Endpoint
2. **Click**: "Metrics" tab
3. **Monitor**:
   - Request count
   - Average response time
   - Error rate
   - GPU utilization

### Scaling Settings
- **Min Replicas**: 0 (cost-effective)
- **Max Replicas**: 3 (good performance)
- **Idle Timeout**: 30 seconds

---

## 🎉 **Success Indicators**

### ✅ **Your deployment is working if:**
1. Endpoint status shows "Active/Ready"
2. Health check returns 200 OK
3. Test request returns video output
4. Response time is reasonable (< 60 seconds after first request)

### 🚀 **Performance Expectations:**
- **First Request**: 30-60 seconds (cold start)
- **Subsequent Requests**: 5-15 seconds
- **Cost**: Only pay for inference time, not idle time!

---

## 🔧 **Troubleshooting**

### If Tests Fail:
1. **Check build logs** in RunPod console
2. **Verify endpoint URL** is correct
3. **Check API key** permissions
4. **Monitor resource usage** (GPU memory, etc.)

### Get Help:
- **RunPod Console**: https://console.runpod.io/serverless
- **Build Logs**: Click on your endpoint → Logs tab
- **Community**: RunPod Discord or documentation

---

## 💡 **Pro Tips**

1. **First request is always slow** - this is normal for serverless
2. **Test with small files first** to verify functionality
3. **Monitor costs** in RunPod billing dashboard
4. **Scale up max replicas** if you need higher throughput
5. **Use health checks** to verify endpoint availability

---

## 🎯 **Next Steps After Testing**

Once your endpoint works:
1. **Integrate into your application**
2. **Set up monitoring and alerts**
3. **Optimize parameters** for your use case
4. **Scale based on usage patterns**

**Remember**: This deployment method is **100x faster** than the Docker push approach that was taking days! 🚀
