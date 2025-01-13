# Personal Data Server PDS - triforce09.traiforos.com

## BlueSky PDS Fork submodule

- https://github.com/straiforos/pds

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

2. Configure the required environment variables:
```bash
# PDS Configuration
PDS_JWT_SECRET=<generate-a-secure-random-string>
PDS_ADMIN_PASSWORD=<your-admin-password>
PDS_ADMIN_EMAIL=stephen@traiforos.com

# IPFS Configuration
PDS_BLOBSTORE_PROVIDER=ipfs
PDS_BLOBSTORE_IPFS_API_URL=http://ipfs:5001
PDS_BLOBSTORE_IPFS_GATEWAY_URL=http://ipfs:8080

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=stephen@traiforos.com
SMTP_PASS=<your-gmail-app-password>
SMTP_FROM=pds@traiforos.com
SMTP_ENCRYPTION=tls
```

3. Generate Gmail App Password:
   - Enable 2FA in your Google Account
   - Go to Security > 2-Step Verification > App passwords
   - Create new app password for "PDS"
   - Update SMTP_PASS in .env with generated password

## Deployment Steps

1. Start the PDS and IPFS containers:
```bash
docker compose up -d
```

2. Verify services are running:
```bash
docker compose ps
```

3. Check the logs:
```bash
docker compose logs -f pds
docker compose logs -f ipfs
```

## IPFS Configuration

The PDS uses IPFS (InterPlanetary File System) for decentralized storage. The setup includes:
- IPFS node running in a container
- Exposed ports:
  - 4001: IPFS swarm
  - 8080: IPFS gateway
  - 5001: IPFS API

### Testing IPFS

1. Make the test script executable:
```bash
chmod +x test-ipfs.sh
```

2. Run the IPFS test:
```bash
./test-ipfs.sh
```

3. Monitor IPFS:
```bash
# Check IPFS peer connections
docker compose exec ipfs ipfs swarm peers

# View IPFS node stats
docker compose exec ipfs ipfs stats bw

# Check IPFS repo size
docker compose exec ipfs ipfs repo stat
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
- Add backup script for PDS
- Add backup script for IPFS data
- Add restore script for PDS
- Add restore script for IPFS data

## Troubleshooting

1. Check service status:
```bash
docker compose ps
docker compose logs pds
docker compose logs ipfs
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

5. Test IPFS functionality:
```bash
./test-ipfs.sh
```

6. IPFS Troubleshooting:
```bash
# Check IPFS daemon status
docker compose exec ipfs ipfs id

# View IPFS config
docker compose exec ipfs ipfs config show

# Check IPFS network connectivity
docker compose exec ipfs ipfs swarm peers
```