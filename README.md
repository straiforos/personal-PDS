# Personal Data Server PDS - triforce09.traiforos.com

## References

- [PDS Environment Configuration Source](https://github.com/bluesky-social/atproto/blob/main/packages/pds/src/config/env.ts)
- [BlueSky PDS Fork](https://github.com/straiforos/pds)

## Setting up submodule in the repo cron-backups/restore-scripts/PDS

```bash
git submodule add https://github.com/straiforos/pds.git restore-scripts/PDS
git submodule update --init --recursive
```

## Setting up atproto submodule for debugging

1. Add the `atproto` submodule:
```bash
git submodule add https://github.com/straiforos/atproto.git path/to/your/submodule
```

2. Initialize and update the submodule:
```bash
git submodule update --init --recursive
```

3. Navigate to the submodule directory:
```bash
cd path/to/your/submodule
```

4. Install dependencies and build the project with source maps:
```bash
npm install
npm run build -- --source-map
```

## Environment Setup

1. Create a `.env` file in the PDS directory by copying the template:
```bash
cp .env.dist .env
```

2. Generate required keys:

   a. Generate JWT secret:
   ```bash
   openssl rand -base64 32
   ```

   b. Generate PLC rotation key:
   ```bash
   # Install required dependencies if needed
   # Ubuntu/Debian:
   sudo apt-get update
   sudo apt-get install openssl vim-common coreutils

   # Make script executable
   chmod +x generate-plc-key.sh
   
   # Generate key
   ./generate-plc-key.sh
   ```

   The PLC key generation script will:
   - Check for required dependencies
   - Generate a secure secp256k1 private key
   - Format it appropriately for PDS
   - Optionally update your .env file directly
   - Create a backup of your .env file if modified

3. Configure the required environment variables:
```bash
# PDS Configuration
PDS_JWT_SECRET=<from-step-2a>
PDS_ADMIN_PASSWORD=<your-admin-password>
PDS_ADMIN_EMAIL=stephen@traiforos.com

# PLC Configuration
PLC_ROTATION_KEY=<from-step-2b>

# Disk Storage Configuration
PDS_BLOBSTORE_DISK_LOCATION=/app/blobstore
PDS_BLOBSTORE_DISK_TMP_LOCATION=/app/blobstore/tmp

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=stephen@traiforos.com
SMTP_PASS=<your-gmail-app-password>
SMTP_FROM=pds@traiforos.com
SMTP_ENCRYPTION=tls
```

4. Generate Gmail App Password:
   - Enable 2FA in your Google Account
   - Go to Security > 2-Step Verification > App passwords
   - Create new app password for "PDS"
   - Update SMTP_PASS in .env with generated password
   - Important: Remove any spaces from the app password when copying it
   - Example: Change "xxxx yyyy zzzz wwww" to "xxxxyyyyyzzzzwwww"

5. Create blobstore directories:
```bash
mkdir -p blobstore/tmp
chmod -R 777 blobstore
```

## Deployment Steps

1. Start the PDS container:
```bash
docker compose up -d
```

2. Verify the service is running:
```bash
docker compose ps
```

3. Check the logs:
```bash
docker compose logs -f pds
```

## Storage Configuration

The PDS uses local disk storage for blobs. The setup includes:
- Local directory: `./blobstore`
- Temporary storage: `./blobstore/tmp`
- Mounted at: `/app/blobstore` in container

### Testing Storage

1. Check storage permissions:
```bash
ls -la blobstore
```

2. Monitor storage usage:
```bash
du -sh blobstore
```

3. Verify container access:
```bash
docker compose exec pds ls -la /app/blobstore
```

## SMTP Testing

1. Make the test script executable:
```bash
chmod +x test-smtp.sh
```

2. Run the SMTP test:
```bash
./test-smtp.sh
```

3. Troubleshooting SMTP:
```bash
# Test SMTP connection
docker compose exec pds nc -zv smtp.gmail.com 587

# Verify environment variables
docker compose exec pds env | grep SMTP

# Check SMTP-related logs
docker compose logs pds | grep -i smtp
```

## Ngrok Configuration

The PDS service is exposed through ngrok at `triforce09.traiforos.com`. The configuration is managed in the homeserver-ngrok-config repository.

To apply ngrok changes:
1. Update ngrok configuration
2. Restart ngrok service:
```bash
docker compose -f /path/to/ngrok/docker-compose.yml restart
```

## Account Creation

1. Generate an invite code using the pdsadmin script:
```bash
# First ensure the submodule is initialized
git submodule update --init --recursive

# Make the pdsadmin script executable
chmod +x pds/pdsadmin.sh

# Create pds.env file if it doesn't exist
cat > pds/pds.env << EOL
PDS_HOSTNAME=triforce09.traiforos.com
PDS_ADMIN_PASSWORD=$(grep PDS_ADMIN_PASSWORD .env | cut -d '=' -f2)
EOL

# Generate a single-use invite code
./pds/pdsadmin.sh create-invite-code

# Alternative: Run directly from container (if you prefer)
docker compose exec pds bash
pdsadmin create-invite-code
```

2. Create your account through the Bluesky app:
   - Service URL: https://triforce09.traiforos.com
   - Use the generated invite code
   - Choose handle: @triforce09.traiforos.com

3. Manage invite codes (using pdsadmin script):
```bash
# List all invite codes
./pds/pdsadmin.sh list-invite-codes

# Disable an invite code
./pds/pdsadmin.sh disable-invite-code <code>

# Check if an invite code is valid
./pds/pdsadmin.sh check-invite-code <code>

# Generate multiple invite codes
./pds/pdsadmin.sh create-invite-code --count 5

# Generate invite code with custom expiry
./pds/pdsadmin.sh create-invite-code --expires-in "7d"  # 7 days
```

Note: 
- Invite codes are single-use by default and expire after 24 hours if no expiry is specified
- The pdsadmin scripts require the PDS_HOSTNAME and PDS_ADMIN_PASSWORD environment variables to be set
- You can either use the local pdsadmin scripts or run commands directly in the container

## Backup and Restore

TODO:
- Add backup script for PDS configuration
- Add backup script for blobstore data
- Add restore script for PDS
- Add restore script for blobstore data

## Troubleshooting

1. Check PDS container status:
```bash
docker compose ps
docker compose logs pds
```

2. Verify ngrok tunnel:
```bash
curl -I https://triforce09.traiforos.com
```

3. Check PDS health:
```bash
curl https://triforce09.traiforos.com/xrpc/_health
```

4. Test email functionality:
```bash
./test-smtp.sh
```

5. Check storage:
```bash
# View storage permissions
ls -la blobstore

# Check storage usage
du -sh blobstore

# Verify container access
docker compose exec pds ls -la /app/blobstore
```

6. PLC Key Issues:
```bash
# Verify PLC key is set
docker compose exec pds env | grep PLC

# Generate a new PLC key if needed
./generate-plc-key.sh

# Check PLC key format
echo $PLC_ROTATION_KEY | base64 -d | xxd
```

Common PLC Issues:
- Missing dependencies for key generation
- Incorrectly formatted key
- Key not properly set in environment
- Backup your .env file before regenerating keys

## NGINX Configuration

The PDS service uses NGINX in a Docker container for reverse proxy:

1. The configuration files are:
   - `nginx.conf`: Site-specific configuration
   - `nginx-main.conf`: Main NGINX configuration

2. Start the services:
```bash
docker compose up -d
```

3. Verify NGINX is running:
```bash
docker compose ps nginx
docker compose logs nginx
```

4. Test the endpoints:
```bash
# Health check
curl http://localhost/xrpc/_health

# DID endpoint
curl http://localhost/.well-known/atproto-did
```

Note: Since we're using Docker, NGINX automatically connects to the PDS service using Docker's internal networking.

## Local Development with Verdaccio

This project uses Verdaccio as a local npm registry to facilitate debugging and development of the atproto packages with source maps.

### Setting up Verdaccio

1. Install dependencies:
```bash
npm install
```

2. Start Verdaccio:
```bash
npx verdaccio
```

3. Configure npm to use the local registry:
```bash
# Create .npmrc in project root
cat > .npmrc << EOL
registry=http://localhost:4873/
@atproto:registry=http://localhost:4873/
strict-ssl=false
EOL
```

### Publishing atproto packages locally

1. Navigate to the atproto submodule:
```bash
cd atproto
```

2. Build packages with source maps:
```bash
npm install
npm run build -- --source-map
```

3. Publish to local registry:
```bash
# Login to Verdaccio (first time only)
npm adduser --registry http://localhost:4873

# Publish all packages
npm publish --registry http://localhost:4873
```

### Updating PDS to use local packages

1. Update PDS dependencies to use local versions:
```bash
cd pds
npm install @atproto/pds --registry http://localhost:4873
```

2. Rebuild PDS with local dependencies:
```bash
npm run build
```

3. Start PDS with source maps:
```bash
docker compose up -d --build
```

### Debugging

1. Configure VS Code launch configuration:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "node",
            "request": "attach",
            "name": "Attach to PDS",
            "port": 9229,
            "restart": true,
            "sourceMaps": true,
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/app"
        }
    ]
}
```

2. Start PDS in debug mode:
```bash
docker compose -f docker-compose.debug.yml up -d
```

3. Attach VS Code debugger using the "Attach to PDS" configuration