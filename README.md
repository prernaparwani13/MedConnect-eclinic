Hospital-System
===============

Simple Java webapp (WAR) for a hospital system demo.

Prerequisites
- Java 17+ installed
- Maven installed
- MySQL running with a database `medconnect_db` and a `users` table

Setup
1. Edit `src/main/resources/config.properties` and set `db.url`, `db.user`, `db.password` appropriately.
2. Build:

```bash
mvn clean package -DskipTests
```

3. Run with embedded Tomcat plugin:

```bash
mvn tomcat7:run
```

Access
- Open: http://localhost:8080/

Default Credentials
-------------------

The application is pre-seeded with default user accounts for different roles:

| Role | Email ID | Password |
| :--- | :--- | :--- |
| **Admin** | `admin@medconnect.com` | `admin123` |
| **Doctor** | `doctor@medconnect.com` | `doctor123` |
| **Receptionist** | `receptionist@medconnect.com` | `recep123` |
| **Patient** | `patient@medconnect.com` | `patient123` |

Notes
- The app reads DB settings from `config.properties`.
- Passwords are stored in plaintext in this demo; replace with hashing for production.
- If you change servlets or mappings, ensure `WEB-INF/web.xml` has `metadata-complete="false"` to allow annotation scanning.

