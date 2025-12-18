# Quick Start Guide - Dockerized Flask Application

## Get Started in 3 Steps

### Step 1: Build and Run
```bash
# Make sure Docker is running, then:
docker-compose up --build
```

### Step 2: Wait for Services (30 seconds)
The application will automatically:
- Start PostgreSQL database
- Run initialization script (`db/init.sql`)
- Create tables and insert sample data
- Start Flask application

### Step 3: Test the Application
Open your browser or use curl:
```bash
# Health check
curl http://localhost:5000/health

# Database check
curl http://localhost:5000/db-check

# Get all users
curl http://localhost:5000/api/users

# Get all products
curl http://localhost:5000/api/products
```

## 📋 What's Included

### ✅ Flask Application
- RESTful API with multiple endpoints
- SQLAlchemy ORM for database operations
- Production-ready with Gunicorn
- Health checks and monitoring

### ✅ PostgreSQL Database
- Automated schema initialization
- Sample data for testing
- Persistent volume storage
- Health checks enabled

### ✅ Docker Setup
- Multi-container orchestration
- Custom network for service communication
- Environment-based configuration
- Automatic dependency management

### ✅ GitHub Actions CI/CD
- Automated testing on push
- Build and deploy workflow
- Self-hosted server deployment
- Health verification

## 🧪 Testing

### Option 1: PowerShell (Windows)
```powershell
.\test_api.ps1
```

### Option 2: Manual Testing
```bash
# Create a new user
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"john_doe","email":"john@example.com"}'

# Create a new product
curl -X POST http://localhost:5000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"High-end laptop","price":1299.99,"stock_quantity":10}'

# Create an order
curl -X POST http://localhost:5000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"items":[{"product_id":1,"quantity":2}]}'
```

## 🗄️ Database Access

### Connect to PostgreSQL
```bash
# Using Docker
docker exec -it postgres-db psql -U postgres -d flaskdb

# Common queries
SELECT * FROM users;
SELECT * FROM products;
SELECT * FROM orders;
```

### Database Credentials
- **Host**: localhost (or `postgres` from within Docker network)
- **Port**: 5432
- **User**: postgres
- **Password**: dragon
- **Database**: flaskdb

## 📊 Monitoring

### View Logs
```bash
# All services
docker-compose logs -f

# Flask app only
docker-compose logs -f flask-app

# Database only
docker-compose logs -f postgres
```

### Check Status
```bash
# Container status
docker-compose ps

# Resource usage
docker stats
```

## 🛠️ Common Commands

### Start Application
```bash
docker-compose up -d
```

### Stop Application
```bash
docker-compose down
```

### Restart Application
```bash
docker-compose restart
```

### Rebuild Application
```bash
docker-compose up -d --build
```

### View Container Logs
```bash
docker-compose logs -f [service-name]
```

### Access Flask Container Shell
```bash
docker exec -it flask-app /bin/bash
```

### Access PostgreSQL Container Shell
```bash
docker exec -it postgres-db /bin/bash
```

## 🔧 Configuration

### Environment Variables (.env)
```env
DB_USER=postgres
DB_PASSWORD=dragon
DB_HOST=postgres
DB_PORT=5432
DB_NAME=flaskdb
FLASK_ENV=production
```

### Change Database Password
1. Edit `.env` file
2. Update `DB_PASSWORD`
3. Restart containers: `docker-compose down && docker-compose up -d`

### Change Flask Port
1. Edit `docker-compose.yml`
2. Change `ports: "5000:5000"` to desired port
3. Restart: `docker-compose up -d`

## 🚢 Deployment to Production

### GitHub Actions (Automated)
1. Add GitHub Secrets:
   - `SERVER_HOST`
   - `SERVER_USER`
   - `SERVER_SSH_KEY`
   - `DB_USER`
   - `DB_PASSWORD`
   - `SECRET_KEY`

2. Push to main branch:
```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

### Manual Deployment
1. SSH to your server
2. Clone repository
3. Create `.env` file
4. Run: `docker-compose up -d --build`

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Windows
netstat -ano | findstr :5000
# Kill the process using the port

# Or change port in docker-compose.yml
```

### Database Connection Failed
```bash
# Check if PostgreSQL is running
docker-compose ps

# View PostgreSQL logs
docker-compose logs postgres

# Restart services
docker-compose restart
```

### Container Won't Start
```bash
# View logs
docker-compose logs

# Remove volumes and restart
docker-compose down -v
docker-compose up -d --build
```

### Permission Denied
```bash
# Windows: Run PowerShell as Administrator
# Linux: Add user to docker group
sudo usermod -aG docker $USER
```

## 📚 API Documentation

### Base URL
```
http://localhost:5000
```

### Endpoints

#### General
- `GET /` - API information
- `GET /health` - Health check
- `GET /db-check` - Database connectivity

#### Users
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create user
  ```json
  {"username": "string", "email": "string"}
  ```

#### Products
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create product
  ```json
  {
    "name": "string",
    "description": "string",
    "price": 99.99,
    "stock_quantity": 100
  }
  ```

#### Orders
- `GET /api/orders` - List all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create order
  ```json
  {
    "user_id": 1,
    "items": [
      {"product_id": 1, "quantity": 2}
    ]
  }
  ```

## 🎯 Next Steps

1. ✅ Application is running
2. ✅ Database is initialized
3. ✅ Sample data is loaded
4. 📝 Test the API endpoints
5. 🚀 Deploy to production
6. 📊 Set up monitoring
7. 🔒 Configure SSL/TLS
8. 🔐 Add authentication

## 📞 Support

- Check `README.md` for detailed documentation
- Review `TASK.md` for complete task guide
- View logs: `docker-compose logs -f`
- Check container status: `docker-compose ps`

---

**Ready to go! 🎉**

Your Flask application is now running at: http://localhost:5000
