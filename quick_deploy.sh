#!/bin/bash
# Quick Deployment Script for Thunder Compute
# Run this script once your Thunder Compute instance is ready

set -e

echo "🚀 Thunder Compute Wan2.2-S2V-14B Quick Deployment"
echo "=================================================="

# Check if we have the instance IP
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <instance-ip-address>"
    echo "   Example: $0 123.456.789.10"
    echo ""
    echo "📝 Get your instance IP from: https://console.thundercompute.com/"
    exit 1
fi

INSTANCE_IP="$1"
INSTANCE_USER="ubuntu"  # Default for most Thunder Compute instances
SSH_KEY_PATH="$HOME/.ssh/thunder_compute"  # Thunder Compute SSH key

echo "🎯 Target instance: $INSTANCE_USER@$INSTANCE_IP"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  SSH key not found at $SSH_KEY_PATH"
    echo "   You may need to:"
    echo "   1. Generate SSH keys: ssh-keygen -t rsa -b 4096"
    echo "   2. Add your public key to Thunder Compute console"
    echo "   3. Or specify correct key path in this script"
    exit 1
fi

echo "📤 Step 1: Uploading deployment files..."

# Upload deployment files
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
    deploy_wan_model.sh setup_api_access.py \
    "$INSTANCE_USER@$INSTANCE_IP:/tmp/"

echo "✅ Files uploaded successfully!"
echo ""

echo "🔧 Step 2: Running deployment on instance..."

# Run deployment
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$INSTANCE_USER@$INSTANCE_IP" << 'REMOTE_COMMANDS'
set -e

echo "🏠 Setting up workspace..."
sudo mkdir -p /workspace
sudo chown $USER:$USER /workspace
cd /workspace

echo "📦 Moving deployment files..."
mv /tmp/deploy_wan_model.sh /tmp/setup_api_access.py /workspace/
chmod +x /workspace/deploy_wan_model.sh

echo "🎬 Starting Wan2.2-S2V-14B model deployment..."
echo "⏰ This will take about 15-30 minutes..."
echo ""

# Run the main deployment script
/workspace/deploy_wan_model.sh

echo ""
echo "🌐 Installing Flask for API server..."
pip install flask

echo ""
echo "🎉 Deployment completed successfully!"
echo "📍 Files are located in: /workspace/wan-s2v-14b/"
echo ""
echo "🚀 To start the API server, run:"
echo "   cd /workspace && python setup_api_access.py"
echo ""

REMOTE_COMMANDS

echo ""
echo "🎊 DEPLOYMENT COMPLETE! 🎊"
echo "=========================="
echo ""
echo "📋 Next steps:"
echo "1. SSH into your instance: ssh -i $SSH_KEY_PATH $INSTANCE_USER@$INSTANCE_IP"
echo "2. Start the API server: cd /workspace && python setup_api_access.py"
echo "3. Test the API: curl http://$INSTANCE_IP:5000/health"
echo ""
echo "🌐 Your API will be available at: http://$INSTANCE_IP:5000"
echo "📖 API docs: http://$INSTANCE_IP:5000/"
echo ""
echo "💰 Remember to stop the instance when not in use to save costs!"
