# ACADEXA Documentation

![ACADEXA Logo](assets/images/Acadexa_Logo.png "ACADEXA Logo")

## 🎓 ACADEXA — Offline Academic Expert System

An intelligent, flutter application for academic management system with a built-in rule-based inference engine for higher education institutions.

![Flutter badge](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![FastAPI badge](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white) ![Supabase badge](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white) ![Python badge](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) ![PostgreSQL badge](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white) ![Redis badge](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)

---

## 📌 Project Overview

**ACADEXA** is more than just a student information system. It is an **intelligent academic advisor** designed to help universities move beyond simple data storage.

The system combines traditional academic management (students, courses, transcripts) with an **Expert System (ES)** engine that mimics human expert reasoning. It can validate prerequisites, detect academic risks, check graduation eligibility, and provide actionable recommendations.

> 🎯 **Core Philosophy:** Instead of just answering "What is the student's GPA?", ACADEXA answers "Why is the student at risk?" and "What should they do next?"

---

## 🧠 System Architecture: How It Thinks

The system is built on a clean, layered architecture that separates concerns and allows each component to scale independently.

```mermaid
graph TD
   A[📱 Flutter Frontend] -->|HTTP / REST| B(⚙️ FastAPI Gateway)
   B --> C{🔐 Auth & Permissions}
   C --> D[🧠 Expert System Engine]
   C --> E[📊 Business Logic Layer]
   D --> F[🗃️ PostgreSQL/Supabase]
   E --> F
   E --> G[📂 Supabase Storage]
   D --> H[⚡ Redis Cache]
   B --> I[📨 Background Jobs (Celery/APScheduler)]
```

### 🧩 Component Breakdown

1. **Presentation Layer (Flutter):** Zero business logic. Only renders UI and handles user input.
2. **API Gateway (FastAPI):** Validates requests, routes traffic, and enforces authentication using Supabase Auth.
3. **Expert System Engine (Python):** The brain of the operation. Applies forward-chaining inference over a set of academic rules.
4. **Service & Repository Layer:** Translates between the expert system's decisions and database operations.
5. **Data Layer (Supabase):** PostgreSQL for relational data, Storage for PDF/Excel files, and Auth for user management.

---

## 🛠️ Full Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Cross-platform UI (Android, iOS, Web, Desktop) |
| **State Management** | Riverpod / Bloc | Reactive state handling |
| **Backend** | Python 3.11+ / FastAPI | High-performance async REST API |
| **Database ORM** | SQLAlchemy (Async) | Async database operations |
| **Database** | PostgreSQL (via Supabase) | Primary relational data store |
| **Auth** | Supabase Auth | JWT-based user authentication |
| **Cache** | Redis | Session caching & rate limiting |
| **Expert System** | Custom Rule Engine (Forward Chaining) | Academic inference logic |
| **Task Queue** | Celery + Redis | Background transcript processing |
| **Parsing** | Pandas, OpenPyXL, PyPDF2 | Excel & PDF data extraction |

---

## 📁 Project Structure (Detailed)

```text
ACADEXA/
├── frontend/                     # Flutter application
│   ├── lib/
│   │   ├── core/                 # Themes, constants, routing, network client
│   │   ├── features/             # Feature-based modules (auth, students, courses)
│   │   │   ├── auth/             # Login/Register screens & logic
│   │   │   ├── dashboard/        # Analytics & KPI widgets
│   │   │   ├── expert/           # Expert system recommendations UI
│   │   │   └── transcripts/      # Upload & view transcripts
│   │   ├── services/             # API service classes (Dio + Retrofit)
│   │   └── shared/               # Reusable widgets & utilities
│   └── pubspec.yaml
│
├── backend/                      # FastAPI application
│   ├── api/                      # Route handlers (routers)
│   │   ├── v1/
│   │   │   ├── auth.py
│   │   │   ├── students.py
│   │   │   ├── expert.py         # Endpoint: /api/v1/expert/analyze
│   │   │   └── transcripts.py
│   ├── core/                     # Config, security, dependencies
│   ├── domain/                   # Pydantic & SQLAlchemy models (Entities)
│   ├── repositories/             # Database CRUD abstraction
│   ├── services/                 # Business logic (GPA calculator, validators)
│   ├── expert_system/            # 🧠 The Expert System Core
│   │   ├── engine.py             # Inference engine (forward chaining)
│   │   ├── rules.py              # Base rule class & rule factory
│   │   ├── knowledge_base.py     # Academic facts loader
│   │   └── inference.py          # Conflict resolution & agenda
│   ├── parsers/                  # File parsers (Excel, PDF transcripts)
│   ├── schemas/                  # Pydantic request/response models
│   └── main.py
│
└── docker-compose.yml            # Supabase, Redis, & backend local setup
```

---

## 🧠 Expert System Deep Dive

The core of ACADEXA is a **rule-based expert system** that uses **forward chaining** to derive new conclusions from known facts.

### 🔧 How the Inference Engine Works

1. **Fact Base:** Loads student data (e.g., `GPA=1.8`, `completed_courses=[MATH101, CS201]`, `current_semester=6`).
2. **Rule Base:** Contains 15-20 predefined IF-THEN rules covering academic logic.
3. **Agenda:** The engine matches facts against rule conditions (RETE-like matching).
4. **Conflict Resolution:** If multiple rules fire, the engine prioritizes by severity (e.g., "WARNING" > "INFO").
5. **Action:** Executes the rule's consequence (e.g., add `status=ACADEMIC_PROBATION`, generate recommendation).

### 📜 Example Academic Rules

```python
# Rule 1: Academic Probation
IF student.gpa < 2.0 
  AND student.current_semester >= 2 
  AND NOT student.on_probation
THEN 
  ADD student.status = "ACADEMIC_PROBATION"
  ADD recommendation = "You are on academic probation. Limit courses to 12 credits."

# Rule 2: Prerequisite Validation
IF course.registration_requested = "CS301"
  AND "CS201" NOT IN student.completed_courses
THEN 
  BLOCK registration
  ADD error_message = "Missing prerequisite: CS201 (Data Structures)"

# Rule 3: Graduation Eligibility (Simple)
IF student.credits_earned >= 120
  AND student.gpa >= 2.0
  AND student.capstone_completed = True
THEN 
  ADD student.eligibility = "ELIGIBLE_FOR_GRADUATION"
  ADD recommendation = "Apply for graduation by October 15th."
```

---

## 🚀 Core Features (Mapped to Use Cases)

| Feature Area | Specific Capability | Powered By |
| :--- | :--- | :--- |
| **📝 Academic Records** | CRUD for students, courses, instructors, departments. | PostgreSQL + FastAPI |
| **📄 Transcript Processing** | Upload PDF/Excel → Auto-parse grades → Calculate GPA. | Pandas + PyPDF2 |
| **✅ Prerequisite Checker** | Prevent registration if missing required courses. | Expert System (Rule #2) |
| **⚠️ Risk Detection** | Flag students with low GPA, excessive absences, or course overload. | Expert System (Rule #1) |
| **🎓 Graduation Audit** | Compare completed credits against study plan. | Service Layer + Expert System |
| **📊 Academic Analytics** | Visualize GPA trends, pass rates, and semester loads. | Flutter Charts + Aggregated APIs |
| **🔐 Role-Based Access** | Admin, Faculty, Student roles with different permissions. | Supabase Auth + Row Level Security |
| **📂 Bulk Import** | Upload entire curriculum (200+ courses) via Excel. | OpenPyXL + Data Validation |

---

## ⚙️ Setup & Installation (Step-by-Step)

### Prerequisites

- Python 3.11+
- Flutter 3.16+
- Docker & Docker Compose (for local Supabase/Redis)

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/hoda-elkassas/acadexa_platform.git
cd acadexa_platform
```

### 2️⃣ Backend Setup (FastAPI)

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Create .env file (see template below)
cp .env.example .env

# Run database migrations (Alembic)
alembic upgrade head

# Start the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 3️⃣ Frontend Setup (Flutter)

```bash
cd ../frontend
flutter pub get
flutter run -d chrome  # For web, or use an emulator
```

### 4️⃣ Run Supabase & Redis Locally (Optional)

```bash
cd ../docker
docker-compose up -d
```

---

## 🔐 Environment Variables (`.env` Template)

Create a `.env` file in the `backend/` directory:

```ini
# Supabase (Production or Local)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (anon/public key)
DATABASE_URL=postgresql://postgres:password@localhost:5432/postgres

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-strong-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# File Upload
MAX_UPLOAD_SIZE=10485760  # 10MB
ALLOWED_EXTENSIONS=.pdf,.xlsx,.xls
```

---

## 📡 API Endpoints Reference

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/register` | Create new user (student/staff) | No |
| `POST` | `/api/v1/auth/login` | Login → returns JWT token | No |
| `GET` | `/api/v1/students/{id}` | Get student profile | Yes (Admin or Self) |
| `POST` | `/api/v1/transcripts/upload` | Upload PDF transcript file | Yes (Student/Admin) |
| `GET` | `/api/v1/transcripts/{student_id}` | Retrieve parsed transcript & GPA | Yes |
| `POST` | `/api/v1/expert/analyze` | Run expert system on a student | Yes |
| `GET` | `/api/v1/expert/recommendations/{student_id}` | Get cached recommendations | Yes |
| `GET` | `/api/v1/courses/check-prerequisite` | Validate course prerequisites | Yes |

### 🧪 Try the Expert System API

```bash
curl -X POST "http://localhost:8000/api/v1/expert/analyze" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"student_id": "123e4567-e89b-12d3-a456-426614174000"}'
```

**Response:**

```json
{
  "status": "AT_RISK",
  "gpa": 1.7,
  "warnings": ["Academic Probation", "Missing prerequisite for CS301"],
  "recommendations": [
   "Limit enrollment to 12 credits this semester.",
   "Attend tutoring for CS201 before attempting CS301."
  ],
  "graduation_eligible": false
}
```

---

## 🧪 Testing Strategy

```bash
# Run backend unit tests
cd backend
pytest tests/unit -v

# Run integration tests (requires Docker)
pytest tests/integration -v

# Run Flutter widget tests
cd ../frontend
flutter test
```

---

## 🗺️ Roadmap & Future Enhancements

| Phase | Feature | Status |
| :--- | :--- | :--- |
| ✅ Phase 1 | Core CRUD + Supabase Auth | Completed |
| ✅ Phase 2 | Expert System (15 rules) | Completed |
| 🔄 Phase 3 | LLM Integration (GPT-based natural language advising) | In Progress |
| 🔄 Phase 4 | Real-time notifications (FCM + Email) | In Progress |
| 📅 Phase 5 | Predictive analytics (Dropout risk using historical data) | Planned |
| 📅 Phase 6 | Multi-university tenancy support | Planned |

---

## 👩‍💻 Author

**Hoda Lotfy Elkassas**  
🎓 Computer Teacher Program — Faculty of Specific Education  
📊 Passionate about Data Analysis, AI Systems, and Full-stack Development  

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- Supabase for the incredible open-source Firebase alternative.
- FastAPI for the blazing-fast async framework.
- Flutter community for the amazing cross-platform tools.

### Made with ❤️ for smarter academic institutions
