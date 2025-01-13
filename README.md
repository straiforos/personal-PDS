# Personal Data Server PDS - triforce09.traiforos.com

## BlueSky PDS Fork submodule

- https://github.com/straiforos/pds

## Setting up submodule in the repo cron-backups/restore-scripts/PDS

```bash
git submodule add https://github.com/straiforos/pds.git restore-scripts/PDS
git submodule update --init --recursive
```

## Environment Setup

1. Create a `.env` file in the PDS directory:

```bash
PDS_JWT_SECRET=<generate-a-secure-random-string>
PDS_ADMIN_PASSWORD=<your-admin-password>
PDS_ADMIN_EMAIL=<your-email>
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
- Add restore script for PDS

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