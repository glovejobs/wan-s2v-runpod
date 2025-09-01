#!/bin/bash

# RunPod Direct Build - No Docker Push Required!
# This uses RunPod's infrastructure to build your image

echo "🚀 RunPod Direct Build Deployment"
echo "================================="
echo ""

# Check if runpodctl is installed
if ! command -v runpodctl &> /dev/null; then
    echo "📦 Installing runpodctl..."
    curl -sL https://runpod.io/install-runpodctl | bash
    export PATH="$HOME/.local/bin:$PATH"
fi

# Check authentication
echo "🔐 Checking RunPod authentication..."
if ! runpodctl config list &> /dev/null; then
    echo "❌ Not logged in to RunPod"
    echo "Run: runpodctl config --apiKey YOUR_API_KEY"
    echo "Get your API key from: https://console.runpod.io/user/settings"
    exit 1
fi

echo "✅ RunPod authentication verified"
echo ""

# Create optimized Dockerfile for cloud builds
echo "🐳 Creating optimized Dockerfile for RunPod builds..."

cat > Dockerfile.runpod << 'EOF'
# Optimized Dockerfile for RunPod Cloud Builds
FROM nvidia/cuda:11.8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV HF_HOME=/tmp

# Install system dependencies in one layer
RUN apt-get update && apt-get install -y \
    python3 python3-pip git wget curl \
    libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (for better layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["python3", "handler.py"]
EOF

echo "✅ Created optimized Dockerfile.runpod"
echo ""

echo "📋 RunPod Build Options:"
echo ""
echo "OPTION 1: GitHub Integration (Recommended)"
echo "==========================================="
echo "1. Push your code to GitHub:"
echo "   git add ."
echo "   git commit -m 'WAN S2V for RunPod'"
echo "   git push origin main"
echo ""
echo "2. Create template in RunPod Console:"
echo "   → Go to https://console.runpod.io/templates"
echo "   → Click 'New Template'"
echo "   → Select 'Build from GitHub'"
echo "   → Enter your repo URL"
echo "   → Set Dockerfile path: Dockerfile.runpod"
echo ""

echo "OPTION 2: RunPod CLI Build Service"
echo "=================================="
echo "Create a build job that runs on RunPod infrastructure:"
echo ""

cat << 'EOF'
# Create build job config
cat > build_config.yaml << 'YAML'
apiVersion: v1
kind: BuildJob
metadata:
  name: wan-s2v-build
spec:
  source:
    type: local
    path: .
  dockerfile: Dockerfile.runpod
  target: wan2v-s2v-14b-serverless
  push:
    registry: docker.io
    repository: glovejobs/wan2v-s2v-14b
    tag: latest
YAML

# Submit build job to RunPod
runpodctl project build create --config build_config.yaml
EOF

echo ""
echo "OPTION 3: Direct Upload (Faster than Docker Push)"
echo "================================================="
echo "Use RunPod's file upload service for faster deployment:"
echo ""

cat << 'EOF'
# Create deployment package
tar -czf wan2v-deployment.tar.gz \
  --exclude='*.git*' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='node_modules' \
  .

# Upload to RunPod storage
runpodctl storage upload wan2v-deployment.tar.gz

# Create serverless endpoint from uploaded package
runpodctl project serverless create-endpoint \
  --name "wan2v-s2v-14b-direct" \
  --source-type "storage" \
  --source-path "wan2v-deployment.tar.gz" \
  --gpu "NVIDIA GeForce RTX 4090" \
  --idle-timeout 30
EOF

echo ""
echo "🎯 RECOMMENDED NEXT STEPS:"
echo "========================="
echo "1. Use OPTION 1 (GitHub Integration) - fastest and most reliable"
echo "2. Your code uploads in seconds instead of hours"
echo "3. RunPod builds on their fast infrastructure"
echo "4. No more Docker daemon issues on your machine!"
echo ""
echo "💡 Want me to help set up the GitHub integration now?"
