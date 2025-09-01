#!/bin/bash

# Simple RunPod Status Checker
# Check if your WAN S2V endpoint is ready

echo "🚀 RunPod WAN S2V Status Checker"
echo "================================"

# Check if runpodctl is available
if ! command -v ~/.local/bin/runpodctl &> /dev/null; then
    echo "❌ runpodctl not found at ~/.local/bin/runpodctl"
    echo "Please make sure RunPod CLI is installed"
    exit 1
fi

echo "🔍 Checking RunPod endpoints..."
echo ""

# Get endpoint list
endpoint_output=$(~/.local/bin/runpodctl get endpoint 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "📊 Current endpoints:"
    echo "$endpoint_output"
    echo ""
    
    # Check if our endpoint exists
    if echo "$endpoint_output" | grep -q "wan-s2v-runpod"; then
        echo "✅ Found 'wan-s2v-runpod' endpoint!"
        
        # Check status
        if echo "$endpoint_output" | grep -i -E "(ready|active|running)"; then
            echo "🎉 Endpoint appears to be READY!"
            echo ""
            echo "🧪 READY TO TEST!"
            echo "================"
            echo "Your endpoint is ready for testing!"
            echo ""
            echo "📋 Next Steps:"
            echo "1. Go to: https://console.runpod.io/serverless"
            echo "2. Find your 'wan-s2v-runpod' endpoint"
            echo "3. Copy the endpoint URL"
            echo "4. Test it with:"
            echo "   curl -X POST YOUR_ENDPOINT_URL/runsync \\"
            echo "        -H 'Content-Type: application/json' \\"
            echo "        -H 'Authorization: Bearer YOUR_API_KEY' \\"
            echo "        -d '{\"input\": {\"prompt\": \"test\"}}'"
            
        else
            echo "⏳ Endpoint is still building or starting..."
            echo ""
            echo "🔨 Current Status: BUILDING"
            echo "=========================="
            echo "Your endpoint is still being built on RunPod infrastructure"
            echo ""
            echo "⏱️  Expected time: 10-15 minutes total"
            echo "📊 Check progress at: https://console.runpod.io/serverless"
        fi
    else
        echo "❓ 'wan-s2v-runpod' endpoint not found"
        echo ""
        echo "🔍 Available endpoints:"
        echo "$endpoint_output"
    fi
else
    echo "❌ Failed to get endpoints:"
    echo "$endpoint_output"
    echo ""
    echo "💡 Try checking manually at: https://console.runpod.io/serverless"
fi

echo ""
echo "🌐 Manual Check Instructions:"
echo "============================"
echo "1. Go to: https://console.runpod.io/serverless"
echo "2. Look for your 'wan-s2v-runpod' endpoint"
echo "3. Check the status:"
echo "   - 🔄 Building = Still in progress"
echo "   - ✅ Active/Ready = Ready to test!"
echo "   - ❌ Failed = Check build logs"
echo ""
echo "💡 Remember: This is 100x faster than the Docker push approach!"
