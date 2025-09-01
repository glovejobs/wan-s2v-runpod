#!/usr/bin/env python3
"""
RunPod Serverless Handler for Wan2.2-S2V-14B
Converts the Flask API to RunPod's serverless format
"""

import runpod
import os
import json
import tempfile
import uuid
import subprocess
import base64
from datetime import datetime
import shutil

# Model configuration
# Try multiple possible model locations
POSSIBLE_MODEL_PATHS = [
    "/workspace/wan-s2v-14b/Wan2.2/Wan2.2-S2V-14B/",
    "/workspace/wan-s2v-14b/Wan2.2-S2V-14B/", 
    "/workspace/Wan2.2-S2V-14B/",
    "/workspace/models/",
    "/app/models/"
]

# Find the actual model path
MODEL_PATH = None
for path in POSSIBLE_MODEL_PATHS:
    if os.path.exists(path):
        MODEL_PATH = path
        break

if not MODEL_PATH:
    MODEL_PATH = POSSIBLE_MODEL_PATHS[0]  # Default fallback

ALLOWED_EXTENSIONS = {'wav', 'mp3', 'jpg', 'jpeg', 'png'}

def setup_environment():
    """Initialize the environment and check model availability"""
    print("🚀 Initializing Wan2.2-S2V-14B handler...")
    
    # Check if model exists
    if not os.path.exists(MODEL_PATH):
        print(f"⚠️ Warning: Model not found at {MODEL_PATH}")
        return False
    
    # Check GPU availability  
    try:
        gpu_info = subprocess.run(['nvidia-smi', '--query-gpu=name,memory.total', '--format=csv,noheader,nounits'], 
                                 capture_output=True, text=True)
        if gpu_info.returncode == 0:
            print(f"✅ GPU detected: {gpu_info.stdout.strip()}")
        else:
            print("⚠️ No GPU detected")
    except Exception as e:
        print(f"⚠️ GPU check failed: {e}")
    
    print("✅ Handler initialization complete")
    return True

def decode_base64_file(base64_string, output_path):
    """Decode base64 string and save to file"""
    try:
        # Remove data URL prefix if present
        if ',' in base64_string:
            base64_string = base64_string.split(',')[1]
        
        # Decode and save
        file_data = base64.b64decode(base64_string)
        with open(output_path, 'wb') as f:
            f.write(file_data)
        return True
    except Exception as e:
        print(f"Error decoding base64 file: {e}")
        return False

def handler(event):
    """
    RunPod handler function for video generation
    
    Expected input format:
    {
        "audio_file": "base64_encoded_audio_data",
        "image_file": "base64_encoded_image_data", 
        "prompt": "A person speaking",
        "resolution": "1024*704"
    }
    """
    print("🎬 Starting video generation request...")
    
    try:
        # Validate input
        if not event.get('input'):
            return {"error": "No input provided"}
        
        input_data = event['input']
        
        # Check required fields
        if 'audio_file' not in input_data or 'image_file' not in input_data:
            return {"error": "Both audio_file and image_file are required (as base64)"}
        
        # Get parameters
        audio_b64 = input_data['audio_file']
        image_b64 = input_data['image_file'] 
        prompt = input_data.get('prompt', 'A person speaking')
        resolution = input_data.get('resolution', '1024*704')
        
        # Generate unique ID for this request
        request_id = str(uuid.uuid4())
        print(f"📝 Request ID: {request_id}")
        print(f"📝 Prompt: {prompt}")
        print(f"📏 Resolution: {resolution}")
        
        # Create temporary directory
        with tempfile.TemporaryDirectory() as temp_dir:
            print(f"📁 Working in: {temp_dir}")
            
            # Decode and save input files
            audio_path = os.path.join(temp_dir, 'input_audio.wav')
            image_path = os.path.join(temp_dir, 'input_image.jpg')
            
            if not decode_base64_file(audio_b64, audio_path):
                return {"error": "Failed to decode audio file"}
            
            if not decode_base64_file(image_b64, image_path):
                return {"error": "Failed to decode image file"}
            
            print("✅ Input files decoded successfully")
            
            # Prepare generation command
            output_path = os.path.join(temp_dir, 'output_video.mp4')
            
            # Find generate.py script in multiple possible locations
            generate_script = None
            possible_locations = [
                '/workspace/generate.py',
                '/workspace/wan-s2v-14b/Wan2.2/generate.py',
                '/workspace/wan-s2v-14b/generate.py',
                '/app/generate.py',
                './generate.py'
            ]
            
            for location in possible_locations:
                if os.path.exists(location):
                    generate_script = location
                    print(f"✅ Found generate.py at: {location}")
                    break
            
            if not generate_script:
                return {
                    "error": "generate.py not found",
                    "details": f"Searched locations: {possible_locations}",
                    "request_id": request_id
                }
            
            cmd = [
                'python', generate_script,
                '--task', 's2v-14B',
                '--size', resolution,
                '--ckpt_dir', MODEL_PATH,
                '--offload_model', 'True',
                '--convert_model_dtype',
                '--prompt', prompt,
                '--image', image_path,
                '--audio', audio_path,
                '--output', output_path
            ]
            
            print("🎯 Starting model inference...")
            
            # Run generation
            start_time = datetime.now()
            result = subprocess.run(cmd, capture_output=True, text=True, cwd='/workspace/wan-s2v-14b/Wan2.2')
            end_time = datetime.now()
            
            generation_time = (end_time - start_time).total_seconds()
            print(f"⏱️ Generation completed in {generation_time:.1f}s")
            
            if result.returncode != 0:
                return {
                    "error": "Video generation failed",
                    "details": result.stderr,
                    "request_id": request_id
                }
            
            # Check if output file was created
            if not os.path.exists(output_path):
                return {
                    "error": "Output video not found", 
                    "request_id": request_id
                }
            
            # Encode output video as base64
            with open(output_path, 'rb') as video_file:
                video_b64 = base64.b64encode(video_file.read()).decode('utf-8')
            
            file_size = os.path.getsize(output_path)
            print(f"✅ Generated video: {file_size / (1024*1024):.1f} MB")
            
            return {
                "success": True,
                "request_id": request_id,
                "video_base64": video_b64,
                "generation_time_seconds": generation_time,
                "file_size_bytes": file_size,
                "resolution": resolution,
                "prompt": prompt,
                "message": "Video generated successfully"
            }
            
    except Exception as e:
        print(f"❌ Handler error: {str(e)}")
        return {"error": f"Internal server error: {str(e)}"}

# Initialize environment when the handler starts
if __name__ != "__main__":
    setup_environment()

# Start the RunPod serverless handler
runpod.serverless.start({"handler": handler})
