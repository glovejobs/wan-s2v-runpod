#!/bin/bash

# Quick GitHub Deployment for RunPod
# This bypasses the 26.8GB Docker push problem entirely!

set -e

echo "⚡ FAST TRACK: GitHub → RunPod Deployment"
echo "========================================"
echo "No more Docker push issues! ✨"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
fi

# Check git status
echo "📊 Current git status:"
git status --porcelain | head -10

echo ""
echo "🔧 Setting up for fast deployment..."

# Create .gitignore for efficient uploads
cat > .gitignore << 'EOF'
# Docker and build artifacts
*.log
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/

# Model weights (if they're downloaded locally)
*.safetensors
*.bin
models/

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

EOF

# Create optimized requirements.txt if it doesn't exist
if [ ! -f "requirements.txt" ]; then
    echo "📦 Creating requirements.txt..."
    cat > requirements.txt << 'EOF'
torch>=2.0.0
transformers>=4.30.0
accelerate>=0.20.0
diffusers>=0.20.0
xformers>=0.0.20
fastapi>=0.100.0
uvicorn>=0.20.0
pydantic>=2.0.0
Pillow>=9.0.0
requests>=2.30.0
numpy>=1.24.0
runpod>=1.0.0
EOF
    echo "✅ Created requirements.txt"
fi

# Add all files
echo "📤 Preparing files for GitHub..."
git add .

# Commit changes
if git diff --cached --quiet; then
    echo "ℹ️  No new changes to commit"
else
    git commit -m "WAN S2V model - optimized for RunPod deployment $(date '+%Y-%m-%d %H:%M')"
    echo "✅ Changes committed"
fi

echo ""
echo "🎯 NEXT STEPS (Choose One):"
echo ""
echo "📝 1. GITHUB INTEGRATION (Fastest - Recommended):"
echo "   a) Create GitHub repo: https://github.com/new"
echo "   b) Add remote: git remote add origin https://github.com/YOURUSERNAME/wan-s2v-runpod.git"
echo "   c) Push code: git push -u origin main"
echo "   d) Go to RunPod Console → Templates → Build from GitHub"
echo ""
echo "🚀 2. DIRECT RUNPOD BUILD:"
echo "   Run: ./runpod_direct_build.sh"
echo ""
echo "📦 3. PACKAGE UPLOAD:"
echo "   a) tar -czf wan2v.tar.gz --exclude='.git' ."
echo "   b) Upload via RunPod storage service"
echo ""

# Check if user wants to proceed with GitHub setup
read -p "🤔 Do you want me to help set up the GitHub deployment now? (y/N): " setup_github

if [[ $setup_github =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔗 GitHub Setup Helper"
    echo "====================="
    echo ""
    
    read -p "📝 Enter your GitHub username: " github_user
    read -p "📝 Enter repository name (default: wan-s2v-runpod): " repo_name
    repo_name=${repo_name:-wan-s2v-runpod}
    
    echo ""
    echo "🚀 GitHub setup commands:"
    echo ""
    echo "# 1. Create repo on GitHub, then run:"
    echo "git remote add origin https://github.com/$github_user/$repo_name.git"
    echo "git branch -M main"
    echo "git push -u origin main"
    echo ""
    echo "# 2. Go to RunPod Console:"
    echo "# https://console.runpod.io/templates"
    echo "# → New Template → Build from GitHub"
    echo "# → Repository: https://github.com/$github_user/$repo_name"
    echo "# → Dockerfile Path: Dockerfile.runpod"
    echo ""
    echo "📊 Benefits:"
    echo "✅ Upload time: ~30 seconds (vs days for Docker push)"
    echo "✅ Build time on RunPod: ~10-15 minutes"
    echo "✅ No local Docker issues"
    echo "✅ Easy updates via git push"
fi

echo ""
echo "🎉 Ready for fast deployment!"
echo "💡 This approach is 100x faster than Docker push!"
