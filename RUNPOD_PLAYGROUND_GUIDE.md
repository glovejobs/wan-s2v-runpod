# 🎮 RunPod Playground Guide for WAN S2V

## 🚀 **Finding the RunPod Playground**

RunPod provides a web-based playground interface for testing your endpoints without writing code!

### **Step 1: Access Your Endpoint**
1. **Go to**: https://console.runpod.io/serverless (should be open now)
2. **Find**: Your `wan-s2v-runpod` endpoint
3. **Click** on the endpoint name to open details

### **Step 2: Look for Testing Interface**
Once inside your endpoint, look for these tabs/sections:
- **"Test"** tab
- **"Playground"** section
- **"Try it out"** button
- **"API"** or **"Testing"** interface

---

## 🎯 **Using the Playground**

### **What You'll See:**
The playground typically provides:
- 📝 **Input Fields** for your model parameters
- 🎮 **Interactive Form** to fill in values
- 🚀 **Send Request** button
- 📊 **Response Display** area
- ⏱️ **Execution Time** tracking

### **Common Input Fields for WAN S2V:**
```json
{
  "prompt": "A person speaking professionally",
  "resolution": "512*512",
  "num_inference_steps": 25,
  "guidance_scale": 7.5,
  "audio_file": "data:audio/wav;base64,UklGRi...",
  "image_file": "data:image/jpeg;base64,/9j/4AAQ..."
}
```

---

## 🎵 **Testing with Sample Data**

### **Option 1: Use Playground's Built-in Samples**
Many RunPod playgrounds include:
- Sample audio files
- Sample images  
- Pre-filled prompts
- Default parameters

### **Option 2: Upload Your Own Files**
If the playground supports file uploads:
1. **Upload Audio**: WAV or MP3 file
2. **Upload Image**: JPG or PNG file
3. **Set Prompt**: Describe desired video
4. **Click Test**: Send the request

### **Option 3: Use Base64 Encoded Data**
Copy these sample values:

**Sample Audio (minimal WAV):**
```
data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=
```

**Sample Image (1x1 pixel JPEG):**
```
data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=
```

---

## 🔍 **If No Playground Exists**

Some endpoints may not have a built-in playground. In that case:

### **Alternative 1: API Documentation**
Look for:
- **"API"** tab
- **"Documentation"** section
- **Sample requests** and **curl commands**

### **Alternative 2: Create Simple HTML Tester**
I can create a simple web interface for you:

```html
<!DOCTYPE html>
<html>
<head>
    <title>WAN S2V Tester</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        textarea { width: 100%; height: 100px; margin: 10px 0; }
        input[type="text"] { width: 100%; margin: 5px 0; }
        button { background: #007cba; color: white; padding: 10px 20px; border: none; border-radius: 5px; }
        .result { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>🎥 WAN S2V Playground</h1>
    
    <div>
        <label>Endpoint URL:</label>
        <input type="text" id="endpoint" placeholder="https://api.runpod.ai/v2/YOUR_ENDPOINT_ID">
    </div>
    
    <div>
        <label>Prompt:</label>
        <input type="text" id="prompt" value="A person speaking professionally" placeholder="Describe the video you want">
    </div>
    
    <div>
        <label>Audio File (Base64):</label>
        <textarea id="audio" placeholder="data:audio/wav;base64,UklGRi...">data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=</textarea>
    </div>
    
    <div>
        <label>Image File (Base64):</label>
        <textarea id="image" placeholder="data:image/jpeg;base64,/9j/4AAQ...">data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=</textarea>
    </div>
    
    <button onclick="testEndpoint()">🚀 Test Model</button>
    
    <div id="result" class="result" style="display:none;">
        <h3>📊 Result:</h3>
        <pre id="output"></pre>
    </div>
    
    <script>
        async function testEndpoint() {
            const endpoint = document.getElementById('endpoint').value;
            const prompt = document.getElementById('prompt').value;
            const audio = document.getElementById('audio').value;
            const image = document.getElementById('image').value;
            
            if (!endpoint) {
                alert('Please enter your endpoint URL');
                return;
            }
            
            const payload = {
                input: {
                    prompt: prompt,
                    resolution: "512*512",
                    audio_file: audio,
                    image_file: image,
                    num_inference_steps: 25,
                    guidance_scale: 7.5
                }
            };
            
            try {
                document.getElementById('output').textContent = 'Sending request...';
                document.getElementById('result').style.display = 'block';
                
                const response = await fetch(endpoint + '/runsync', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer rpa_VO0LZMIM1CQD3GNBYARJ4B4X6ET4K6DY197FND7Ovhrdv4'
                    },
                    body: JSON.stringify(payload)
                });
                
                const result = await response.json();
                document.getElementById('output').textContent = JSON.stringify(result, null, 2);
                
            } catch (error) {
                document.getElementById('output').textContent = 'Error: ' + error.message;
            }
        }
    </script>
</body>
</html>
```

---

## 📊 **Playground Features to Look For**

### **Input Section:**
- 📝 Text inputs for prompts
- 📁 File upload buttons
- 🎛️ Parameter sliders
- 📋 Sample data buttons

### **Output Section:**
- 🎥 Video preview/download
- 📊 Response JSON
- ⏱️ Execution time
- 📈 Token/cost usage

### **Controls:**
- 🚀 **Run/Execute** button
- 🔄 **Reset** form
- 💾 **Save** configurations
- 📤 **Export** results

---

## 🎯 **What to Test First**

### **Minimal Test:**
1. **Use default values** in playground
2. **Click Run/Execute**
3. **Wait for response** (30-60 seconds first time)
4. **Check if video is generated**

### **Custom Test:**
1. **Upload your audio file**
2. **Upload your image file**  
3. **Write custom prompt**
4. **Adjust parameters**
5. **Generate video**

---

## 💡 **Pro Tips for Playground**

1. **Start simple** - use default values first
2. **First request is slow** - cold start is normal
3. **Check file formats** - ensure audio is WAV, image is JPG/PNG
4. **Monitor costs** - each request uses compute time
5. **Save successful configs** - for reuse later

---

## 🔧 **If Playground Doesn't Work**

1. **Check endpoint status** - must be "Active"
2. **Verify API key** - check permissions
3. **Try smaller files** - reduce file sizes
4. **Check browser console** - for JavaScript errors
5. **Use curl/API directly** - as backup testing method

---

## 🎉 **Expected First Success**

When the playground works, you should see:
- ✅ **Status**: "COMPLETED"
- 🎥 **Output**: Video file or URL
- ⏱️ **Time**: 30-60 seconds initially
- 💰 **Cost**: Small amount charged

**The playground is the easiest way to test your model!** 🚀
