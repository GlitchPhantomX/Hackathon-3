# LearnFlow Frontend

Interactive Python learning platform frontend built with Next.js.

## Features

- Student dashboard with progress tracking
- Teacher dashboard with class management
- Python code editor with Monaco Editor
- AI-powered tutoring system
- Real-time chat interface
- Quiz system for assessment

## Development

1. Install dependencies:
```bash
npm install
```

2. Run the development server:
```bash
npm run dev
```

3. Open [http://localhost:3000](http://localhost:3000) to view the application.

## Environment Variables

Create a `.env.local` file in the root directory with the following variables:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_BETTER_AUTH_URL=http://localhost:8080
```

## Building for Production

```bash
npm run build
```

## Deployment to Kubernetes

### Prerequisites
- Docker
- Kubernetes cluster
- kubectl configured

### Steps

1. Build the Docker image:
```bash
docker build -t learnflow-frontend:latest .
```

2. If using a remote registry, tag and push the image:
```bash
docker tag learnflow-frontend:latest your-registry/learnflow-frontend:latest
docker push your-registry/learnflow-frontend:latest
```

3. Update the image name in `k8s-deployment.yaml` if using a remote registry

4. Deploy to Kubernetes:
```bash
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-hpa-configmap.yaml
```

### Using the deployment script

Alternatively, you can use the provided deployment script:

```bash
chmod +x deploy.sh
./deploy.sh
```

## Architecture

The frontend communicates with:
- FastAPI backend for business logic
- Better Auth for authentication
- WebSocket server for real-time features
- Database through the backend API

## Services

- `learnflow-frontend`: Main frontend service
- `learnflow-frontend-service`: Kubernetes service exposing the frontend
- `learnflow-frontend-ingress`: Ingress for external access

## Scaling

The deployment includes a Horizontal Pod Autoscaler that scales based on CPU and memory usage.
