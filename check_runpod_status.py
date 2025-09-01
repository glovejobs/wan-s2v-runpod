#!/usr/bin/env python3

"""
Quick RunPod Status Checker
Check if your WAN S2V endpoint is ready for testing
"""

import subprocess
import os
import json
import requests

def check_runpod_cli():
    """Check endpoint status via RunPod CLI"""
    print("🔍 Checking RunPod endpoints...")
    
    try:
        result = subprocess.run([
            os.path.expanduser("~/.local/bin/runpodctl"), 
            "get", "endpoint"
        ], capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("📊 RunPod CLI Output:")
            print(result.stdout)
            
            # Look for our endpoint
            if "wan-s2v-runpod" in result.stdout:
                print("✅ Found wan-s2v-runpod endpoint!")
                
                # Check if it's ready
                if "READY" in result.stdout.upper() or "ACTIVE" in result.stdout.upper():
                    print("🎉 Endpoint appears to be READY!")
                    return True
                else:
                    print("⏳ Endpoint is still building or starting up...")
                    return False
            else:
                print("❓ wan-s2v-runpod endpoint not found in list")
                return False
        else:
            print("❌ RunPod CLI failed:")
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("⏰ RunPod CLI command timed out")
        return False
    except Exception as e:
        print(f"❌ Error running RunPod CLI: {e}")
        return False

def check_build_status():
    """Check the build status in RunPod console"""
    print("\n🔨 Build Status Check:")
    print("=" * 30)
    print("To check build status manually:")
    print("1. Go to: https://console.runpod.io/serverless")
    print("2. Look for 'wan-s2v-runpod' endpoint")
    print("3. Check status:")
    print("   - 🔄 Building/Pending = Still in progress")
    print("   - ✅ Ready/Active = Ready to test!")
    print("   - ❌ Failed = Check build logs")

def get_endpoint_info():
    """Try to extract endpoint information"""
    print("\n📋 How to get your endpoint URL:")
    print("=" * 35)
    print("1. Go to RunPod Console → Serverless")
    print("2. Click on your 'wan-s2v-runpod' endpoint")
    print("3. Copy the endpoint URL (looks like:)")
    print("   https://api.runpod.ai/v2/YOUR_ENDPOINT_ID")
    print("4. Use it to test with:")
    print("   python test_runpod_endpoint.py https://api.runpod.ai/v2/YOUR_ENDPOINT_ID")

def main():
    print("🚀 RunPod WAN S2V Status Checker")
    print("=" * 40)
    
    # Check if endpoint is ready
    is_ready = check_runpod_cli()
    
    # Always show build status info
    check_build_status()
    
    # Show endpoint info
    get_endpoint_info()
    
    print("\n" + "=" * 40)
    
    if is_ready:
        print("🎉 Your endpoint appears to be ready!")
        print("📋 Next steps:")
        print("1. Get your endpoint URL from RunPod console")
        print("2. Run: python test_runpod_endpoint.py YOUR_ENDPOINT_URL")
        print("3. Test your WAN S2V model!")
    else:
        print("⏳ Your endpoint is not ready yet")
        print("📋 What to do:")
        print("1. Wait for build to complete (10-15 minutes total)")
        print("2. Check RunPod console for build progress")
        print("3. Run this script again to check status")
    
    print("\n💡 Tip: The first deployment can take 15-20 minutes")
    print("   But future updates via git push will be much faster!")

if __name__ == "__main__":
    main()
