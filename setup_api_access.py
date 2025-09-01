#!/usr/bin/env python3
"""
Thunder Compute API Access Setup for Wan2.2-S2V-14B
Creates a simple API wrapper for the model deployment
"""

import os
import json
from flask import Flask, request, jsonify, send_file
import subprocess
import tempfile
import uuid
from datetime import datetime

app = Flask(__name__)

# Configuration
MODEL_PATH = "/workspace/wan-s2v-14b/Wan2.2/Wan2.2-S2V-14B/"
OUTPUT_DIR = "/workspace/outputs"
ALLOWED_EXTENSIONS = {'wav', 'mp3', 'jpg', 'jpeg', 'png'}

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        # Check if model exists
        model_exists = os.path.exists(MODEL_PATH)
        
        # Check GPU availability
        gpu_info = subprocess.run(['nvidia-smi', '--query-gpu=name,memory.total', '--format=csv,noheader,nounits'], 
                                 capture_output=True, text=True)
        gpu_available = gpu_info.returncode == 0
        
        return jsonify({
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "model_available": model_exists,
            "gpu_available": gpu_available,
            "gpu_info": gpu_info.stdout.strip() if gpu_available else "No GPU detected",
            "model_path": MODEL_PATH
        })
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 500

@app.route('/generate', methods=['POST'])
def generate_video():
    """
    Generate video from audio and image
    
    Expected form data:
    - audio_file: Audio file (wav/mp3)
    - image_file: Image file (jpg/jpeg/png) 
    - prompt: Text prompt (optional)
    - resolution: Video resolution (default: "1024*704")
    """
    try:
        # Check if files are present
        if 'audio_file' not in request.files or 'image_file' not in request.files:
            return jsonify({"error": "Both audio_file and image_file are required"}), 400
        
        audio_file = request.files['audio_file']
        image_file = request.files['image_file']
        
        if audio_file.filename == '' or image_file.filename == '':
            return jsonify({"error": "No files selected"}), 400
        
        if not (allowed_file(audio_file.filename) and allowed_file(image_file.filename)):
            return jsonify({"error": "Invalid file type"}), 400
        
        # Get parameters
        prompt = request.form.get('prompt', 'A person speaking')
        resolution = request.form.get('resolution', '1024*704')
        
        # Generate unique ID for this request
        request_id = str(uuid.uuid4())
        temp_dir = os.path.join(OUTPUT_DIR, request_id)
        os.makedirs(temp_dir, exist_ok=True)
        
        # Save uploaded files
        audio_path = os.path.join(temp_dir, 'input_audio.wav')
        image_path = os.path.join(temp_dir, 'input_image.jpg')
        audio_file.save(audio_path)
        image_file.save(image_path)
        
        # Prepare generation command
        output_path = os.path.join(temp_dir, 'output_video.mp4')
        
        cmd = [
            'python', '/workspace/wan-s2v-14b/Wan2.2/generate.py',
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
        
        # Log the request
        print(f"🎬 Starting video generation for request {request_id}")
        print(f"📝 Prompt: {prompt}")
        print(f"📏 Resolution: {resolution}")
        
        # Run generation (this will take several minutes)
        result = subprocess.run(cmd, capture_output=True, text=True, cwd='/workspace/wan-s2v-14b/Wan2.2')
        
        if result.returncode != 0:
            return jsonify({
                "error": "Video generation failed",
                "details": result.stderr,
                "request_id": request_id
            }), 500
        
        # Check if output file was created
        if not os.path.exists(output_path):
            return jsonify({
                "error": "Output video not found",
                "request_id": request_id
            }), 500
        
        return jsonify({
            "success": True,
            "request_id": request_id,
            "message": "Video generated successfully",
            "download_url": f"/download/{request_id}",
            "generation_log": result.stdout
        })
        
    except Exception as e:
        return jsonify({"error": f"Internal server error: {str(e)}"}), 500

@app.route('/download/<request_id>', methods=['GET'])
def download_video(request_id):
    """Download generated video"""
    try:
        video_path = os.path.join(OUTPUT_DIR, request_id, 'output_video.mp4')
        
        if not os.path.exists(video_path):
            return jsonify({"error": "Video not found"}), 404
        
        return send_file(video_path, as_attachment=True, download_name=f'wan_generated_{request_id}.mp4')
        
    except Exception as e:
        return jsonify({"error": f"Download failed: {str(e)}"}), 500

@app.route('/status/<request_id>', methods=['GET'])
def get_status(request_id):
    """Check generation status"""
    try:
        temp_dir = os.path.join(OUTPUT_DIR, request_id)
        video_path = os.path.join(temp_dir, 'output_video.mp4')
        
        if os.path.exists(video_path):
            file_size = os.path.getsize(video_path)
            return jsonify({
                "status": "completed",
                "request_id": request_id,
                "file_size": file_size,
                "download_url": f"/download/{request_id}"
            })
        elif os.path.exists(temp_dir):
            return jsonify({
                "status": "processing",
                "request_id": request_id,
                "message": "Video generation in progress"
            })
        else:
            return jsonify({
                "status": "not_found",
                "request_id": request_id
            }), 404
            
    except Exception as e:
        return jsonify({"error": f"Status check failed: {str(e)}"}), 500

@app.route('/', methods=['GET'])
def index():
    """API documentation"""
    return jsonify({
        "name": "Wan2.2-S2V-14B API",
        "version": "1.0.0",
        "description": "Speech-to-Video generation API using Wan2.2-S2V-14B model",
        "endpoints": {
            "health": {
                "method": "GET",
                "url": "/health",
                "description": "Check API health and model status"
            },
            "generate": {
                "method": "POST",
                "url": "/generate",
                "description": "Generate video from audio and image",
                "parameters": {
                    "audio_file": "Audio file (wav/mp3)",
                    "image_file": "Image file (jpg/jpeg/png)",
                    "prompt": "Text prompt (optional)",
                    "resolution": "Video resolution, e.g. '1024*704' (optional)"
                }
            },
            "download": {
                "method": "GET", 
                "url": "/download/<request_id>",
                "description": "Download generated video"
            },
            "status": {
                "method": "GET",
                "url": "/status/<request_id>", 
                "description": "Check generation status"
            }
        },
        "example_curl": {
            "generate": """curl -X POST http://your-instance-url:5000/generate \\
  -F "audio_file=@your_audio.wav" \\
  -F "image_file=@your_image.jpg" \\
  -F "prompt=A person speaking at the beach" \\
  -F "resolution=1024*704\"""",
            "health": "curl http://your-instance-url:5000/health"
        },
        "gpu_requirement": "H100 80GB recommended",
        "generation_time": "~5-10 minutes for 5-second 720P video"
    })

if __name__ == '__main__':
    print("🚀 Starting Wan2.2-S2V-14B API Server...")
    print("📊 Checking system requirements...")
    
    # Check if model exists
    if not os.path.exists(MODEL_PATH):
        print(f"⚠️  Warning: Model not found at {MODEL_PATH}")
        print("   Please run the deployment script first!")
    
    print("🌐 API will be available at: http://0.0.0.0:5000")
    print("📖 Visit http://0.0.0.0:5000/ for API documentation")
    
    app.run(host='0.0.0.0', port=5000, debug=False)
