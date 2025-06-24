# PowerDNS Docker Image

A minimal Docker image for PowerDNS Authoritative Server with SQLite backend.

## Features

- Alpine Linux base (lightweight)
- PowerDNS Authoritative Server
- SQLite backend for DNS records
- REST API enabled with authentication
- Web interface for monitoring

## Building the Image

```bash
docker build -t powerdns .
```

## Running the Container

### Basic Usage

```bash
docker run -d \
  -p 5353:53/udp \
  -p 5353:53/tcp \
  -p 8081:8081 \
  --name powerdns \
  powerdns
```

### With Persistent Storage

```bash
docker run -d \
  -p 5353:53/udp \
  -p 5353:53/tcp \
  -p 8081:8081 \
  -v $(pwd)/data:/var/lib/pdns \
  --name powerdns \
  powerdns
```

### Using Standard Port 53 (Linux/Servers)

If port 53 is available (typically on Linux servers), you can use:

```bash
docker run -d \
  -p 53:53/udp \
  -p 53:53/tcp \
  -p 8081:8081 \
  --name powerdns \
  powerdns
```

## Configuration

### Ports

- **5353/udp, 5353/tcp**: DNS queries
- **8081/tcp**: REST API and web interface

> **Note for macOS users**: Port 53 is occupied by Apple's mDNSResponder service by default, so this image uses port 5353 to avoid conflicts.

### API Access

- **URL**: http://localhost:8081
- **API Key**: `secret`
- **Documentation**: PowerDNS API documentation at `/api/docs`

### Environment

The container runs PowerDNS as the `pdns` user for security.

## API Examples

### List Zones

```bash
curl -H "X-API-Key: secret" http://localhost:8081/api/v1/servers/localhost/zones
```

### Create a Zone

```bash
curl -X POST \
  -H "X-API-Key: secret" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "example.com.",
    "kind": "Native",
    "rrsets": [
      {
        "name": "example.com.",
        "type": "SOA",
        "ttl": 3600,
        "records": [
          {
            "content": "ns1.example.com. admin.example.com. 1 3600 1800 604800 3600",
            "disabled": false
          }
        ]
      }
    ]
  }' \
  http://localhost:8081/api/v1/servers/localhost/zones
```

### Add an A Record

```bash
curl -X PATCH \
  -H "X-API-Key: secret" \
  -H "Content-Type: application/json" \
  -d '{
    "rrsets": [
      {
        "name": "www.example.com.",
        "type": "A",
        "ttl": 300,
        "changetype": "REPLACE",
        "records": [
          {
            "content": "192.168.1.100",
            "disabled": false
          }
        ]
      }
    ]
  }' \
  http://localhost:8081/api/v1/servers/localhost/zones/example.com.
```

## Testing DNS Resolution

```bash
# Test with dig (using port 5353)
dig @localhost -p 5353 example.com SOA
dig @localhost -p 5353 www.example.com A

# Test with nslookup
nslookup www.example.com localhost
```

## Container Management

### Start/Stop

```bash
# Stop container
docker stop powerdns

# Start container
docker start powerdns

# Remove container
docker rm powerdns
```

### Port Conflicts on macOS

On macOS, you may encounter port conflicts due to:
- **mDNSResponder**: Apple's built-in multicast DNS service
- **dnsmasq**: From development tools like Laravel Herd
- **Local DNS servers**: Other development setups

If you encounter port conflicts, try different ports:

```bash
docker run -d \
  -p 9053:53/udp \
  -p 9053:53/tcp \
  -p 8081:8081 \
  --name powerdns \
  powerdns

# Test with alternative port
dig @localhost -p 9053 example.com SOA
```

### View Logs

```bash
docker logs powerdns
docker logs -f powerdns  # Follow logs
```

### Access Container Shell

```bash
docker exec -it powerdns sh
```

## Configuration Files

- **docker-pdns.conf**: PowerDNS configuration optimized for containers
- **schema.sqlite3.sql**: Database schema for SQLite backend
- **Dockerfile**: Container build instructions

## Security Notes

- Change the default API key (`secret`) in production
- Consider restricting API access with `webserver-allow-from`
- Run behind a reverse proxy for HTTPS in production
- Regularly backup the SQLite database

## Troubleshooting

### Check PowerDNS Status

```bash
docker exec powerdns pdns_control status
```

### Database Location

The SQLite database is located at `/var/lib/pdns/pdns.sqlite3` inside the container.

### Common Issues

1. **Port conflicts**: Ensure ports 53 and 8081 are not in use
2. **Permission issues**: The container runs as user `pdns`
3. **API authentication**: Always include the `X-API-Key` header
