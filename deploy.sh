#!/bin/bash

# Gophish Render Deployment Script
# This script helps deploy Gophish to Render

set -e

echo "🚀 Preparing Gophish for Render deployment..."

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository. Please run this script from the gophish directory."
    exit 1
fi

# Check if we have uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes. Please commit or stash them first."
    echo "   Run: git add . && git commit -m 'Prepare for Render deployment'"
    exit 1
fi

echo "✅ Repository is clean"

# Check if we have the necessary files
required_files=("Dockerfile" "render.yaml" "docker-compose.yml" ".dockerignore")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

echo "✅ All required files are present"

# Check if we have a remote origin
if ! git remote get-url origin &> /dev/null; then
    echo "❌ No remote origin found. Please add your GitHub repository as origin:"
    echo "   git remote add origin https://github.com/0x1of1/gophish.git"
    exit 1
fi

echo "✅ Remote origin is configured"

# Get the current branch
current_branch=$(git branch --show-current)
echo "📍 Current branch: $current_branch"

# Push to GitHub if not already up to date
echo "📤 Pushing to GitHub..."
git push origin $current_branch

echo ""
echo "🎉 Gophish is ready for Render deployment!"
echo ""
echo "Next steps:"
echo "1. Go to https://render.com and sign up/login"
echo "2. Click 'New +' and select 'Web Service'"
echo "3. Connect your GitHub repository: https://github.com/0x1of1/gophish.git"
echo "4. Configure the service:"
echo "   - Name: gophish"
echo "   - Environment: Docker"
echo "   - Branch: $current_branch"
echo "   - Build Command: docker build -t gophish ."
echo "   - Start Command: docker run -p \$PORT:3333 gophish"
echo "5. Click 'Create Web Service'"
echo ""
echo "The service will automatically build and deploy!"
echo "Check the logs for your admin password after deployment."
