# Next.js K8s Deploy Reference

## Architecture
The nextjs-k8s-deploy skill creates a scalable Next.js deployment with:
- Next.js application containers
- Reverse proxy/load balancer
- CDN integration for static assets
- Persistent storage for dynamic content

## Deployment Strategy
The skill implements modern deployment practices:
- Multi-stage Docker builds
- Image optimization
- Static asset pre-building
- Server-side rendering configuration
- Client-side hydration setup

## Caching Strategy
The deployment includes multiple caching layers:
- CDN caching for static assets
- Browser caching headers
- API response caching
- Server-side rendering cache
- Image optimization pipeline

## Scaling Configuration
The skill configures appropriate scaling:
- Horizontal pod autoscaling
- Cluster autoscaling triggers
- Resource requests and limits
- Readiness and liveness probes
- Graceful shutdown procedures