FROM alpine:latest

# Install PowerDNS and SQLite
RUN apk add --no-cache \
    pdns \
    pdns-backend-sqlite3 \
    sqlite

# Create directories and set permissions (pdns user already exists from package)
RUN mkdir -p /var/lib/pdns && \
    mkdir -p /var/run/pdns && \
    chown -R pdns:pdns /var/lib/pdns /var/run/pdns

# Copy configuration and schema
COPY docker-pdns.conf /etc/pdns/pdns.conf
COPY schema.sqlite3.sql /tmp/schema.sqlite3.sql

# Initialize SQLite database with schema
RUN sqlite3 /var/lib/pdns/pdns.sqlite3 < /tmp/schema.sqlite3.sql && \
    chown pdns:pdns /var/lib/pdns/pdns.sqlite3 && \
    rm /tmp/schema.sqlite3.sql

# Expose DNS and API ports
EXPOSE 53/udp 53/tcp 8081/tcp

# Switch to pdns user
USER pdns

# Start PowerDNS in foreground
CMD ["pdns_server", "--daemon=no", "--guardian=no"]
