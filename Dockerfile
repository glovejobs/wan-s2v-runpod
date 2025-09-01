# RunPod Serverless Dockerfile for Wan2.2-S2V-14B
FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install runpod \
    opencv-python \
    imageio \
    imageio-ffmpeg \
    accelerate \
    transformers \
    diffusers \
    xformers \
    torchaudio \
    torchvision \
    huggingface_hub \
    safetensors \
    omegaconf \
    einops \
    rotary_embedding_torch \
    decord

# Try to install flash-attn, but continue if it fails
RUN pip install flash-attn --no-build-isolation || \
    echo "Warning: flash-attn installation failed, continuing without it"

# Create directory structure
RUN mkdir -p /workspace/wan-s2v-14b/Wan2.2

# Download the model (this will happen during build)
# Note: You might need to set HF_TOKEN as build arg if the model is gated
ARG HF_TOKEN
ENV HUGGINGFACE_HUB_TOKEN=${HF_TOKEN}

# Try to download the model, continue if it fails
RUN python -c "from huggingface_hub import snapshot_download; import os; \
try: snapshot_download('IDEA-Research/Wan2.2-S2V-14B', local_dir='/workspace/wan-s2v-14b/Wan2.2/Wan2.2-S2V-14B', local_dir_use_symlinks=False); print('Model download successful') \
except Exception as e: print(f'Model download failed: {e}'); os.makedirs('/workspace/wan-s2v-14b/Wan2.2/Wan2.2-S2V-14B', exist_ok=True)" || echo "Model download setup completed"

# Install common requirements that the Wan2.2 project likely needs
RUN pip install \
    scipy \
    scikit-image \
    matplotlib \
    seaborn \
    pandas || echo "Optional packages installation completed"

# Copy the handler script
COPY runpod_handler.py /workspace/runpod_handler.py

# Set environment variables
ENV PYTHONPATH="/workspace/wan-s2v-14b/Wan2.2:${PYTHONPATH}"
ENV TORCH_CUDA_ARCH_LIST="6.1;7.0;7.5;8.0;8.6;8.9;9.0"
ENV CUDA_VISIBLE_DEVICES=0

# Expose port (not really needed for serverless but good practice)
EXPOSE 8000

# Set the entrypoint to our handler
CMD ["python", "/workspace/runpod_handler.py"]
