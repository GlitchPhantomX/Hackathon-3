---
name: nextjs-k8s-deploy
description: Deploy Next.js app with Monaco editor on Kubernetes
---

# NextJS K8s Deploy

## When to Use
Use this skill to create LearnFlow frontend with Monaco editor.

## Instructions
1. Run `generate_nextjs_app.sh` to create Next.js project
2. Run `add_monaco.sh` to integrate Monaco code editor
3. Run `dockerize.sh` to create Dockerfile and build
4. Run `deploy.sh` to deploy to K8s

## Validation Checklist
- [ ] Frontend is accessible
- [ ] Monaco editor is working
- [ ] API routes connect to backend
- [ ] Authentication works

For implementation details, see REFERENCE.md.