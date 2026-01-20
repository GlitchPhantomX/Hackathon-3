# LearnFlow PostgreSQL Setup

This document describes the PostgreSQL setup for the LearnFlow application, including deployment, configuration, and usage instructions.

## 🚀 Quick Start

### Deploy PostgreSQL
```bash
# Add Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create namespace
kubectl create namespace postgres

# Install PostgreSQL with custom values
helm install postgresql bitnami/postgresql \
  --namespace postgres \
  --values values.yaml \
  --wait --timeout 10m
```

### Verify Deployment
```bash
# Run verification script
./verify-postgres.sh
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Applications  │    │   PostgreSQL     │    │   Persistent    │
│                 │◄──►│   (Database)     │◄──►│   Storage       │
│ (Services)      │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

PostgreSQL serves as the primary database for LearnFlow, storing all application data including user information, curriculum content, exercises, submissions, and progress tracking.

## 📚 Database Schema

LearnFlow uses 9 distinct tables for different purposes:

| Table Name | Purpose |
|------------|---------|
| `users` | Authentication and user accounts |
| `students` | Student profiles and information |
| `teachers` | Teacher profiles and information |
| `topics` | Curriculum topics and content (24 Python topics) |
| `exercises` | Exercise definitions and content |
| `submissions` | Student exercise submissions |
| `progress` | Mastery tracking and progress |
| `chat_history` | Conversation history with AI |
| `struggle_alerts` | Student struggle detection alerts |

## 🔐 Connection Information

### For Applications
```bash
# PostgreSQL Connection Details
Host: postgresql.postgres.svc.cluster.local:5432
Database: learnflow_db
Username: learnflow
Password: learnflow_dev_pass
```

### From Outside the Cluster
```bash
# Port forward to access locally
kubectl port-forward -n postgres svc/postgresql 5432:5432
```

## 🧪 Testing

### Connect to Database
```bash
# Example: Connect to PostgreSQL
kubectl exec -it -n postgres <postgres-pod-name> -- psql -U learnflow -d learnflow_db
```

### Query Sample Data
```sql
-- Example: Check users table
SELECT * FROM users LIMIT 5;

-- Example: Check topics count
SELECT COUNT(*) FROM topics;

-- Example: Check student progress
SELECT s.first_name, s.last_name, p.mastery_level
FROM students s
JOIN progress p ON s.id = p.student_id
LIMIT 5;
```

## 🛠️ Troubleshooting

### Common Issues

1. **PostgreSQL pods stuck in Pending state**
   - Check if there are enough nodes and resources available
   - Verify PersistentVolume availability
   - Check storage class configuration

2. **Connection timeouts**
   - Verify service is accessible within the cluster
   - Check network policies if enabled
   - Ensure DNS resolution works: `nslookup postgresql.postgres.svc.cluster.local`

3. **Database initialization issues**
   - Check PostgreSQL logs: `kubectl logs -n postgres <postgres-pod>`
   - Verify init scripts are properly configured
   - Check permissions for init scripts

### Useful Commands

```bash
# Check PostgreSQL pod status
kubectl get pods -n postgres -l app.kubernetes.io/name=postgresql

# Check PostgreSQL service
kubectl get svc -n postgres -l app.kubernetes.io/name=postgresql

# View PostgreSQL logs
kubectl logs -n postgres -l app.kubernetes.io/name=postgresql

# Connect to PostgreSQL directly
kubectl exec -n postgres <postgres-pod> -- psql -U learnflow -d learnflow_db -c "\dt"

# Check database size
kubectl exec -n postgres <postgres-pod> -- psql -U learnflow -d learnflow_db -c "SELECT pg_size_pretty(pg_database_size('learnflow_db'));"
```

## 📋 Maintenance

### Backup and Restore
Regular database backups should be scheduled using PostgreSQL's built-in tools or external backup solutions.

### Monitoring
Monitor database performance, connection pools, and storage utilization:
```bash
# Check active connections
kubectl exec -n postgres <postgres-pod> -- psql -U learnflow -d learnflow_db -c "SELECT count(*) FROM pg_stat_activity;"

# Check table sizes
kubectl exec -n postgres <postgres-pod> -- psql -U learnflow -d learnflow_db -c "SELECT schemaname, tablename, pg_size_pretty(table_len) FROM (SELECT schemaname, tablename, pg_total_relation_size(schemaname||'.'||tablename) AS table_len FROM pg_tables WHERE schemaname='public') t ORDER BY table_len DESC;"
```