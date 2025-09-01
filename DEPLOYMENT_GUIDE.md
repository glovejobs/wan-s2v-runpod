# Wan2.2-S2V-14B Deployment on Thunder Compute

This guide walks you through deploying the Wan2.2-S2V-14B model on Thunder Compute's cloud GPU platform.

## Prerequisites

1. **Thunder Compute Account Setup**:
   - Sign up at [Thunder Compute Console](https://console.thundercompute.com/)
   - Add a payment method to your account
   - Generate an API token from the console

2. **Local Setup**:
   - Thunder Compute CLI (`tnr`) is already installed at `/usr/local/bin/tnr`
   - Deployment scripts are ready in this directory

## Quick Start

### Step 1: Create Thunder Compute Instance

1. **Via Console (Recommended)**:
   - Go to [Thunder Compute Console](https://console.thundercompute.com/)
   - Click "Create Instance"
   - Select **H100 80GB GPU** (required for this 14B model)
   - Choose PyTorch/ML framework image
   - Set instance name: `wan-s2v-14b`

2. **Via CLI** (alternative):
   ```bash
   # Login to Thunder Compute
   tnr login
   
   # Create H100 instance
   tnr create instance --name wan-s2v-14b --gpu h100-80gb --image pytorch
   ```

### Step 2: Deploy the Model

Once your instance is running:

1. **Connect via SSH or VSCode Extension**:
   - Use the connection details from the Thunder Compute console
   - Or install the Thunder Compute VSCode extension for integrated development

2. **Upload and Run Deployment Script**:
   ```bash
   # Upload the deployment script to your instance
   scp deploy_wan_model.sh user@your-instance-ip:/workspace/
   
   # SSH into your instance
   ssh user@your-instance-ip
   
   # Run deployment
   cd /workspace
   chmod +x deploy_wan_model.sh
   ./deploy_wan_model.sh
   ```

### Step 3: Start the API Server

After deployment completes:

1. **Upload API script**:
   ```bash
   # From your local machine
   scp setup_api_access.py user@your-instance-ip:/workspace/
   ```

2. **Install Flask and start server**:
   ```bash
   # On the instance
   pip install flask
   python setup_api_access.py
   ```

3. **Access your API**:
   - API will be available at `http://your-instance-ip:5000`
   - Visit `http://your-instance-ip:5000/` for API documentation

## API Usage Examples

### Health Check
```bash
curl http://your-instance-ip:5000/health
```

### Generate Video
```bash
curl -X POST http://your-instance-ip:5000/generate \
  -F "audio_file=@sample_audio.wav" \
  -F "image_file=@portrait.jpg" \
  -F "prompt=A person speaking enthusiastically" \
  -F "resolution=1024*704"
```

### Check Status
```bash
curl http://your-instance-ip:5000/status/your-request-id
```

### Download Result
```bash
curl http://your-instance-ip:5000/download/your-request-id -o generated_video.mp4
```

## Python Client Example

```python
import requests

# API base URL
api_url = "http://your-instance-ip:5000"

# Generate video
files = {
    'audio_file': open('input_audio.wav', 'rb'),
    'image_file': open('input_image.jpg', 'rb')
}
data = {
    'prompt': 'A person giving a presentation',
    'resolution': '1024*704'
}

response = requests.post(f"{api_url}/generate", files=files, data=data)
result = response.json()

if result.get('success'):
    request_id = result['request_id']
    
    # Check status
    status_response = requests.get(f"{api_url}/status/{request_id}")
    
    # Download when ready
    if status_response.json().get('status') == 'completed':
        video_response = requests.get(f"{api_url}/download/{request_id}")
        with open('output_video.mp4', 'wb') as f:
            f.write(video_response.content)
```

## Performance Notes

### Hardware Requirements
- **GPU**: H100 80GB (recommended)
- **RAM**: 32GB+ system RAM
- **Storage**: 100GB+ for model and outputs

### Generation Times (H100 80GB)
- **720p, 5 seconds**: ~5-8 minutes
- **1024x704, 5 seconds**: ~8-12 minutes
- **Higher resolutions**: Proportionally longer

### Cost Optimization
- **Spot Instances**: Use Thunder Compute spot instances for 50-80% cost savings
- **Auto-shutdown**: Configure auto-shutdown after idle periods
- **Batch Processing**: Process multiple requests together

## Troubleshooting

### Common Issues

1. **Out of Memory Error**:
   ```bash
   # Check GPU memory
   nvidia-smi
   
   # Reduce batch size or resolution
   # Use model offloading (already enabled in our setup)
   ```

2. **Model Download Fails**:
   ```bash
   # Check Hugging Face token
   huggingface-cli login
   
   # Retry download
   huggingface-cli download IDEA-Research/Wan2.2-S2V-14B
   ```

3. **API Server Won't Start**:
   ```bash
   # Check port availability
   netstat -tulpn | grep :5000
   
   # Install missing dependencies
   pip install flask
   ```

4. **Generation Takes Too Long**:
   - Verify H100 GPU is being used: `nvidia-smi`
   - Check that CUDA is properly configured
   - Consider using lower resolution for testing

### Thunder Compute Specific

1. **Instance Connection Issues**:
   - Check instance status in console
   - Verify SSH keys are configured
   - Try the VSCode extension for easier access

2. **Billing Questions**:
   - Check usage in Thunder Compute console
   - Set up billing alerts
   - Consider spot instances for development

## File Structure

```
/workspace/
├── wan-s2v-14b/           # Main installation directory
│   ├── Wan2.2/           # Cloned repository
│   └── conda_env/        # Conda environment
├── setup_api_access.py   # API server
├── outputs/              # Generated videos
└── logs/                 # System logs
```

## Next Steps

1. **Production Deployment**:
   - Set up load balancing for multiple instances
   - Implement request queuing system
   - Add authentication and rate limiting

2. **Performance Optimization**:
   - Experiment with different model configurations
   - Implement model caching strategies
   - Consider multi-GPU setups for higher throughput

3. **Integration**:
   - Create SDKs for different languages
   - Set up monitoring and alerting
   - Implement automated deployment pipelines

## Support

- **Thunder Compute**: [Documentation](https://www.thundercompute.com/docs/quickstart)
- **Wan2.2 Model**: [Hugging Face](https://huggingface.co/IDEA-Research/Wan2.2-S2V-14B)
- **Issues**: Check the deployment logs in `/workspace/logs/`

---

**Estimated Setup Time**: 30-45 minutes  
**First Generation**: 5-10 minutes  
**GPU Requirement**: H100 80GB minimum
