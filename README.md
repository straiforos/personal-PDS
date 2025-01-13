# Personal Data Server PDS - triforce09.traiforos.com

## References

- [PDS Environment Configuration Source](https://github.com/bluesky-social/atproto/blob/main/packages/pds/src/config/env.ts)
- [BlueSky PDS Fork](https://github.com/straiforos/pds)

## Setting up submodule in the repo cron-backups/restore-scripts/PDS

```bash
git submodule add https://github.com/straiforos/pds.git restore-scripts/PDS
git submodule update --init --recursive
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

1. Generate an invite code:
```bash
docker compose exec pds pdsadmin create-invite-code
```

2. Create your account through the Bluesky app:
   - Service URL: https://triforce09.traiforos.com
   - Use the generated invite code
   - Choose handle: @triforce09.traiforos.com

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