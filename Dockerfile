# Build stage
FROM python:3.9-alpine as builder
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev libpq postgresql-dev mariadb-connector-c-dev

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.9-alpine
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache libpq mariadb-connector-c

COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production

# Uncomment for PostgreSQL support
# ENV DATABASE_URL=postgresql://user:pass@db:5432/dbname

# Uncomment for MySQL support
# ENV DATABASE_URL=mysql://user:pass@mysql:3306/dbname

EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "app:app"]