# Dockerized Flask Application with PostgreSQL - Complete Task Guide

## Project Overview
This project demonstrates a complete DevOps pipeline for a Flask application with PostgreSQL database, using Docker Compose for orchestration and GitHub Actions for CI/CD automation.

## Architecture Components

### 1. Flask Application
- **Framework**: Flask (Python web framework)
- **Purpose**: RESTful API backend
- **Features**:
  - Health check endpoint
  - Database connectivity verification
  - CRUD operations for sample data
  - Environment-based configuration

### 2. PostgreSQL Database
- **Version**: PostgreSQL 15
- **Purpose**: Persistent data storage
- **Features**:
  - Automated schema initialization
  - Volume persistence
  - Custom initialization scripts

### 3. Docker Containerization
- **Flask Container**: 
  - Base image: Python 3.11-slim
  - Exposed port: 5000
  - Health checks enabled
- **PostgreSQL Container**:
  - Base image: PostgreSQL 15
  - Exposed port: 5432
  - Persistent volume for data

### 4. Docker Compose Orchestration
- **Network**: Custom bridge network for inter-service communication
- **Services**: Flask app and PostgreSQL
- **Environment**: Configuration via .env file
- **Dependencies**: Flask waits for PostgreSQL to be ready

### 5. GitHub Actions CI/CD
- **Trigger**: Push to main branch
- **Steps**:
  1. Checkout code
  2. Build Docker images
  3. Run tests
  4. Deploy to self-hosted server
  5. Health check verification

## Project Structure

```
.
├── app/
│   ├── __init__.py           # Flask app initialization
│   ├── models.py             # Database models
│   ├── routes.py             # API endpoints
│   └── config.py             # Configuration management
├── db/
│   └── init.sql              # Database initialization script
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions workflow
├── Dockerfile                # Flask app container definition
├── docker-compose.yml        # Multi-container orchestration
├── requirements.txt          # Python dependencies
├── .env.example              # Environment variables template
├── .dockerignore             # Docker build exclusions
└── README.md                 # Project documentation
```

## Database Configuration

### Environment Variables
```
DB_HOST: postgres
DB_PORT: 5432
DB_USER: postgres (default)
DB_PASSWORD: dragon (default)
DATABASE_URL: postgresql://postgres:dragon@postgres:5432/flaskdb
TEST_DATABASE_URL: postgresql://postgres:dragon@postgres:5432/testdb
```

### Database Schema
The initialization script creates:
- **users** table: id, username, email, created_at
- **products** table: id, name, description, price, created_at
- Sample data for testing

## Setup Instructions

### Prerequisites
- Docker and Docker Compose installed
- GitHub account with repository
- Self-hosted server with Docker installed
- SSH access to deployment server

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Test
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Build and run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

4. **Verify deployment**
   ```bash
   curl http://localhost:5000/health
   ```

### Database Initialization

The database is automatically initialized when the PostgreSQL container starts:
- Entry point script: `/docker-entrypoint-initdb.d/init.sql`
- Creates database schema
- Inserts sample data
- Runs only on first container creation

### API Endpoints

- `GET /health` - Health check endpoint
- `GET /api/users` - List all users
- `POST /api/users` - Create new user
- `GET /api/products` - List all products
- `POST /api/products` - Create new product
- `GET /db-check` - Verify database connectivity

## Docker Compose Services

### Flask Service
```yaml
- Container name: flask-app
- Port mapping: 5000:5000
- Depends on: postgres
- Auto-restart: always
- Health checks: enabled
```

### PostgreSQL Service
```yaml
- Container name: postgres-db
- Port mapping: 5432:5432
- Volume: postgres_data (persistent)
- Init scripts: ./db/init.sql
- Health checks: enabled
```

## GitHub Actions Workflow

### Workflow Triggers
- Push to `main` branch
- Pull requests to `main` branch
- Manual workflow dispatch

### Deployment Steps

1. **Build Phase**
   - Checkout code
   - Set up Docker Buildx
   - Build Flask and PostgreSQL images
   - Run unit tests

2. **Deploy Phase**
   - SSH to self-hosted server
   - Pull latest code
   - Stop existing containers
   - Start new containers
   - Run health checks

3. **Verification Phase**
   - Check container status
   - Verify API endpoints
   - Test database connectivity

### Required GitHub Secrets

```
SERVER_HOST: <your-server-ip>
SERVER_USER: <ssh-username>
SERVER_SSH_KEY: <private-ssh-key>
DB_USER: postgres
DB_PASSWORD: dragon
```

## Self-Hosted Server Setup

### Server Requirements
- Ubuntu 20.04+ or similar Linux distribution
- Docker 20.10+
- Docker Compose 2.0+
- SSH server enabled
- Firewall configured (ports 22, 5000, 5432)

### Initial Server Configuration

1. **Install Docker**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

2. **Install Docker Compose**
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Create deployment directory**
   ```bash
   mkdir -p ~/flask-app
   ```

4. **Configure SSH key authentication**
   ```bash
   # On your local machine
   ssh-keygen -t rsa -b 4096 -C "github-actions"
   # Copy public key to server
   ssh-copy-id user@server-ip
   ```

## Security Best Practices

1. **Environment Variables**: Never commit .env files
2. **Secrets Management**: Use GitHub Secrets for sensitive data
3. **Database Passwords**: Use strong passwords in production
4. **Network Isolation**: Use Docker networks for service communication
5. **SSL/TLS**: Configure reverse proxy (Nginx) for HTTPS
6. **Firewall**: Restrict access to necessary ports only

## Monitoring and Logging

### Container Logs
```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f flask-app
docker-compose logs -f postgres
```

### Health Checks
```bash
# Check container health
docker ps

# Test API health
curl http://localhost:5000/health

# Test database connectivity
curl http://localhost:5000/db-check
```

## Troubleshooting

### Common Issues

1. **Database connection refused**
   - Ensure PostgreSQL container is running
   - Check network connectivity
   - Verify environment variables

2. **Port already in use**
   - Stop conflicting services
   - Change port mapping in docker-compose.yml

3. **Permission denied errors**
   - Check file permissions
   - Ensure user is in docker group

4. **GitHub Actions deployment fails**
   - Verify SSH key is correct
   - Check server accessibility
   - Review workflow logs

## Production Deployment Checklist

- [ ] Update environment variables for production
- [ ] Configure reverse proxy (Nginx/Traefik)
- [ ] Set up SSL certificates (Let's Encrypt)
- [ ] Configure database backups
- [ ] Set up monitoring (Prometheus/Grafana)
- [ ] Configure log aggregation
- [ ] Implement rate limiting
- [ ] Set up automated backups
- [ ] Configure firewall rules
- [ ] Test disaster recovery procedures

## Maintenance

### Backup Database
```bash
docker exec postgres-db pg_dump -U postgres flaskdb > backup.sql
```

### Restore Database
```bash
docker exec -i postgres-db psql -U postgres flaskdb < backup.sql
```

### Update Application
```bash
git pull origin main
docker-compose down
docker-compose up --build -d
```

## Performance Optimization

1. **Use multi-stage Docker builds** - Reduce image size
2. **Implement caching** - Redis for session/data caching
3. **Connection pooling** - SQLAlchemy connection pool
4. **Load balancing** - Multiple Flask instances
5. **Database indexing** - Optimize query performance

## Future Enhancements

- [ ] Add Redis for caching
- [ ] Implement user authentication (JWT)
- [ ] Add API rate limiting
- [ ] Set up Kubernetes deployment
- [ ] Implement blue-green deployment
- [ ] Add comprehensive test suite
- [ ] Set up staging environment
- [ ] Implement API versioning
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Set up centralized logging (ELK stack)

## Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## License
MIT License

## Support
For issues and questions, please open an issue in the GitHub repository.
