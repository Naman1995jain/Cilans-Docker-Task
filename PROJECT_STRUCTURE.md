# Project Structure

```
Test/
│
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions CI/CD workflow
│
├── app/
│   ├── __init__.py                 # Flask app factory
│   ├── config.py                   # Configuration management
│   ├── models.py                   # Database models (User, Product, Order, OrderItem)
│   └── routes.py                   # API routes and endpoints
│
├── db/
│   └── init.sql                    # PostgreSQL initialization script
│
├── .dockerignore                   # Docker build exclusions
├── .env                            # Environment variables (local)
├── .env.example                    # Environment template
├── .gitignore                      # Git exclusions
├── Dockerfile                      # Flask app container definition
├── docker-compose.yml              # Multi-container orchestration
├── requirements.txt                # Python dependencies
├── run.py                          # Application entry point
│
├── deploy.sh                       # Deployment helper script (Linux/Mac)
├── test_api.sh                     # API testing script (Linux/Mac)
├── test_api.ps1                    # API testing script (Windows)
│
├── QUICKSTART.md                   # Quick start guide
├── README.md                       # Main documentation
├── TASK.md                         # Complete task documentation
└── PROJECT_STRUCTURE.md            # This file
```

## File Descriptions

### Application Files

#### `app/__init__.py`
- Flask application factory
- SQLAlchemy initialization
- Blueprint registration

#### `app/config.py`
- Environment-based configuration
- Database connection settings
- Development, production, and testing configs

#### `app/models.py`
- SQLAlchemy ORM models:
  - User (id, username, email)
  - Product (id, name, description, price, stock_quantity)
  - Order (id, user_id, total_amount, status)
  - OrderItem (id, order_id, product_id, quantity, price)

#### `app/routes.py`
- REST API endpoints:
  - General: /, /health, /db-check
  - Users: GET/POST /api/users
  - Products: GET/POST /api/products
  - Orders: GET/POST /api/orders

#### `run.py`
- Application entry point
- Runs Flask development server

### Database Files

#### `db/init.sql`
- PostgreSQL initialization script
- Creates tables with proper schema
- Adds indexes for performance
- Inserts sample data
- Creates triggers for updated_at timestamps
- Runs automatically via docker-entrypoint-initdb.d

### Docker Files

#### `Dockerfile`
- Multi-stage build for Flask app
- Based on Python 3.11-slim
- Installs system dependencies
- Creates non-root user for security
- Configures Gunicorn WSGI server
- Includes health checks

#### `docker-compose.yml`
- Orchestrates Flask and PostgreSQL services
- Defines custom network (flask-network)
- Configures volumes for data persistence
- Sets up health checks
- Manages service dependencies

#### `.dockerignore`
- Excludes unnecessary files from Docker build
- Reduces image size
- Improves build speed

### Configuration Files

#### `.env`
- Local environment variables
- Database credentials
- Flask configuration
- **NOT committed to git**

#### `.env.example`
- Template for environment variables
- Safe to commit to git
- Copy to .env for local use

#### `requirements.txt`
- Python dependencies:
  - Flask 3.0.0
  - psycopg2-binary 2.9.9
  - python-dotenv 1.0.0
  - SQLAlchemy 2.0.23
  - Flask-SQLAlchemy 3.1.1
  - gunicorn 21.2.0

### CI/CD Files

#### `.github/workflows/deploy.yml`
- GitHub Actions workflow
- Jobs:
  1. build-and-test: Build, test, and verify
  2. deploy: Deploy to self-hosted server
  3. cleanup: Clean up old Docker resources
- Triggers on push to main/master branch

### Testing & Deployment Scripts

#### `test_api.sh` (Linux/Mac)
- Bash script for API testing
- Tests all endpoints
- Colored output
- Error handling

#### `test_api.ps1` (Windows)
- PowerShell script for API testing
- Tests all endpoints
- Colored output
- Error handling

#### `deploy.sh` (Linux/Mac)
- Deployment helper script
- Checks Docker installation
- Sets up repository
- Creates .env file
- Deploys application
- Verifies deployment

### Documentation Files

#### `QUICKSTART.md`
- Quick start guide
- Essential commands
- Common troubleshooting
- API examples

#### `README.md`
- Main project documentation
- Setup instructions
- API documentation
- Deployment guide
- Troubleshooting

#### `TASK.md`
- Complete task documentation
- Architecture overview
- Detailed setup instructions
- Production deployment checklist
- Security best practices

## Key Features

### 🐳 Docker Containerization
- **Flask Container**: Python 3.11, Gunicorn, health checks
- **PostgreSQL Container**: PostgreSQL 15, persistent volumes, init scripts
- **Network**: Custom bridge network for inter-service communication

### 🗄️ Database
- **Automatic Initialization**: Schema created on first run
- **Sample Data**: Pre-populated with test users and products
- **Relationships**: Foreign keys and cascading deletes
- **Triggers**: Automatic timestamp updates
- **Indexes**: Optimized for common queries

### 🚀 CI/CD Pipeline
- **Automated Testing**: Runs on every push
- **Build Verification**: Docker images built and tested
- **Deployment**: Automatic deployment to self-hosted server
- **Health Checks**: Verifies deployment success
- **Cleanup**: Removes old Docker resources

### 🔒 Security
- **Non-root User**: Flask runs as non-root user
- **Environment Variables**: Sensitive data in .env
- **GitHub Secrets**: CI/CD credentials secured
- **Network Isolation**: Docker network isolation
- **Password Authentication**: PostgreSQL password protection

### 📊 Monitoring
- **Health Endpoints**: /health and /db-check
- **Docker Health Checks**: Container-level monitoring
- **Logging**: Comprehensive application and database logs
- **Container Stats**: Resource usage monitoring

## Getting Started

1. **Clone repository**
2. **Copy .env.example to .env**
3. **Run `docker-compose up --build`**
4. **Access http://localhost:5000**
5. **Test with `test_api.ps1` (Windows) or `test_api.sh` (Linux/Mac)**

## Deployment Flow

```
Developer → Git Push → GitHub Actions → Build & Test → Deploy to Server → Health Check → Success
```

## Technology Stack

- **Backend**: Flask 3.0.0
- **Database**: PostgreSQL 15
- **ORM**: SQLAlchemy 2.0.23
- **WSGI Server**: Gunicorn 21.2.0
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions
- **Language**: Python 3.11

---

**Last Updated**: 2025-12-18
