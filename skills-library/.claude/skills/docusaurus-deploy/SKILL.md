---
name: docusaurus-deploy
description: Generate and deploy comprehensive documentation site
---

# Docusaurus Deploy

## When to Use
Use this skill to create project documentation, API references, and guides.

## Instructions
1. Run `init_docs.sh` to create Docusaurus site
2. Run `generate_api_docs.py` to auto-generate API documentation
3. Run `build_deploy.sh` to build and deploy to K8s

## Validation Checklist
- [ ] Docs site is accessible
- [ ] Search is working
- [ ] API docs are generated
- [ ] Navigation is functional

For implementation details, see REFERENCE.md.