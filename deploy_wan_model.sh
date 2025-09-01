#!/bin/bash
# Wan2.2-S2V-14B Deployment Script for Thunder Compute H100

set -e

echo "🚀 Deploying Wan2.2-S2V-14B on Thunder Compute H100..."

# Check GPU availability
echo "📊 Checking GPU status..."
nvidia-smi

# Check available memory
echo "💾 Checking memory..."
free -h

# Create project directory
PROJECT_DIR="/workspace/wan-s2v-14b"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Clone the Wan2.2 repository
echo "📦 Cloning Wan2.2 repository..."
git clone https://github.com/Wan-Video/Wan2.2.git
cd Wan2.2

# Install dependencies
echo "🔧 Installing dependencies..."
# Ensure torch >= 2.4.0
pip install torch>=2.4.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Download the model
echo "⬇️  Downloading Wan2.2-S2V-14B model..."
# Create model directory
mkdir -p ./Wan2.2-S2V-14B

# Option 1: Using huggingface-cli (recommended)
pip install "huggingface_hub[cli]"
huggingface-cli download Wan-AI/Wan2.2-S2V-14B --local-dir ./Wan2.2-S2V-14B

# Option 2: Alternative using modelscope (if huggingface is slow)
# pip install modelscope
# modelscope download Wan-AI/Wan2.2-S2V-14B --local_dir ./Wan2.2-S2V-14B

echo "✅ Model downloaded successfully!"

# Test the installation
echo "🧪 Testing model setup..."
python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB')
"

# Create example generation script
echo "📝 Creating example generation script..."
cat > generate_example.py << 'EOF'
#!/usr/bin/env python3
"""
Example script for Wan2.2-S2V-14B model inference
Optimized for H100 80GB GPU
"""

import torch
import os
import sys

def main():
    print("🎬 Wan2.2-S2V-14B Speech-to-Video Generation")
    print("=" * 50)
    
    # Check GPU
    if not torch.cuda.is_available():
        print("❌ CUDA not available!")
        sys.exit(1)
    
    gpu_name = torch.cuda.get_device_name(0)
    gpu_memory = torch.cuda.get_device_properties(0).total_memory / 1024**3
    
    print(f"🖥️  GPU: {gpu_name}")
    print(f"💾 GPU Memory: {gpu_memory:.1f} GB")
    
    if gpu_memory < 75:  # Need at least 80GB for optimal performance
        print("⚠️  Warning: GPU has less than 80GB memory. Model may require optimization.")
    
    # Model configuration
    model_path = "./Wan2.2-S2V-14B/"
    if not os.path.exists(model_path):
        print(f"❌ Model not found at {model_path}")
        sys.exit(1)
    
    print("\n🔧 Model Configuration:")
    print(f"   Model Path: {model_path}")
    print(f"   Resolution: 1024x704 (720P)")
    print(f"   Mode: Single GPU with model offloading")
    
    # Example generation command (adjust paths as needed)
    example_command = f"""
    python generate.py \\
        --task s2v-14B \\
        --size 1024*704 \\
        --ckpt_dir {model_path} \\
        --offload_model True \\
        --convert_model_dtype \\
        --prompt "Summer beach vacation style, a white cat wearing sunglasses sits on a surfboard." \\
        --image "examples/i2v_input.JPG" \\
        --audio "examples/talk.wav"
    """
    
    print("\n🚀 Example generation command:")
    print(example_command)
    
    print("\n✅ Setup complete! Ready for video generation.")

if __name__ == "__main__":
    main()
EOF

chmod +x generate_example.py

# Run the example setup check
python generate_example.py

echo """
🎉 Wan2.2-S2V-14B Deployment Complete!

📋 Next Steps:
1. Test with your audio and image files
2. Adjust generation parameters as needed
3. For multi-GPU setup (if using multiple H100s):
   torchrun --nproc_per_node=2 generate.py --dit_fsdp --t5_fsdp --ulysses_size 2

📊 Performance Notes:
- Single H100 80GB: ~80GB VRAM usage
- Generation time: ~5-10 minutes for 5-second 720P video
- For faster inference, consider using multiple H100s with FSDP

🔗 Useful Links:
- Model Hub: https://huggingface.co/Wan-AI/Wan2.2-S2V-14B
- Documentation: https://github.com/Wan-Video/Wan2.2
- Thunder Compute Console: https://console.thundercompute.com
"""
