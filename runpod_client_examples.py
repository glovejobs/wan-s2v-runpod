#!/usr/bin/env python3
"""
RunPod Serverless Client Examples for Wan2.2-S2V-14B
Usage examples for the deployed serverless endpoint
"""

import requests
import base64
import json
import time
import os
from typing import Optional

class RunPodClient:
    """Client for RunPod Serverless Wan2.2-S2V-14B API"""
    
    def __init__(self, endpoint_url: str, api_key: Optional[str] = None):
        """
        Initialize the client
        
        Args:
            endpoint_url: Your RunPod endpoint URL 
                         (e.g., "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync")
            api_key: Your RunPod API key (optional if endpoint is public)
        """
        self.endpoint_url = endpoint_url
        self.headers = {"Content-Type": "application/json"}
        
        if api_key:
            self.headers["Authorization"] = f"Bearer {api_key}"
    
    def encode_file_to_base64(self, file_path: str) -> str:
        """Encode a file to base64 string"""
        with open(file_path, 'rb') as file:
            return base64.b64encode(file.read()).decode('utf-8')
    
    def generate_video(self, 
                      audio_file: str, 
                      image_file: str, 
                      prompt: str = "A person speaking",
                      resolution: str = "1024*704") -> dict:
        """
        Generate video from audio and image files
        
        Args:
            audio_file: Path to audio file (wav/mp3)
            image_file: Path to image file (jpg/jpeg/png)
            prompt: Text prompt for generation
            resolution: Video resolution (e.g., "1024*704")
            
        Returns:
            Dict containing the result
        """
        print(f"📁 Encoding files...")
        
        # Encode files to base64
        audio_b64 = self.encode_file_to_base64(audio_file)
        image_b64 = self.encode_file_to_base64(image_file)
        
        print(f"🚀 Sending request to RunPod...")
        print(f"📝 Prompt: {prompt}")
        print(f"📏 Resolution: {resolution}")
        
        # Prepare request payload
        payload = {
            "input": {
                "audio_file": audio_b64,
                "image_file": image_b64,
                "prompt": prompt,
                "resolution": resolution
            }
        }
        
        # Send request
        start_time = time.time()
        response = requests.post(self.endpoint_url, headers=self.headers, json=payload)
        
        if response.status_code == 200:
            result = response.json()
            end_time = time.time()
            
            print(f"✅ Request completed in {end_time - start_time:.1f}s")
            return result
        else:
            print(f"❌ Request failed: {response.status_code}")
            print(f"Response: {response.text}")
            return {"error": f"HTTP {response.status_code}: {response.text}"}
    
    def save_video_from_base64(self, base64_data: str, output_path: str):
        """Save base64 encoded video to file"""
        try:
            video_data = base64.b64decode(base64_data)
            with open(output_path, 'wb') as f:
                f.write(video_data)
            
            file_size = len(video_data) / (1024 * 1024)  # MB
            print(f"💾 Video saved to {output_path} ({file_size:.1f} MB)")
            return True
        except Exception as e:
            print(f"❌ Failed to save video: {e}")
            return False


# Example usage functions

def example_basic_generation():
    """Basic example of video generation"""
    print("🎬 Basic Video Generation Example")
    print("=" * 40)
    
    # Replace with your RunPod endpoint details
    ENDPOINT_URL = "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync"
    API_KEY = "your-runpod-api-key"  # Optional if endpoint is public
    
    client = RunPodClient(ENDPOINT_URL, API_KEY)
    
    # Example files (replace with your actual files)
    audio_file = "sample_audio.wav"
    image_file = "sample_image.jpg"
    
    if not os.path.exists(audio_file) or not os.path.exists(image_file):
        print("❌ Please provide sample_audio.wav and sample_image.jpg files")
        return
    
    # Generate video
    result = client.generate_video(
        audio_file=audio_file,
        image_file=image_file, 
        prompt="A person speaking enthusiastically about technology",
        resolution="1024*704"
    )
    
    # Handle result
    if "error" in result:
        print(f"❌ Generation failed: {result['error']}")
    elif result.get("success"):
        print(f"✅ Video generated successfully!")
        print(f"⏱️ Generation time: {result.get('generation_time_seconds', 'N/A')}s")
        print(f"📏 Resolution: {result.get('resolution', 'N/A')}")
        print(f"💾 File size: {result.get('file_size_bytes', 0) / (1024*1024):.1f} MB")
        
        # Save the video
        if "video_base64" in result:
            output_file = f"generated_video_{result['request_id']}.mp4"
            client.save_video_from_base64(result["video_base64"], output_file)
    else:
        print(f"❌ Unexpected response: {result}")


def example_batch_generation():
    """Example of processing multiple files"""
    print("📦 Batch Processing Example")
    print("=" * 30)
    
    ENDPOINT_URL = "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/runsync"
    API_KEY = "your-runpod-api-key"
    
    client = RunPodClient(ENDPOINT_URL, API_KEY)
    
    # List of files to process
    batch_requests = [
        {
            "audio": "audio1.wav",
            "image": "image1.jpg",
            "prompt": "A person giving a presentation",
            "resolution": "1024*704"
        },
        {
            "audio": "audio2.wav", 
            "image": "image2.jpg",
            "prompt": "A person speaking passionately",
            "resolution": "512*512"  # Smaller for faster processing
        }
    ]
    
    for i, request in enumerate(batch_requests, 1):
        print(f"\n🎬 Processing request {i}/{len(batch_requests)}")
        
        if not os.path.exists(request["audio"]) or not os.path.exists(request["image"]):
            print(f"❌ Files not found for request {i}")
            continue
        
        result = client.generate_video(
            audio_file=request["audio"],
            image_file=request["image"],
            prompt=request["prompt"],
            resolution=request["resolution"]
        )
        
        if result.get("success") and "video_base64" in result:
            output_file = f"batch_output_{i}_{result['request_id']}.mp4"
            client.save_video_from_base64(result["video_base64"], output_file)
        else:
            print(f"❌ Request {i} failed: {result.get('error', 'Unknown error')}")


def example_async_generation():
    """Example using RunPod's async endpoint (if available)"""
    print("⚡ Async Generation Example")
    print("=" * 30)
    
    # For async, use /run instead of /runsync
    ENDPOINT_URL = "https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/run"
    API_KEY = "your-runpod-api-key"
    
    client = RunPodClient(ENDPOINT_URL, API_KEY)
    
    audio_file = "sample_audio.wav"
    image_file = "sample_image.jpg"
    
    if not os.path.exists(audio_file) or not os.path.exists(image_file):
        print("❌ Please provide sample files")
        return
    
    # Send async request
    result = client.generate_video(
        audio_file=audio_file,
        image_file=image_file,
        prompt="A person speaking in a professional setting",
        resolution="1024*704"
    )
    
    if "id" in result:
        request_id = result["id"]
        print(f"🚀 Async request submitted: {request_id}")
        
        # Poll for status (you'd implement this)
        status_url = f"https://api.runpod.ai/v2/YOUR_ENDPOINT_ID/status/{request_id}"
        
        print("💡 To check status, poll:")
        print(f"GET {status_url}")
        print(f"Headers: {{'Authorization': 'Bearer {API_KEY}'}}")
    else:
        print(f"❌ Async request failed: {result}")


def cost_calculator():
    """Estimate costs for RunPod vs Thunder Compute"""
    print("💰 Cost Comparison Calculator")
    print("=" * 35)
    
    # Example costs (update with current pricing)
    runpod_per_second = 0.0012  # $/second for RTX 4090
    thunder_per_hour = 3.50     # $/hour for H100 (example)
    
    generation_time = 300  # 5 minutes per video
    videos_per_day = int(input("📊 How many videos do you generate per day? "))
    days_per_month = 30
    
    # RunPod Serverless (pay per use)
    monthly_seconds = videos_per_day * days_per_month * generation_time
    runpod_monthly = monthly_seconds * runpod_per_second
    
    # Thunder Compute (always-on instance)
    # Assume you need instance running for generation_time per video + overhead
    daily_runtime_hours = (videos_per_day * generation_time / 3600) + 1  # +1 hour overhead
    monthly_hours = daily_runtime_hours * days_per_month
    thunder_monthly = monthly_hours * thunder_per_hour
    
    print(f"\n📈 Monthly Cost Comparison:")
    print(f"RunPod Serverless: ${runpod_monthly:.2f}")
    print(f"Thunder Compute:   ${thunder_monthly:.2f}")
    print(f"💡 Savings:        ${thunder_monthly - runpod_monthly:.2f} ({((thunder_monthly - runpod_monthly) / thunder_monthly * 100):.1f}%)")
    
    if runpod_monthly < thunder_monthly:
        print("✅ RunPod Serverless is more cost-effective!")
    else:
        print("⚠️ Thunder Compute might be better for your usage pattern")


if __name__ == "__main__":
    print("🚀 RunPod Serverless Client Examples")
    print("=" * 45)
    
    while True:
        print("\nChoose an example:")
        print("1. Basic generation example")
        print("2. Batch processing example") 
        print("3. Async generation example")
        print("4. Cost calculator")
        print("5. Exit")
        
        choice = input("\nEnter your choice (1-5): ").strip()
        
        if choice == "1":
            example_basic_generation()
        elif choice == "2":
            example_batch_generation()
        elif choice == "3":
            example_async_generation()
        elif choice == "4":
            cost_calculator()
        elif choice == "5":
            print("👋 Goodbye!")
            break
        else:
            print("❌ Invalid choice. Please try again.")
