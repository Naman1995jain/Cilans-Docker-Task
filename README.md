# Dockerized Flask Application with PostgreSQL

A production-ready Flask application with PostgreSQL database, containerized using Docker and automated deployment via GitHub Actions.

## 🚀 Features

- **Flask REST API** with SQLAlchemy ORM
- **PostgreSQL Database** with automated initialization
- **Docker Compose** orchestration for multi-container setup
- **GitHub Actions CI/CD** for automated testing and deployment
- **Health checks** and monitoring endpoints
- **Production-ready** with Gunicorn WSGI server
- **Database migrations** and sample data seeding

## 📋 Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Python 3.11+ (for local development)
- Git

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐
│                 │         │                  │
│  Flask App      │────────▶│  PostgreSQL DB   │
│  (Port 5000)    │         │  (Port 5432)     │
│                 │         │                  │
└─────────────────┘         └──────────────────┘
        │                            │
        └────────────────┬───────────┘
                         │
                  Docker Network
```

## 🛠️ Quick Start

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd Test
```

### 2. Create environment file

```bash
cp .env.example .env
```

Edit `.env` with your configuration if needed.

### 3. Build and run with Docker Compose

```bash
docker-compose up --build
```

### 4. Access the application

- **API Base URL**: http://localhost:5000
- **Health Check**: http://localhost:5000/health
- **Database Check**: http://localhost:5000/db-check

## 📡 API Endpoints

### General
- `GET /` - API information
- `GET /health` - Health check
- `GET /db-check` - Database connectivity check

### Users
- `GET /api/users` - List all users
- `GET /api/users/<id>` - Get user by ID
- `POST /api/users` - Create new user

### Products
- `GET /api/products` - List all products
- `GET /api/products/<id>` - Get product by ID
- `POST /api/products` - Create new product

### Orders
- `GET /api/orders` - List all orders
- `GET /api/orders/<id>` - Get order by ID
- `POST /api/orders` - Create new order

## 🧪 Testing API

### Get all users
```bash
curl http://localhost:5000/api/users
```

### Create a new user
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "email": "test@example.com"}'
```

### Get all products
```bash
curl http://localhost:5000/api/products
```

### Create a new product
```bash
curl -X POST http://localhost:5000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "New Product", "description": "Test product", "price": 99.99, "stock_quantity": 10}'
```

## 🗄️ Database

### Schema

The database is automatically initialized with the following tables:

- **users**: User accounts
- **products**: Product catalog
- **orders**: Customer orders
- **order_items**: Order line items

### Sample Data

The initialization script (`db/init.sql`) includes sample data for testing:
- 4 sample users
- 5 sample products

### Manual Database Access

```bash
# Connect to PostgreSQL container
docker exec -it postgres-db psql -U postgres -d flaskdb

# List tables
\dt

# Query users
SELECT * FROM users;

# Exit
\q
```

## 🔧 Development

### Local Development (without Docker)

1. **Create virtual environment**
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Set up PostgreSQL locally** and update `.env`

4. **Run the application**
```bash
python run.py
```

## 🚢 Deployment

### GitHub Actions Setup

1. **Add GitHub Secrets** (Settings → Secrets → Actions):
   - `SERVER_HOST`: Your server IP address
   - `SERVER_USER`: SSH username
   - `SERVER_SSH_KEY`: Private SSH key
   - `DB_USER`: Database username
   - `DB_PASSWORD`: Database password
   - `SECRET_KEY`: Flask secret key

2. **Push to main branch** to trigger deployment:
```bash
git add .
git commit -m "Deploy application"
git push origin main
```

### Manual Deployment to Self-Hosted Server

1. **SSH to your server**
```bash
ssh user@your-server-ip
```

2. **Clone repository**
```bash
git clone <your-repository-url>
cd Test
```

3. **Create .env file**
```bash
nano .env
# Add your environment variables
```

4. **Deploy with Docker Compose**
```bash
docker-compose up -d --build
```

5. **Verify deployment**
```bash
curl http://localhost:5000/health
```

## 📊 Monitoring

### View logs
```bash
# All services
docker-compose logs -f

# Flask app only
docker-compose logs -f flask-app

# PostgreSQL only
docker-compose logs -f postgres
```

### Check container status
```bash
docker-compose ps
```

### Check resource usage
```bash
docker stats
```

## 🔒 Security

- Environment variables for sensitive data
- Non-root user in Docker containers
- PostgreSQL password authentication
- GitHub Secrets for CI/CD credentials
- Network isolation via Docker networks

## 🧹 Maintenance

### Backup database
```bash
docker exec postgres-db pg_dump -U postgres flaskdb > backup_$(date +%Y%m%d).sql
```

### Restore database
```bash
docker exec -i postgres-db psql -U postgres flaskdb < backup.sql
```

### Update application
```bash
git pull origin main
docker-compose down
docker-compose up -d --build
```

### Clean up Docker resources
```bash
docker system prune -a
docker volume prune
```

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FLASK_ENV` | Environment (development/production) | `production` |
| `DB_USER` | PostgreSQL username | `postgres` |
| `DB_PASSWORD` | PostgreSQL password | `dragon` |
| `DB_HOST` | Database host | `postgres` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | `flaskdb` |
| `SECRET_KEY` | Flask secret key | Random |

## 🐛 Troubleshooting

### Port already in use
```bash
# Find process using port 5000
lsof -i :5000  # On Linux/Mac
netstat -ano | findstr :5000  # On Windows

# Stop the process or change port in docker-compose.yml
```

### Database connection refused
```bash
# Check if PostgreSQL is running
docker-compose ps

# Restart services
docker-compose restart
```

### Permission denied errors
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

## 📚 Project Structure

```
.
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── config.py            # Configuration
│   ├── models.py            # Database models
│   └── routes.py            # API routes
├── db/
│   └── init.sql             # Database initialization
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD workflow
├── Dockerfile               # Flask container
├── docker-compose.yml       # Multi-container setup
├── requirements.txt         # Python dependencies
├── run.py                   # Application entry point
├── .env.example             # Environment template
├── .dockerignore           # Docker exclusions
├── .gitignore              # Git exclusions
├── TASK.md                 # Complete task guide
└── README.md               # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 👥 Support

For issues and questions:
- Open an issue on GitHub
- Check the TASK.md for detailed documentation

## 🎯 Next Steps

- [ ] Add Redis for caching
- [ ] Implement JWT authentication
- [ ] Add API rate limiting
- [ ] Set up Nginx reverse proxy
- [ ] Configure SSL/TLS
- [ ] Add comprehensive tests
- [ ] Implement API documentation (Swagger)
- [ ] Set up monitoring (Prometheus/Grafana)

---

**Built with ❤️ using Flask, PostgreSQL, and Docker**
