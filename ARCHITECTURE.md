# Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                            │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │ Flask App    │  │ Dockerfile   │  │ Docker       │              │
│  │ (Python)     │  │              │  │ Compose      │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │ Database     │  │ GitHub       │  │ Documentation│              │
│  │ Init Script  │  │ Actions      │  │              │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ git push
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        GitHub Actions CI/CD                          │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Job 1: Build & Test                                          │  │
│  │  ├─ Checkout code                                             │  │
│  │  ├─ Set up Python                                             │  │
│  │  ├─ Install dependencies                                      │  │
│  │  ├─ Lint with flake8                                          │  │
│  │  ├─ Build Docker images                                       │  │
│  │  ├─ Start services (docker-compose up)                        │  │
│  │  ├─ Test API endpoints                                        │  │
│  │  └─ Stop services                                             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                │                                      │
│                                ▼                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Job 2: Deploy to Self-Hosted Server                          │  │
│  │  ├─ Setup SSH                                                 │  │
│  │  ├─ Connect to server                                         │  │
│  │  ├─ Pull latest code                                          │  │
│  │  ├─ Create .env file                                          │  │
│  │  ├─ Stop old containers                                       │  │
│  │  ├─ Build & start new containers                              │  │
│  │  └─ Verify deployment                                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                │                                      │
│                                ▼                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Job 3: Cleanup                                                │  │
│  │  ├─ Remove unused images                                      │  │
│  │  ├─ Remove unused volumes                                     │  │
│  │  └─ Remove unused networks                                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ SSH Deploy
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Self-Hosted Server                              │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │              Docker Compose Environment                        │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │  Flask Network (Bridge)                                  │ │ │
│  │  │                                                           │ │ │
│  │  │  ┌──────────────────────┐    ┌──────────────────────┐  │ │ │
│  │  │  │  Flask Container     │    │  PostgreSQL Container│  │ │ │
│  │  │  │  ┌────────────────┐ │    │  ┌────────────────┐ │  │ │ │
│  │  │  │  │ Gunicorn       │ │    │  │ PostgreSQL 15  │ │  │ │ │
│  │  │  │  │ (4 workers)    │ │    │  │                │ │  │ │ │
│  │  │  │  └────────────────┘ │    │  └────────────────┘ │  │ │ │
│  │  │  │  ┌────────────────┐ │    │  ┌────────────────┐ │  │ │ │
│  │  │  │  │ Flask App      │ │◄───┼──│ Database       │ │  │ │ │
│  │  │  │  │ (Python 3.11)  │ │    │  │ (flaskdb)      │ │  │ │ │
│  │  │  │  └────────────────┘ │    │  └────────────────┘ │  │ │ │
│  │  │  │  ┌────────────────┐ │    │  ┌────────────────┐ │  │ │ │
│  │  │  │  │ SQLAlchemy ORM │ │    │  │ init.sql       │ │  │ │ │
│  │  │  │  └────────────────┘ │    │  │ (auto-run)     │ │  │ │ │
│  │  │  │                      │    │  └────────────────┘ │  │ │ │
│  │  │  │  Port: 5000         │    │  Port: 5432         │  │ │ │
│  │  │  │  Health: ✓          │    │  Health: ✓          │  │ │ │
│  │  │  └──────────────────────┘    └──────────────────────┘  │ │ │
│  │  │                                                           │ │ │
│  │  └─────────────────────────────────────────────────────────┘ │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │  Persistent Volumes                                      │ │ │
│  │  │  └─ postgres_data (Database storage)                    │ │ │
│  │  └─────────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ HTTP Requests
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            Clients                                   │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │ Web Browser  │  │ curl/Postman │  │ Mobile App   │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│                                                                       │
│  HTTP Requests to: http://server-ip:5000                            │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
1. Client Request
   │
   ├─► GET /api/users
   │
   ▼
2. Flask App (Gunicorn)
   │
   ├─► Route Handler (routes.py)
   │
   ▼
3. SQLAlchemy ORM (models.py)
   │
   ├─► SQL Query Generation
   │
   ▼
4. PostgreSQL Database
   │
   ├─► Query Execution
   │
   ▼
5. Return Data
   │
   ├─► JSON Serialization
   │
   ▼
6. HTTP Response
   │
   └─► Client receives JSON
```

## Database Initialization Flow

```
1. Docker Compose starts PostgreSQL container
   │
   ▼
2. PostgreSQL initialization
   │
   ├─► Checks /docker-entrypoint-initdb.d/
   │
   ▼
3. Finds init.sql
   │
   ├─► Executes SQL script
   │
   ▼
4. Creates tables
   │
   ├─► users
   ├─► products
   ├─► orders
   └─► order_items
   │
   ▼
5. Creates indexes
   │
   ▼
6. Creates triggers
   │
   ▼
7. Inserts sample data
   │
   └─► Database ready!
```

## Deployment Flow

```
Developer
   │
   ├─► git add .
   ├─► git commit -m "message"
   ├─► git push origin main
   │
   ▼
GitHub Repository
   │
   ├─► Triggers GitHub Actions
   │
   ▼
GitHub Actions Runner
   │
   ├─► Job 1: Build & Test
   │   ├─► Lint code
   │   ├─► Build images
   │   ├─► Run tests
   │   └─► Verify health
   │
   ├─► Job 2: Deploy
   │   ├─► SSH to server
   │   ├─► Pull code
   │   ├─► docker-compose down
   │   ├─► docker-compose up --build
   │   └─► Verify deployment
   │
   └─► Job 3: Cleanup
       └─► Remove old resources
   │
   ▼
Self-Hosted Server
   │
   └─► Application running!
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Docker Host                                                 │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  flask-network (bridge)                              │   │
│  │                                                       │   │
│  │  ┌──────────────┐         ┌──────────────┐         │   │
│  │  │ flask-app    │         │ postgres-db  │         │   │
│  │  │              │         │              │         │   │
│  │  │ IP: auto     │◄───────►│ IP: auto     │         │   │
│  │  │              │         │              │         │   │
│  │  └──────┬───────┘         └──────────────┘         │   │
│  │         │                                           │   │
│  └─────────┼───────────────────────────────────────────┘   │
│            │                                                │
│  ┌─────────▼───────────────────────────────────────────┐   │
│  │  Port Mapping                                        │   │
│  │  ├─ 5000:5000 (Flask)                               │   │
│  │  └─ 5432:5432 (PostgreSQL)                          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
                         │
                         ▼
                   External Access
                   (localhost:5000)
```

## Component Interaction

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │ HTTP Request
       ▼
┌──────────────────────────────────────┐
│   Gunicorn WSGI Server               │
│   ├─ Worker 1                        │
│   ├─ Worker 2                        │
│   ├─ Worker 3                        │
│   └─ Worker 4                        │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│   Flask Application                  │
│   ├─ Routes (routes.py)              │
│   ├─ Models (models.py)              │
│   ├─ Config (config.py)              │
│   └─ App Factory (__init__.py)       │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│   SQLAlchemy ORM                     │
│   ├─ Connection Pool                 │
│   ├─ Query Builder                   │
│   └─ Transaction Management          │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│   PostgreSQL Database                │
│   ├─ Tables                          │
│   ├─ Indexes                         │
│   ├─ Triggers                        │
│   └─ Constraints                     │
└──────────────────────────────────────┘
```

## Security Layers

```
┌─────────────────────────────────────────────────┐
│  Layer 1: Network Isolation                     │
│  └─ Docker bridge network                       │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│  Layer 2: Container Security                    │
│  ├─ Non-root user                               │
│  └─ Minimal base image                          │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│  Layer 3: Application Security                  │
│  ├─ Environment variables                       │
│  ├─ Secret key                                  │
│  └─ Input validation                            │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│  Layer 4: Database Security                     │
│  ├─ Password authentication                     │
│  ├─ Network isolation                           │
│  └─ Parameterized queries (SQLAlchemy)          │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│  Layer 5: CI/CD Security                        │
│  ├─ GitHub Secrets                              │
│  ├─ SSH key authentication                      │
│  └─ Encrypted environment variables             │
└─────────────────────────────────────────────────┘
```

---

**Visual Architecture Guide**  
*Complete system overview with data flow and security layers*
