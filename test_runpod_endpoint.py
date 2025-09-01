#!/usr/bin/env python3

"""
RunPod WAN S2V Endpoint Testing Script
Test your deployed WAN S2V model on RunPod serverless
"""

import requests
import json
import time
import base64
import os

# Configuration
RUNPOD_ENDPOINT_URL = "YOUR_ENDPOINT_URL_HERE"  # Get this from RunPod console
RUNPOD_API_KEY = "YOUR_RUNPOD_API_KEY_HERE"  # Replace with your actual API key

def encode_file_to_base64(file_path):
    """Encode a file to base64 string"""
    try:
        with open(file_path, "rb") as file:
            return base64.b64encode(file.read()).decode('utf-8')
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        return None

def test_endpoint_health():
    """Test if the endpoint is responsive"""
    print("🔍 Testing endpoint health...")
    
    health_url = f"{RUNPOD_ENDPOINT_URL}/health"
    try:
        response = requests.get(health_url, timeout=10)
        if response.status_code == 200:
            print("✅ Endpoint is healthy and responding")
            return True
        else:
            print(f"⚠️  Endpoint returned status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_runpod_endpoint(audio_file_path=None, image_file_path=None):
    """Test the RunPod serverless endpoint"""
    
    print("🚀 Testing RunPod WAN S2V Endpoint")
    print("=" * 50)
    
    # Test data - use sample files or create minimal test data
    test_payload = {
        "input": {
            "prompt": "A person speaking in a professional setting",
            "resolution": "512*512",
            "num_inference_steps": 25,
            "guidance_scale": 7.5
        }
    }
    
    # Add audio file if provided
    if audio_file_path and os.path.exists(audio_file_path):
        print(f"📁 Using audio file: {audio_file_path}")
        audio_b64 = encode_file_to_base64(audio_file_path)
        if audio_b64:
            test_payload["input"]["audio_file"] = f"data:audio/wav;base64,{audio_b64}"
    else:
        print("🎵 Using sample audio data")
        # Minimal WAV header for testing
        test_payload["input"]["audio_file"] = "data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA="
    
    # Add image file if provided
    if image_file_path and os.path.exists(image_file_path):
        print(f"🖼️  Using image file: {image_file_path}")
        image_b64 = encode_file_to_base64(image_file_path)
        if image_b64:
            test_payload["input"]["image_file"] = f"data:image/jpeg;base64,{image_b64}"
    else:
        print("🖼️  Using sample image data")
        # Minimal JPEG for testing
        test_payload["input"]["image_file"] = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="
    
    print("\n📤 Sending request to RunPod endpoint...")
    print(f"🔗 URL: {RUNPOD_ENDPOINT_URL}")
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {RUNPOD_API_KEY}"
    }
    
    start_time = time.time()
    
    try:
        response = requests.post(
            f"{RUNPOD_ENDPOINT_URL}/runsync",
            headers=headers,
            json=test_payload,
            timeout=300  # 5 minute timeout
        )
        
        end_time = time.time()
        duration = end_time - start_time
        
        print(f"⏱️  Request took: {duration:.2f} seconds")
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SUCCESS! Endpoint is working")
            print("\n📋 Response Summary:")
            print(f"   Status: {result.get('status', 'Unknown')}")
            
            if 'output' in result:
                output = result['output']
                print(f"   Output type: {type(output)}")
                if isinstance(output, dict):
                    print(f"   Output keys: {list(output.keys())}")
                    if 'video_url' in output:
                        print(f"   🎥 Video URL: {output['video_url']}")
                    if 'video_base64' in output:
                        print("   🎥 Video returned as base64 data")
            
            # Save full response for inspection
            with open('runpod_test_response.json', 'w') as f:
                json.dump(result, f, indent=2)
            print("   💾 Full response saved to: runpod_test_response.json")
            
            return True
            
        else:
            print(f"❌ Request failed with status {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("⏰ Request timed out (5 minutes)")
        print("   This might be normal for first request (cold start)")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False

def check_runpod_status():
    """Check the status of your RunPod endpoint"""
    print("🔍 Checking RunPod endpoint status via CLI...")
    
    try:
        import subprocess
        result = subprocess.run([
            os.path.expanduser("~/.local/bin/runpodctl"), 
            "get", "endpoint"
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("📊 Current endpoints:")
            print(result.stdout)
        else:
            print("⚠️  Could not get endpoint status")
            print(result.stderr)
    except Exception as e:
        print(f"❌ CLI check failed: {e}")

def main():
    print("🧪 RunPod WAN S2V Testing Suite")
    print("=" * 50)
    
    # Check if endpoint URL is configured
    if RUNPOD_ENDPOINT_URL == "YOUR_ENDPOINT_URL_HERE":
        print("⚠️  Please configure your endpoint URL first!")
        print("\n📋 To get your endpoint URL:")
        print("1. Go to RunPod Console → Serverless")
        print("2. Find your 'wan-s2v-runpod' endpoint")
        print("3. Copy the endpoint URL")
        print("4. Replace 'YOUR_ENDPOINT_URL_HERE' in this script")
        print("\nOr run with URL as argument:")
        print("python test_runpod_endpoint.py https://api.runpod.ai/v2/YOUR_ENDPOINT_ID")
        return
    
    # Check RunPod status first
    check_runpod_status()
    
    print("\n" + "=" * 50)
    
    # Test endpoint health
    if test_endpoint_health():
        print("\n" + "=" * 50)
        # Run the main test
        success = test_runpod_endpoint()
        
        if success:
            print("\n🎉 ALL TESTS PASSED!")
            print("Your WAN S2V model is working on RunPod!")
        else:
            print("\n❌ Tests failed. Check the logs above.")
    else:
        print("\n❌ Endpoint health check failed.")
        print("Make sure your endpoint is deployed and running.")

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        RUNPOD_ENDPOINT_URL = sys.argv[1]
    main()
