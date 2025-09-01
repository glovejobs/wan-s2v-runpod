#!/bin/bash

# Docker Push Recovery Script for Large Images (26.8GB)
# Handles daemon connectivity issues and provides multiple push strategies

IMAGE_NAME="glovejobs/wan2v-s2v-14b:latest"

echo "🔧 Docker Push Recovery for Large Image"
echo "======================================="
echo "Image: $IMAGE_NAME (26.8GB)"
echo ""

# Function to check Docker daemon status
check_docker_daemon() {
    if docker version >/dev/null 2>&1; then
        echo "✅ Docker daemon is running"
        return 0
    else
        echo "❌ Docker daemon is not accessible"
        return 1
    fi
}

# Function to start Docker and wait for it to be ready
start_docker_and_wait() {
    echo "🚀 Starting Docker Desktop..."
    open -a Docker
    
    echo "⏳ Waiting for Docker daemon to be ready..."
    for i in {1..12}; do
        sleep 10
        if check_docker_daemon; then
            echo "✅ Docker daemon is ready after $((i*10)) seconds"
            return 0
        fi
        echo "   Still waiting... (attempt $i/12)"
    done
    
    echo "❌ Docker daemon failed to start after 120 seconds"
    return 1
}

# Function to check available disk space
check_disk_space() {
    echo "💾 Checking available disk space..."
    df -h . | tail -1 | awk '{print "Available space: " $4}'
    
    # Check if we have at least 30GB free (image is 26.8GB)
    available=$(df . | tail -1 | awk '{print $4}')
    required=31457280  # 30GB in KB
    
    if [ $available -lt $required ]; then
        echo "⚠️  WARNING: Low disk space detected. Consider freeing up space."
        echo "   Required: ~30GB, Available: $(($available/1024/1024))GB"
    fi
}

# Function to optimize Docker settings for large pushes
optimize_docker_settings() {
    echo "⚙️  Optimizing Docker for large image push..."
    
    echo "   Current Docker resource usage:"
    docker system df 2>/dev/null || echo "   Unable to check Docker disk usage"
    
    echo "   Consider these optimizations:"
    echo "   - Close other applications to free RAM"
    echo "   - Ensure stable internet connection"
    echo "   - Push during off-peak hours"
}

# Function to attempt push with progress monitoring
push_with_monitoring() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo ""
        echo "📤 Push attempt $attempt of $max_attempts..."
        echo "   This may take 30-60 minutes for a 26.8GB image"
        echo "   Progress will show layer-by-layer uploads"
        echo ""
        
        # Use timeout to prevent hanging
        timeout 3600 docker push $IMAGE_NAME
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo "✅ Push completed successfully!"
            return 0
        elif [ $exit_code -eq 124 ]; then
            echo "⏱️  Push timed out after 1 hour"
        else
            echo "❌ Push failed with exit code: $exit_code"
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            echo "   Waiting 60 seconds before retry..."
            sleep 60
            
            # Check if daemon is still running
            if ! check_docker_daemon; then
                echo "   Docker daemon disconnected, restarting..."
                start_docker_and_wait || return 1
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    echo "❌ All push attempts failed"
    return 1
}

# Main execution
echo "🔍 Pre-flight checks..."

# Check current status
if check_docker_daemon; then
    echo "✅ Docker daemon is already running"
else
    start_docker_and_wait || {
        echo "❌ Failed to start Docker daemon"
        echo ""
        echo "🛠️  Troubleshooting suggestions:"
        echo "   1. Restart Docker Desktop manually"
        echo "   2. Increase Docker Desktop memory allocation (Preferences > Resources)"
        echo "   3. Close other applications to free system resources"
        echo "   4. Check available disk space"
        exit 1
    }
fi

check_disk_space
optimize_docker_settings

# Check if we're logged in
echo ""
echo "🔐 Checking Docker Hub authentication..."
if docker info | grep -q "Username"; then
    echo "✅ Already authenticated to Docker Hub"
else
    echo "🔑 Logging in to Docker Hub..."
    docker login || {
        echo "❌ Failed to login to Docker Hub"
        exit 1
    }
fi

# Verify image exists
echo ""
echo "🖼️  Verifying image exists locally..."
if docker images | grep -q "$IMAGE_NAME"; then
    echo "✅ Image found: $IMAGE_NAME"
    docker images | grep "glovejobs/wan2v-s2v-14b"
else
    echo "❌ Image not found locally"
    exit 1
fi

echo ""
echo "🚀 Starting optimized push process..."
echo "   Image size: 26.8GB"
echo "   Expected time: 30-60 minutes"
echo "   Many layers already exist and will be skipped"
echo ""

# Attempt the push
if push_with_monitoring; then
    echo ""
    echo "🎉 SUCCESS! Image pushed to Docker Hub"
    echo "📍 Image location: docker.io/$IMAGE_NAME"
    echo ""
    echo "🚀 Next steps for RunPod deployment:"
    echo "   1. Use the deployed script: ./deploy_runpod.sh"
    echo "   2. Or run the RunPod command manually with the pushed image"
    echo "   3. Monitor the RunPod console for endpoint creation"
else
    echo ""
    echo "❌ FAILED: Could not complete push after multiple attempts"
    echo ""
    echo "🔧 Alternative solutions:"
    echo "   1. Try during off-peak hours (better bandwidth)"
    echo "   2. Use Docker BuildKit with registry cache"
    echo "   3. Consider pushing from a server with better bandwidth"
    echo "   4. Split the image into smaller layers if possible"
    echo ""
    echo "📞 For RunPod deployment, you can also:"
    echo "   - Build directly on RunPod infrastructure"
    echo "   - Use their GitHub integration"
fi
