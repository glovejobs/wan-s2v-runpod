#!/bin/bash

# 🚀 Automated RunPod Deployment Script
# This creates everything needed for the fastest deployment

echo "🚀 AUTOMATED RUNPOD DEPLOYMENT"
echo "=============================="
echo ""

# Your GitHub repo is ready
echo "✅ GitHub Repository: https://github.com/glovejobs/wan-s2v-runpod"
echo "✅ RunPod CLI configured with API key"
echo ""

# Open RunPod console pages automatically
echo "🌐 Opening RunPod console pages..."

# Open templates page
open "https://console.runpod.io/templates"

echo ""
echo "📋 COPY-PASTE READY VALUES:"
echo "=========================="
echo ""

echo "Template Name:"
echo "WAN-S2V-14B-Serverless"
echo ""

echo "Description:"
echo "WAN 2.2 S2V model for speech-to-video generation - GitHub build"
echo ""

echo "GitHub Repository URL:"
echo "https://github.com/glovejobs/wan-s2v-runpod"
echo ""

echo "Branch:"
echo "main"
echo ""

echo "Dockerfile Path:"
echo "Dockerfile"
echo ""

echo "Container Port:"
echo "8000"
echo ""

echo "Environment Variables (add these one by one):"
echo "PYTHONUNBUFFERED = 1"
echo "HF_HOME = /tmp"
echo ""

echo "🎯 QUICK STEPS IN BROWSER:"
echo "========================="
echo "1. Click 'New Template' (blue button)"
echo "2. Select 'Build from GitHub'"
echo "3. Copy-paste the values above"
echo "4. Click 'Save Template'"
echo "5. Wait 10-15 minutes for build"
echo "6. Deploy serverless endpoint"
echo ""

echo "⏰ Expected Timeline:"
echo "- Template creation: 2 minutes"
echo "- Image build on RunPod: 10-15 minutes"
echo "- Endpoint deployment: 1 minute"
echo ""

echo "🎉 Total time: ~18 minutes vs DAYS of Docker push!"
echo ""

# Wait for user to complete
read -p "Press Enter after you've created the template in the browser..."

echo ""
echo "🔍 Checking template status..."

# List templates to see if it was created
~/.local/bin/runpodctl get template 2>/dev/null || echo "Use web console to monitor build progress"

echo ""
echo "📊 Next: Once build completes, go to Serverless tab and deploy!"
echo "🎯 Endpoint will be ready for inference!"
