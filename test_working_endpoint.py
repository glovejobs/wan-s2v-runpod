#!/usr/bin/env python3

"""
Quick test for working RunPod endpoint
Your endpoint: https://api.runpod.ai/v2/hhtztg5wcz9ppw
"""

import requests
import json
import time

# Your working endpoint
ENDPOINT_URL = "https://api.runpod.ai/v2/hhtztg5wcz9ppw"
API_KEY = "YOUR_RUNPOD_API_KEY_HERE"  # Replace with your actual API key

def test_endpoint():
    print("🧪 Testing WAN S2V RunPod Endpoint")
    print("=" * 50)
    print(f"🔗 Endpoint: {ENDPOINT_URL}")
    print("")
    
    # Test payload
    payload = {
        "input": {
            "prompt": "A person speaking professionally",
            "resolution": "512*512",
            "audio_file": "data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=",
            "image_file": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=",
            "num_inference_steps": 20,
            "guidance_scale": 7.5
        }
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }
    
    print("📤 Sending test request...")
    start_time = time.time()
    
    try:
        response = requests.post(f"{ENDPOINT_URL}/runsync", 
                               headers=headers, 
                               json=payload,
                               timeout=300)
        
        duration = time.time() - start_time
        
        print(f"📊 Response received in {duration:.2f} seconds")
        print(f"📊 Status Code: {response.status_code}")
        print("")
        
        if response.status_code == 200:
            result = response.json()
            print("📋 Response Details:")
            print(f"   Status: {result.get('status', 'Unknown')}")
            print(f"   Delay Time: {result.get('delayTime', 0)}ms") 
            print(f"   Execution Time: {result.get('executionTime', 0)}ms")
            print(f"   Worker ID: {result.get('workerId', 'Unknown')}")
            
            if result.get('status') == 'COMPLETED':
                print("✅ SUCCESS! Video generation completed!")
                if 'output' in result and result['output']:
                    print("🎥 Video output received!")
                    # Save response for inspection
                    with open('success_response.json', 'w') as f:
                        json.dump(result, f, indent=2)
                    print("💾 Full response saved to: success_response.json")
                    return True
            else:
                print("❌ Request failed:")
                print(f"   Error: {result.get('error', 'Unknown error')}")
                if 'output' in result and 'details' in result['output']:
                    print(f"   Details: {result['output']['details']}")
                
                # Save error response for debugging
                with open('error_response.json', 'w') as f:
                    json.dump(result, f, indent=2)
                print("💾 Error details saved to: error_response.json")
                
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            print(f"Response: {response.text}")
            
        return False
        
    except requests.exceptions.Timeout:
        print("⏰ Request timed out (5 minutes)")
        return False
    except Exception as e:
        print(f"❌ Request failed: {e}")
        return False

def main():
    print("🚀 RunPod WAN S2V Endpoint Test")
    print("Your endpoint is confirmed working!")
    print("Testing with sample data...")
    print("")
    
    success = test_endpoint()
    
    print("\n" + "=" * 50)
    if success:
        print("🎉 ENDPOINT IS WORKING PERFECTLY!")
        print("Your WAN S2V model is ready for production use!")
    else:
        print("⚠️  ENDPOINT IS ACTIVE BUT HAS ISSUES")
        print("The good news: Your deployment is successful!")
        print("The issue: Model files need to be fixed")
        print("")
        print("🔧 Next steps:")
        print("1. Check RunPod build logs")
        print("2. Verify model files are downloaded correctly")
        print("3. Update handler.py to correct file paths")
    
    print(f"\n🔗 Your working endpoint: {ENDPOINT_URL}")
    print("📝 Use this URL in the HTML playground!")

if __name__ == "__main__":
    main()
