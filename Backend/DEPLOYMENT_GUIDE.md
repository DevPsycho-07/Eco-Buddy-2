# 🚀 Eco Daily Score - Deployment Guide

Complete guide for deploying the Eco Daily Score backend to production environments.

**Version:** 1.0.0  
**Framework:** ASP.NET Core 8.0  
**Last Updated:** February 16, 2026

---

## 📑 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Configuration](#configuration)
4. [Database Setup](#database-setup)
5. [Deployment Options](#deployment-options)
6. [Security Checklist](#security-checklist)
7. [Monitoring & Logging](#monitoring--logging)
8. [Backup & Recovery](#backup--recovery)
9. [Scaling](#scaling)
10. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

### Server Requirements

**Minimum:**
- **CPU:** 2 cores
- **RAM:** 2 GB
- **Disk:** 10 GB SSD
- **OS:** Windows Server 2019+ / Ubuntu 20.04+ / RHEL 8+

**Recommended (Production):**
- **CPU:** 4 cores
- **RAM:** 8 GB
- **Disk:** 50 GB SSD
- **OS:** Ubuntu 22.04 LTS / Windows Server 2022

### Software Requirements

1. **.NET 8 Runtime** (or SDK for build on server)
   ```bash
   # Ubuntu/Debian
   wget https://dot.net/v1/dotnet-install.sh
   sudo bash dotnet-install.sh --channel 8.0 --runtime aspnetcore
   
   # Windows Server
   # Download from https://dotnet.microsoft.com/download/dotnet/8.0
   ```

2. **Reverse Proxy** (recommended)
   - **Nginx** (Linux)
   - **IIS** (Windows)
   - **Apache** (Linux)

3. **SQLite** (embedded, no separate installation needed)

4. **Firebase Account** (for push notifications)
   - Create project at https://console.firebase.google.com
   - Generate service account credentials JSON

5. **SMTP Server** (for emails)
   - Gmail (with app password)
   - SendGrid
   - Amazon SES
   - Custom SMTP server

---

## 🌍 Environment Setup

### Linux (Ubuntu 22.04)

1. **Install .NET 8 Runtime**
   ```bash
   # Add Microsoft package repository
   wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   rm packages-microsoft-prod.deb
   
   # Install ASP.NET Core Runtime
   sudo apt-get update
   sudo apt-get install -y aspnetcore-runtime-8.0
   
   # Verify installation
   dotnet --info
   ```

2. **Create application user**
   ```bash
   sudo useradd -m -s /bin/bash ecobackend
   sudo usermod -aG sudo ecobackend
   ```

3. **Create application directory**
   ```bash
   sudo mkdir -p /var/www/ecobackend
   sudo chown ecobackend:ecobackend /var/www/ecobackend
   ```

4. **Install Nginx**
   ```bash
   sudo apt-get install -y nginx
   sudo systemctl enable nginx
   sudo systemctl start nginx
   ```

5. **Configure firewall**
   ```bash
   sudo ufw allow 'Nginx Full'
   sudo ufw allow OpenSSH
   sudo ufw enable
   ```

### Windows Server 2022

1. **Install .NET 8 Hosting Bundle**
   - Download from https://dotnet.microsoft.com/download/dotnet/8.0
   - Install "ASP.NET Core Runtime 8.0 - Windows Hosting Bundle"
   - Restart server

2. **Install IIS**
   ```powershell
   # Open PowerShell as Administrator
   Install-WindowsFeature -Name Web-Server -IncludeManagementTools
   Install-WindowsFeature -Name Web-Asp-Net45
   ```

3. **Create application folder**
   ```powershell
   New-Item -Path "C:\inetpub\ecobackend" -ItemType Directory
   ```

---

## ⚙️ Configuration

### Production appsettings.json

Create `appsettings.Production.json` (NEVER commit with real credentials):

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning",
      "EcoBackend": "Information"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=/var/www/ecobackend/data/eco.db"
  },
  "JWT": {
    "Secret": "CHANGE-THIS-TO-STRONG-SECRET-MIN-64-CHARS-RANDOM-STRING-FOR-PRODUCTION",
    "ValidIssuer": "EcoBackendAPI",
    "ValidAudience": "EcoBackendClient",
    "ExpiryInHours": 24,
    "RefreshTokenExpiryInDays": 7
  },
  "EmailSettings": {
    "SmtpServer": "smtp.gmail.com",
    "SmtpPort": 587,
    "UseSsl": true,
    "SenderEmail": "noreply@yourdomain.com",
    "SenderName": "Eco Daily Score",
    "Username": "noreply@yourdomain.com",
    "Password": "YOUR-APP-PASSWORD"
  },
  "Firebase": {
    "CredentialsPath": "/var/www/ecobackend/config/firebase-credentials.json"
  },
  "Hangfire": {
    "DashboardEnabled": false,
    "StoragePath": "/var/www/ecobackend/data/hangfire.db"
  },
  "Cors": {
    "AllowedOrigins": [
      "https://yourdomain.com",
      "https://www.yourdomain.com",
      "https://app.yourdomain.com"
    ]
  },
  "RateLimiting": {
    "Enabled": true,
    "PermitLimit": 100,
    "Window": "00:01:00"
  }
}
```

### Environment Variables

For sensitive data, use environment variables instead of config files:

**Linux:**
```bash
# Add to /etc/environment or use systemd service file
export JWT__Secret="your-production-secret-key"
export EmailSettings__Password="your-smtp-password"
export Firebase__CredentialsPath="/var/www/ecobackend/config/firebase-credentials.json"
export ASPNETCORE_ENVIRONMENT="Production"
```

**Windows:**
```powershell
# Set system environment variables
[Environment]::SetEnvironmentVariable("JWT__Secret", "your-production-secret-key", "Machine")
[Environment]::SetEnvironmentVariable("EmailSettings__Password", "your-smtp-password", "Machine")
[Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Production", "Machine")
```

### Secrets Management

**For high security, use:**
- **Azure Key Vault** (Azure deployments)
- **AWS Secrets Manager** (AWS deployments)
- **HashiCorp Vault** (on-premises)
- **Kubernetes Secrets** (Kubernetes deployments)

---

## 🗄️ Database Setup

### Initial Database Migration

1. **Create data directory**
   ```bash
   # Linux
   sudo mkdir -p /var/www/ecobackend/data
   sudo chown ecobackend:ecobackend /var/www/ecobackend/data
   
   # Windows
   New-Item -Path "C:\inetpub\ecobackend\data" -ItemType Directory
   ```

2. **Apply migrations**
   
   Option A: Using EF Core CLI (requires .NET SDK on server)
   ```bash
   cd /var/www/ecobackend
   dotnet ef database update --project EcoBackend.Infrastructure --startup-project EcoBackend.API
   ```
   
   Option B: Apply migrations on startup (recommended)
   - Migrations are applied automatically on first run
   - Seeding only runs in Development environment

3. **Set permissions**
   ```bash
   # Linux - ensure write access
   sudo chmod 755 /var/www/ecobackend/data
   sudo chown -R www-data:www-data /var/www/ecobackend/data
   ```

### Database Backup

**Automated backup script (Linux):**
```bash
#!/bin/bash
# /usr/local/bin/backup-ecobackend-db.sh

BACKUP_DIR="/var/backups/ecobackend"
DB_PATH="/var/www/ecobackend/data/eco.db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/eco_backup_$TIMESTAMP.db"

# Create backup directory
mkdir -p $BACKUP_DIR

# Copy database
cp $DB_PATH $BACKUP_FILE

# Compress
gzip $BACKUP_FILE

# Delete backups older than 30 days
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE.gz"
```

**Schedule with cron:**
```bash
# Edit crontab
sudo crontab -e

# Add daily backup at 2 AM
0 2 * * * /usr/local/bin/backup-ecobackend-db.sh >> /var/log/ecobackend-backup.log 2>&1
```

---

## 🚢 Deployment Options

### Option 1: Linux with Nginx (Recommended)

#### 1. Build Application

```bash
# On development machine
cd Backend/EcoBackend.API
dotnet publish -c Release -o ./publish

# Create deployment package
tar -czf ecobackend-release.tar.gz publish/
```

#### 2. Deploy to Server

```bash
# Transfer to server
scp ecobackend-release.tar.gz user@your-server:/tmp/

# On server
cd /var/www/ecobackend
sudo tar -xzf /tmp/ecobackend-release.tar.gz --strip-components=1
sudo chown -R www-data:www-data /var/www/ecobackend
```

#### 3. Create Systemd Service

```bash
sudo nano /etc/systemd/system/ecobackend.service
```

```ini
[Unit]
Description=Eco Daily Score Backend API
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/ecobackend
ExecStart=/usr/bin/dotnet /var/www/ecobackend/EcoBackend.API.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=ecobackend
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```

#### 4. Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/ecobackend
```

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    # SSL certificates (use Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Proxy settings
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # File upload size limit
    client_max_body_size 10M;
    
    # Access logs
    access_log /var/log/nginx/ecobackend-access.log;
    error_log /var/log/nginx/ecobackend-error.log;
}
```

#### 5. Enable and Start Services

```bash
# Enable Nginx site
sudo ln -s /etc/nginx/sites-available/ecobackend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Start application
sudo systemctl enable ecobackend
sudo systemctl start ecobackend
sudo systemctl status ecobackend
```

#### 6. Setup SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.yourdomain.com

# Auto-renewal is configured automatically
# Test renewal
sudo certbot renew --dry-run
```

---

### Option 2: Windows with IIS

#### 1. Build Application

```powershell
# On development machine
cd Backend\EcoBackend.API
dotnet publish -c Release -o .\publish

# Copy to server (via RDP, network share, or FTP)
```

#### 2. Configure IIS

1. **Open IIS Manager**
2. **Create Application Pool:**
   - Name: EcoBackend
   - .NET CLR Version: No Managed Code
   - Managed Pipeline Mode: Integrated
   - Identity: ApplicationPoolIdentity

3. **Create Website:**
   - Site Name: EcoBackend
   - Physical Path: C:\inetpub\ecobackend
   - Application Pool: EcoBackend
   - Binding: https, Port 443
   - Host Name: api.yourdomain.com

4. **Install URL Rewrite Module** (for HTTPS redirect)
   - Download from https://www.iis.net/downloads/microsoft/url-rewrite

5. **Configure web.config** (auto-generated by publish)
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <configuration>
     <system.webServer>
       <handlers>
         <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
       </handlers>
       <aspNetCore processPath="dotnet"
                   arguments=".\EcoBackend.API.dll"
                   stdoutLogEnabled="false"
                   stdoutLogFile=".\logs\stdout"
                   hostingModel="inprocess">
         <environmentVariables>
           <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
         </environmentVariables>
       </aspNetCore>
     </system.webServer>
   </configuration>
   ```

6. **Configure SSL Certificate:**
   - Use Let's Encrypt with win-acme
   - Or use commercial certificate
   - Bind certificate to IIS site

---

### Option 3: Docker Container

#### 1. Create Dockerfile

```dockerfile
# Backend/Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["EcoBackend.API/EcoBackend.API.csproj", "EcoBackend.API/"]
COPY ["EcoBackend.Core/EcoBackend.Core.csproj", "EcoBackend.Core/"]
COPY ["EcoBackend.Infrastructure/EcoBackend.Infrastructure.csproj", "EcoBackend.Infrastructure/"]
RUN dotnet restore "EcoBackend.API/EcoBackend.API.csproj"
COPY . .
WORKDIR "/src/EcoBackend.API"
RUN dotnet build "EcoBackend.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EcoBackend.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create directories
RUN mkdir -p /app/data /app/media/profile_pictures

# Set environment
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80

ENTRYPOINT ["dotnet", "EcoBackend.API.dll"]
```

#### 2. Create docker-compose.yml

```yaml
version: '3.8'

services:
  ecobackend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ecobackend-api
    restart: unless-stopped
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - JWT__Secret=${JWT_SECRET}
      - EmailSettings__Password=${SMTP_PASSWORD}
    volumes:
      - ./data:/app/data
      - ./media:/app/media
      - ./config/firebase-credentials.json:/app/config/firebase-credentials.json:ro
    networks:
      - ecobackend-network

  nginx:
    image: nginx:alpine
    container_name: ecobackend-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - ecobackend
    networks:
      - ecobackend-network

networks:
  ecobackend-network:
    driver: bridge

volumes:
  data:
  media:
```

#### 3. Build and Run

```bash
# Create .env file
cat > .env <<EOF
JWT_SECRET=your-production-secret-key
SMTP_PASSWORD=your-smtp-password
EOF

# Build and start
docker-compose up -d

# View logs
docker-compose logs -f ecobackend

# Stop
docker-compose down
```

---

### Option 4: Cloud Platforms

#### Azure App Service

```bash
# Install Azure CLI
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Login
az login

# Create resource group
az group create --name EcoBackendRG --location eastus

# Create app service plan
az appservice plan create --name EcoBackendPlan --resource-group EcoBackendRG --sku B1 --is-linux

# Create web app
az webapp create --name ecobackend-api --resource-group EcoBackendRG --plan EcoBackendPlan --runtime "DOTNETCORE:8.0"

# Configure app settings
az webapp config appsettings set --name ecobackend-api --resource-group EcoBackendRG --settings \
  ASPNETCORE_ENVIRONMENT=Production \
  JWT__Secret="your-secret" \
  EmailSettings__Password="your-password"

# Deploy
cd Backend/EcoBackend.API
az webapp up --name ecobackend-api --resource-group EcoBackendRG
```

#### AWS Elastic Beanstalk

```bash
# Install EB CLI
pip install awsebcli

# Initialize
cd Backend
eb init -p "64bit Amazon Linux 2 v2.6.0 running .NET Core" ecobackend-api

# Create environment
eb create ecobackend-prod

# Set environment variables
eb setenv ASPNETCORE_ENVIRONMENT=Production JWT__Secret="your-secret"

# Deploy
eb deploy
```

---

## 🔒 Security Checklist

### Pre-Deployment

- [ ] Change JWT secret to strong random 64+ character string
- [ ] Use HTTPS only (SSL/TLS certificates)
- [ ] Set `ASPNETCORE_ENVIRONMENT=Production`
- [ ] Disable Swagger UI in production (`if (app.Environment.IsDevelopment())`)
- [ ] Disable Hangfire dashboard or secure with authorization
- [ ] Configure CORS to allow only trusted origins
- [ ] Use environment variables or secrets manager for sensitive data
- [ ] Enable rate limiting
- [ ] Review and remove any debug/test code
- [ ] Ensure database is not publicly accessible

### Post-Deployment

- [ ] Test all endpoints with production configuration
- [ ] Verify SSL certificate is valid
- [ ] Check security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- [ ] Test authentication and authorization
- [ ] Verify CORS configuration
- [ ] Review application logs for errors
- [ ] Set up monitoring and alerting
- [ ] Document recovery procedures

### Ongoing

- [ ] Regular security updates for .NET and packages
- [ ] Rotate JWT secrets periodically
- [ ] Monitor for suspicious activity
- [ ] Regular database backups
- [ ] Review access logs
- [ ] Penetration testing

---

## 📊 Monitoring & Logging

### Application Insights (Azure)

```csharp
// In Program.cs
builder.Services.AddApplicationInsightsTelemetry(
    builder.Configuration["ApplicationInsights:ConnectionString"]);
```

### Serilog (Structured Logging)

1. **Install packages:**
   ```bash
   dotnet add package Serilog.AspNetCore
   dotnet add package Serilog.Sinks.File
   ```

2. **Configure in Program.cs:**
   ```csharp
   using Serilog;
   
   Log.Logger = new LoggerConfiguration()
       .WriteTo.Console()
       .WriteTo.File("logs/ecobackend-.txt", rollingInterval: RollingInterval.Day)
       .CreateLogger();
   
   builder.Host.UseSerilog();
   ```

### Health Checks

Monitor application health at `/health` endpoint:

```bash
# Check health
curl https://api.yourdomain.com/health

# Expected response
{
  "status": "Healthy",
  "totalDuration": "00:00:00.0234567"
}
```

### Monitoring Tools

- **Uptime Monitoring:** UptimeRobot, Pingdom, StatusCake
- **APM:** Application Insights, New Relic, Datadog
- **Logs:** ELK Stack, Splunk, CloudWatch
- **Metrics:** Prometheus + Grafana

---

## 💾 Backup & Recovery

### Backup Strategy

1. **Database:** Daily automated backups (see Database Setup)
2. **Configuration:** Version control (Git)
3. **Media Files:** Daily sync to cloud storage
4. **Logs:** Rotate and archive weekly

### Recovery Procedure

1. **Stop application**
   ```bash
   sudo systemctl stop ecobackend
   ```

2. **Restore database**
   ```bash
   cp /var/backups/ecobackend/eco_backup_YYYYMMDD.db /var/www/ecobackend/data/eco.db
   ```

3. **Restore media files**
   ```bash
   rsync -av /backups/media/ /var/www/ecobackend/media/
   ```

4. **Start application**
   ```bash
   sudo systemctl start ecobackend
   ```

5. **Verify**
   ```bash
   curl https://api.yourdomain.com/health
   ```

---

## 📈 Scaling

### Vertical Scaling

- Increase server CPU/RAM
- Optimize database queries
- Enable response caching
- Use CDN for static files

### Horizontal Scaling

For high traffic, deploy multiple instances:

1. **Load Balancer** (Nginx, AWS ALB, Azure Load Balancer)
2. **Shared Database** (move to PostgreSQL/MySQL)
3. **Shared File Storage** (Azure Blob, AWS S3)
4. **Distributed Cache** (Redis)
5. **Session Persistence** (Redis, database)

---

## 🐛 Troubleshooting

### Application Won't Start

```bash
# Check service status
sudo systemctl status ecobackend

# View logs
sudo journalctl -u ecobackend -n 100 --no-pager

# Check file permissions
sudo chown -R www-data:www-data /var/www/ecobackend
```

### Database Connection Errors

- Verify database file path in appsettings
- Check file permissions
- Ensure migrations are applied

### 502 Bad Gateway (Nginx)

- Check if application is running: `sudo systemctl status ecobackend`
- Verify proxy_pass URL in Nginx config
- Check `proxy_read_timeout` setting

### High Memory Usage

- Review query performance
- Check for memory leaks
- Enable garbage collection logging
- Consider increasing server resources

### SSL Certificate Issues

```bash
# Renew Let's Encrypt certificate
sudo certbot renew

# Test SSL configuration
curl -I https://api.yourdomain.com
```

---

## 📞 Support

For deployment issues:
- Review this guide
- Check server logs: `/var/log/nginx/` and `journalctl -u ecobackend`
- Verify configuration files
- Contact: devops@ecodailyscore.com

---

**Good Luck with Your Deployment! 🚀**

Last Updated: February 16, 2026
