#!/bin/bash

# Test IPFS configuration for PDS
echo "Testing IPFS configuration..."

# Check if containers are running
if ! docker compose ps | grep -q "pds.*running"; then
    echo "Error: PDS container is not running"
    exit 1
fi

if ! docker compose ps | grep -q "ipfs.*running"; then
    echo "Error: IPFS container is not running"
    exit 1
fi

# Test IPFS connection and basic operations
docker compose exec pds node -e '
const ipfsClient = require("ipfs-http-client");

async function testIPFS() {
    try {
        // Connect to IPFS node
        const ipfs = ipfsClient.create({ 
            url: process.env.PDS_BLOBSTORE_IPFS_API_URL 
        });

        // Test adding content
        const testData = "Hello IPFS from PDS!"
        const { cid } = await ipfs.add(testData);
        console.log("Successfully added content to IPFS:", cid.toString());

        // Test retrieving content
        const chunks = []
        for await (const chunk of ipfs.cat(cid)) {
            chunks.push(chunk)
        }
        const content = Buffer.concat(chunks).toString()
        console.log("Successfully retrieved content from IPFS:", content);

        if (content === testData) {
            console.log("IPFS test successful!");
        } else {
            throw new Error("Retrieved content does not match original");
        }

    } catch (error) {
        console.error("Error testing IPFS:", error);
        process.exit(1);
    }
}

testIPFS();
' 