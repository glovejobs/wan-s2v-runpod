#!/bin/bash

# RunPod Serverless Deployment Script for Wan2.2-S2V-14B
# This script builds and deploys your model to RunPod Serverless

set -e

echo "🚀 RunPod Serverless Deployment for Wan2.2-S2V-14B"
echo "=================================================="

# Configuration
DOCKER_IMAGE_NAME="wan2v-s2v-14b-serverless"
RUNPOD_ENDPOINT_NAME="wan2v-s2v-14b"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
fi

# Check if runpodctl is installed
if ! command -v runpodctl &> /dev/null; then
    echo "📦 Installing runpodctl..."
    # Install runpodctl
    curl -sL https://runpod.io/install-runpodctl | bash
    # Source the shell profile to get runpodctl in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    if ! command -v runpodctl &> /dev/null; then
        print_error "Failed to install runpodctl. Please install manually: https://docs.runpod.io/cli/install-runpodctl"
    fi
fi

print_status "Prerequisites check complete"

# Check if user is logged in to RunPod
echo "🔐 Checking RunPod authentication..."
if ! runpodctl config list &> /dev/null; then
    print_warning "Not logged in to RunPod. Please login first."
    echo "Run: runpodctl config --apiKey YOUR_API_KEY"
    echo "Get your API key from: https://console.runpod.io/user/settings"
    exit 1
fi

print_status "RunPod authentication verified"

# Ask for Hugging Face token if the model is gated
read -p "🤗 Enter your Hugging Face token (press Enter if not needed): " HF_TOKEN

# Build Docker image
echo "🐳 Building Docker image..."
if [ -n "$HF_TOKEN" ]; then
    docker build --build-arg HF_TOKEN="$HF_TOKEN" -t $DOCKER_IMAGE_NAME .
else
    docker build -t $DOCKER_IMAGE_NAME .
fi

print_status "Docker image built successfully"

# Test the image locally (optional)
read -p "🧪 Test the image locally first? (y/N): " test_locally
if [[ $test_locally =~ ^[Yy]$ ]]; then
    echo "🧪 Testing image locally..."
    echo "Starting container for testing..."
    
    # Create a simple test
    cat > test_payload.json << EOF
{
    "input": {
        "audio_file": "data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=",
        "image_file": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=",
        "prompt": "Test generation",
        "resolution": "512*512"
    }
}
EOF
    
    docker run --rm --gpus all -p 8000:8000 $DOCKER_IMAGE_NAME &
    CONTAINER_PID=$!
    sleep 10
    
    # Stop the test container
    kill $CONTAINER_PID 2>/dev/null || true
    rm test_payload.json
    
    print_status "Local test completed"
fi

# Push to Docker registry (RunPod requires this)
echo "📤 Pushing to Docker registry..."

# Tag for registry (you might need to adapt this based on your registry)
REGISTRY_IMAGE="$DOCKER_IMAGE_NAME:latest"

print_warning "You need to push the image to a registry (Docker Hub, GCR, etc.)"
print_warning "For Docker Hub, run:"
echo "  docker tag $DOCKER_IMAGE_NAME yourusername/$DOCKER_IMAGE_NAME:latest"
echo "  docker push yourusername/$DOCKER_IMAGE_NAME:latest"
echo ""
read -p "Enter the full registry image name (e.g., yourusername/wan2v-s2v-14b:latest): " REGISTRY_IMAGE

if [ -z "$REGISTRY_IMAGE" ]; then
    print_error "Registry image name is required"
fi

# Create RunPod serverless endpoint
echo "🚀 Creating RunPod serverless endpoint..."

# Generate the runpodctl command
cat << EOF

📋 RunPod Serverless Endpoint Creation

To create your endpoint, run the following command:

runpodctl project serverless create-endpoint \\
  --name "$RUNPOD_ENDPOINT_NAME" \\
  --image "$REGISTRY_IMAGE" \\
  --gpu "NVIDIA GeForce RTX 4090" \\
  --idle-timeout 30 \\
  --scale-settings '{"request_delay_threshold": 1, "min_replicas": 0, "max_replicas": 3}' \\
  --env PYTHONUNBUFFERED=1

Alternative GPU options:
- "NVIDIA A100 80GB PCIe" (more expensive, faster)
- "NVIDIA A100 40GB PCIe"  
- "NVIDIA GeForce RTX 4090" (good cost/performance)
- "NVIDIA GeForce RTX 3090" (budget option)

EOF

echo "🎯 Next Steps:"
echo "1. Push your Docker image to a registry (Docker Hub, etc.)"
echo "2. Run the runpodctl command above to create the endpoint"
echo "3. Get your endpoint URL from the RunPod console"
echo "4. Test with the provided Python client example"

print_status "Deployment preparation complete!"

# Create a helper script for endpoint management
cat > manage_endpoint.sh << 'EOF'
#!/bin/bash

# RunPod Endpoint Management Helper

case "$1" in
    "list")
        echo "📋 Listing your serverless endpoints..."
        runpodctl project serverless list-endpoints
        ;;
    "logs")
        if [ -z "$2" ]; then
            echo "❌ Usage: ./manage_endpoint.sh logs ENDPOINT_ID"
            exit 1
        fi
        echo "📜 Getting logs for endpoint $2..."
        runpodctl project serverless logs $2
        ;;
    "delete")
        if [ -z "$2" ]; then
            echo "❌ Usage: ./manage_endpoint.sh delete ENDPOINT_ID"
            exit 1
        fi
        echo "🗑️  Deleting endpoint $2..."
        runpodctl project serverless delete-endpoint $2
        ;;
    "status")
        if [ -z "$2" ]; then
            echo "❌ Usage: ./manage_endpoint.sh status ENDPOINT_ID"
            exit 1
        fi
        echo "📊 Getting status for endpoint $2..."
        runpodctl project serverless status $2
        ;;
    *)
        echo "🛠️  RunPod Endpoint Management"
        echo ""
        echo "Usage: ./manage_endpoint.sh COMMAND [ARGS]"
        echo ""
        echo "Commands:"
        echo "  list              - List all endpoints"
        echo "  logs ENDPOINT_ID  - Get logs for an endpoint"
        echo "  status ENDPOINT_ID- Get endpoint status"
        echo "  delete ENDPOINT_ID- Delete an endpoint"
        ;;
esac
EOF

chmod +x manage_endpoint.sh

print_status "Created endpoint management helper: ./manage_endpoint.sh"

echo ""
echo "🎉 Ready for RunPod Serverless deployment!"
echo "💰 Remember: You only pay for actual inference time, not idle time!"
