#!/bin/bash

# Deploy Remindy Landing Page to Firebase
# Run this script to deploy the landing page

echo ""
echo "========================================="
echo "  Remindy Landing Page Deployment"
echo "========================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI ไม่ได้ติดตั้ง"
    echo ""
    echo "ให้รันคำสั่งนี้ก่อน:"
    echo "npm install -g firebase-tools"
    echo ""
    exit 1
fi

echo "✅ Firebase CLI พบแล้ว"
echo ""

# Check if user is logged in
if ! firebase auth:list &> /dev/null; then
    echo "🔐 กำลังเข้าสู่ระบบ Firebase..."
    firebase login
fi

echo ""
echo "📦 กำลัง Deploy Landing Page..."
echo ""

# Deploy to Firebase
firebase deploy --only hosting

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Deploy ไม่สำเร็จ"
    echo "ลองตรวจสอบ:"
    echo "1. การเชื่อมต่ออินเทอร์เน็ต"
    echo "2. Firebase credentials"
    echo "3. ไฟล์ firebase.json"
    echo ""
    exit 1
fi

echo ""
echo "✅ Deploy สำเร็จ!"
echo ""
echo "🌐 Landing Page URL:"
echo "https://upf001-b206e-landing-pag.web.app/"
echo ""
echo "หากต้องการแก้ไข ให้:"
echo "1. แก้ไขไฟล์ใน web/ folder"
echo "2. รันสคริปต์นี้อีกครั้ง"
echo ""
