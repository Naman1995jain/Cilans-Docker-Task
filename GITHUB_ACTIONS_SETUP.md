# GitHub Actions Setup Guide - Self-Hosted Windows Runner

## Step 1: Add Workflow File to GitHub

Since you cannot push workflow files via Git (OAuth scope limitation), add it via GitHub web interface:

### Instructions:

1. **Go to your repository**: 
   https://github.com/Naman1995jain/Cilans-Docker-Task

2. **Create new file**:
   - Click "Add file" → "Create new file"
   - Filename: `.github/workflows/deploy.yml`

3. **Copy workflow content**:
   - Open: `c:\Ai project\Test\.github\workflows\deploy.yml`
   - Copy all content (Ctrl+A, Ctrl+C)
   - Paste into GitHub editor

4. **Commit**:
   - Commit message: "Add CI/CD workflow for self-hosted Windows runner"
   - Click "Commit new file"

---

## Step 2: Add GitHub Secrets

Go to: Settings → Secrets and variables → Actions → New repository secret

Add these three secrets:

### 1. DB_USER
```
Name: DB_USER
Secret: postgres
```

### 2. DB_PASSWORD
```
Name: DB_PASSWORD
Secret: dragon
```

### 3. SECRET_KEY
Generate a random key using PowerShell:
```powershell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
```
Copy the output and add as secret:
```
Name: SECRET_KEY
Secret: [paste generated key]
```

---

## Step 3: Set Up Self-Hosted Runner

### Open PowerShell as Administrator

```powershell
# Create runner directory
mkdir C:\actions-runner
cd C:\actions-runner

# Download runner package
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-win-x64-2.329.0.zip -OutFile actions-runner-win-x64-2.329.0.zip

# Validate hash (optional)
if((Get-FileHash -Path actions-runner-win-x64-2.329.0.zip -Algorithm SHA256).Hash.ToUpper() -ne 'f60be5ddf373c52fd735388c3478536afd12bfd36d1d0777c6b855b758e70f25'.ToUpper()){ throw 'Computed checksum did not match' }

# Extract installer
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.329.0.zip", "$PWD")

# Configure runner (use your token from GitHub)
.\config.cmd --url https://github.com/Naman1995jain/Cilans-Docker-Task --token A7KMUR7TZPQZCWLH5Z46EVDJIN2WA

# Run the runner
.\run.cmd
```

**Note**: The token `A7KMUR7TZPQZCWLH5Z46EVDJIN2WA` expires quickly. If it doesn't work:
1. Go to: https://github.com/Naman1995jain/Cilans-Docker-Task/settings/actions/runners/new
2. Copy the new token from the configuration command
3. Use it in the `.\config.cmd` command above

---

## Step 4: Install Runner as Windows Service (Optional but Recommended)

After configuring the runner, install it as a service so it runs automatically:

```powershell
# Stop the runner if it's running (Ctrl+C)

# Install as service
.\svc.cmd install

# Start the service
.\svc.cmd start

# Check status
.\svc.cmd status
```

---

## Step 5: Test Locally First

Before triggering the workflow, test your application:

```powershell
cd "C:\Ai project\Test"

# Build and start
docker-compose up --build -d

# Wait 30 seconds
Start-Sleep -Seconds 30

# Test endpoints
Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing

# View logs
docker-compose logs -f
```

**Access your application**:
- Frontend: http://localhost
- Backend: http://localhost:5000
- Health: http://localhost:5000/health

---

## Step 6: Trigger the Workflow

Once everything is set up:

### Option 1: Push to trigger
```powershell
cd "C:\Ai project\Test"
git add .
git commit -m "Trigger workflow"
git push origin main
```

### Option 2: Manual trigger
1. Go to: https://github.com/Naman1995jain/Cilans-Docker-Task/actions
2. Click "Build and Deploy Flask Application"
3. Click "Run workflow" → "Run workflow"

---

## Workflow Overview

Your CI/CD pipeline has 3 jobs:

### Job 1: Build and Test
- Installs Python dependencies
- Lints code with flake8
- Builds Docker images
- Starts all services
- Tests all API endpoints
- Tests frontend
- Stops services

### Job 2: Deploy
- Creates .env file with secrets
- Stops old containers
- Builds and starts new containers
- Verifies deployment
- Tests all endpoints
- Displays application URLs

### Job 3: Cleanup
- Removes old Docker images
- Cleans up unused networks
- Frees up disk space

---

## Monitoring the Workflow

1. **View workflow runs**:
   https://github.com/Naman1995jain/Cilans-Docker-Task/actions

2. **Check runner status**:
   https://github.com/Naman1995jain/Cilans-Docker-Task/settings/actions/runners

3. **View logs**:
   - Click on any workflow run
   - Click on job name
   - Expand steps to see detailed logs

---

## Troubleshooting

### Runner not appearing in GitHub
- Check if runner service is running: `.\svc.cmd status`
- Restart service: `.\svc.cmd stop` then `.\svc.cmd start`
- Check runner logs in: `C:\actions-runner\_diag\`

### Workflow fails
- Check workflow logs in GitHub Actions tab
- Verify all secrets are added correctly
- Ensure Docker Desktop is running
- Check local Docker: `docker ps`

### Port conflicts
- Stop existing containers: `docker-compose down`
- Check ports: `netstat -ano | findstr :80` and `netstat -ano | findstr :5000`

### Permission errors
- Run PowerShell as Administrator
- Check Docker Desktop settings
- Ensure user is in docker-users group

---

## Quick Reference Commands

```powershell
# Start application
docker-compose up -d

# Stop application
docker-compose down

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Restart services
docker-compose restart

# Rebuild
docker-compose up --build -d

# Clean up
docker-compose down -v
docker system prune -a
```

---

## Success Checklist

- [ ] Workflow file added to GitHub
- [ ] All 3 secrets added (DB_USER, DB_PASSWORD, SECRET_KEY)
- [ ] Self-hosted runner configured and running
- [ ] Runner appears as "Idle" in GitHub settings
- [ ] Local test successful (docker-compose up)
- [ ] Workflow triggered and passed
- [ ] Application accessible at http://localhost

---

**You're all set! Your CI/CD pipeline is ready to automate your deployments.**
