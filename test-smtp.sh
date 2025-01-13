#!/bin/bash

# Test SMTP configuration for PDS
echo "Testing SMTP configuration..."

# Check if container is running
if ! docker compose ps | grep -q "pds.*running"; then
    echo "Error: PDS container is not running"
    exit 1
fi

# Test email sending through PDS container
docker compose exec pds node -e '
const nodemailer = require("nodemailer");

async function testEmail() {
    const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        secure: false,
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS
        }
    });

    try {
        await transporter.sendMail({
            from: process.env.SMTP_FROM,
            to: process.env.PDS_ADMIN_EMAIL,
            subject: "PDS SMTP Test",
            text: "If you receive this email, your SMTP configuration is working correctly."
        });
        console.log("Test email sent successfully!");
    } catch (error) {
        console.error("Error sending test email:", error);
        process.exit(1);
    }
}

testEmail();
' 