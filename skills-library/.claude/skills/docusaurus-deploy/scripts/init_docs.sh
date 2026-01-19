#!/bin/bash

# Docusaurus Deploy - Initialize Documentation Site
# Creates a new Docusaurus site with basic documentation structure

set -euo pipefail

SITE_NAME="${1:-learnflow-docs}"
OUTPUT_DIR="${2:-.}"

echo "Initializing Docusaurus documentation site: $SITE_NAME"

cd "$OUTPUT_DIR"

# Create the Docusaurus site
npx create-docusaurus@latest "$SITE_NAME" classic --typescript

cd "$SITE_NAME"

# Install additional dependencies for enhanced documentation
npm install @docusaurus/module-type-aliases @docusaurus/tsconfig @docusaurus/preset-classic

# Create basic documentation structure
mkdir -p docs/{introduction,tutorials,api-reference,deployment,troubleshooting}

# Create basic documentation files
cat > docs/introduction.md << 'EOF'
---
sidebar_position: 1
---

# Introduction

Welcome to the LearnFlow documentation. This guide will help you understand and use the LearnFlow platform effectively.

## What is LearnFlow?

LearnFlow is an AI-powered learning platform that helps students master programming concepts through personalized instruction and hands-on exercises.

## Key Features

- **Personalized Learning**: AI-powered lessons tailored to your learning style and pace
- **Interactive Coding**: Integrated code editor with real-time feedback
- **Progress Tracking**: Visual tracking of your learning journey
- **Adaptive Challenges**: Exercises that adjust to your skill level

## Getting Started

To get started with LearnFlow, follow the tutorials in the next section.
EOF

cat > docs/tutorials/_category_.json << 'EOF'
{
  "label": "Tutorials",
  "position": 2,
  "link": {
    "type": "generated-index",
    "description": "Step-by-step guides to help you use LearnFlow effectively."
  }
}
EOF

cat > docs/tutorials/getting-started.md << 'EOF'
---
sidebar_position: 1
---

# Getting Started

This tutorial will walk you through setting up and using LearnFlow.

## Prerequisites

- Basic understanding of programming concepts
- A modern web browser
- Internet connection

## Creating an Account

1. Navigate to the LearnFlow platform
2. Click on "Sign Up"
3. Follow the registration process

## Your First Lesson

1. Browse available courses
2. Select a course that matches your skill level
3. Start with the first lesson
4. Complete the exercises at the end of each lesson

That's it! You're now ready to begin your learning journey.
EOF

cat > docs/api-reference/_category_.json << 'EOF'
{
  "label": "API Reference",
  "position": 3,
  "link": {
    "type": "generated-index",
    "description": "Technical documentation for LearnFlow APIs."
  }
}
EOF

cat > docs/api-reference/intro.md << 'EOF'
---
sidebar_position: 1
---

# API Reference

This section contains technical documentation for LearnFlow APIs.

## Base URL

All API endpoints are rooted at `https://api.learnflow.example.com`.

## Authentication

All requests require an API key in the Authorization header:

```
Authorization: Bearer YOUR_API_KEY
```

## Rate Limiting

API requests are limited to 1000 per hour per API key.
EOF

cat > docs/deployment/_category_.json << 'EOF'
{
  "label": "Deployment",
  "position": 4,
  "link": {
    "type": "generated-index",
    "description": "Guides for deploying LearnFlow."
  }
}
EOF

cat > docs/deployment/setup.md << 'EOF'
---
sidebar_position: 1
---

# Deployment Setup

This guide covers deploying LearnFlow to various platforms.

## Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (for production)
- Domain name and SSL certificate

## Environment Variables

Required environment variables:

- `DATABASE_URL`: PostgreSQL connection string
- `NEXTAUTH_SECRET`: Secret for authentication
- `NEXTAUTH_URL`: URL of your deployment
- `OPENAI_API_KEY`: API key for OpenAI services

## Quick Start

For development:

```bash
docker-compose up
```

For production:

```bash
kubectl apply -f deployment.yaml
```
EOF

cat > docs/troubleshooting/_category_.json << 'EOF'
{
  "label": "Troubleshooting",
  "position": 5,
  "link": {
    "type": "generated-index",
    "description": "Common issues and solutions."
  }
}
EOF

cat > docs/troubleshooting/common-issues.md << 'EOF'
---
sidebar_position: 1
---

# Common Issues and Solutions

## Authentication Problems

**Issue**: Cannot log in to the platform
**Solution**: Clear browser cookies and cache, then try again

## Code Editor Not Working

**Issue**: Code editor is not responding
**Solution**: Check browser compatibility and ensure JavaScript is enabled

## API Errors

**Issue**: Receiving 401 Unauthorized errors
**Solution**: Verify your API key is correct and has not expired

## Performance Issues

**Issue**: Slow loading times
**Solution**: Check your internet connection and contact support if the issue persists
EOF

# Update the docusaurus.config.js to include the new documentation
cat > docusaurus.config.js << 'EOF'
// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'LearnFlow Documentation',
  tagline: 'AI-Powered Learning Platform',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://learnflow.example.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'learnflow', // Usually your GitHub org/user name.
  projectName: 'learnflow-docs', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/learnflow/learnflow-docs/tree/main/packages/create-docusaurus/templates/shared/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/learnflow/learnflow-docs/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      navbar: {
        title: 'LearnFlow Docs',
        logo: {
          alt: 'LearnFlow Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Docs',
          },
          {to: '/blog', label: 'Blog', position: 'left'},
          {
            href: 'https://github.com/learnflow/learnflow',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Tutorial',
                to: '/docs/intro',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Stack Overflow',
                href: 'https://stackoverflow.com/questions/tagged/docusaurus',
              },
              {
                label: 'Discord',
                href: 'https://discordapp.com/invite/docusaurus',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/docusaurus',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/facebook/docusaurus',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} LearnFlow, Inc. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
EOF

# Update the sidebar configuration
cat > sidebars.js << 'EOF'
/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Introduction',
      items: ['introduction'],
    },
    {
      type: 'category',
      label: 'Tutorials',
      items: ['tutorials/getting-started'],
    },
    {
      type: 'category',
      label: 'API Reference',
      items: ['api-reference/intro'],
    },
    {
      type: 'category',
      label: 'Deployment',
      items: ['deployment/setup'],
    },
    {
      type: 'category',
      label: 'Troubleshooting',
      items: ['troubleshooting/common-issues'],
    },
  ],
};

module.exports = sidebars;
EOF

echo "✓ Docusaurus site '$SITE_NAME' initialized successfully!"
echo "  - Created basic documentation structure"
echo "  - Added introduction, tutorials, API reference, deployment, and troubleshooting sections"
echo "  - Configured navigation and sidebar"
echo "  - Ready for API documentation generation"