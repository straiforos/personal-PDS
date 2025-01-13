#!/bin/bash

# Test S3 storage configuration for PDS
echo "Testing S3 storage configuration..."

# Check if container is running
if ! docker compose ps | grep -q "pds.*running"; then
    echo "Error: PDS container is not running"
    exit 1
fi

# Test S3 connection
docker compose exec pds node -e '
const AWS = require("aws-sdk");

async function testS3() {
    const s3 = new AWS.S3({
        endpoint: process.env.PDS_BLOBSTORE_S3_ENDPOINT,
        accessKeyId: process.env.PDS_BLOBSTORE_S3_ACCESS_KEY,
        secretAccessKey: process.env.PDS_BLOBSTORE_S3_SECRET_KEY,
        s3ForcePathStyle: true,
        signatureVersion: "v4",
        region: process.env.PDS_BLOBSTORE_S3_REGION
    });

    try {
        // Test bucket access
        await s3.headBucket({ Bucket: process.env.PDS_BLOBSTORE_S3_BUCKET }).promise();
        console.log("Successfully connected to S3 bucket!");

        // Test write
        const testKey = "test-file.txt";
        await s3.putObject({
            Bucket: process.env.PDS_BLOBSTORE_S3_BUCKET,
            Key: testKey,
            Body: "Test content"
        }).promise();
        console.log("Successfully wrote test file!");

        // Test read
        const data = await s3.getObject({
            Bucket: process.env.PDS_BLOBSTORE_S3_BUCKET,
            Key: testKey
        }).promise();
        console.log("Successfully read test file!");

        // Cleanup
        await s3.deleteObject({
            Bucket: process.env.PDS_BLOBSTORE_S3_BUCKET,
            Key: testKey
        }).promise();
        console.log("Successfully deleted test file!");

    } catch (error) {
        console.error("Error testing S3:", error);
        process.exit(1);
    }
}

testS3();
' 