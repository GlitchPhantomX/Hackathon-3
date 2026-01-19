import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      items: ['getting-started/installation', 'getting-started/configuration'],
    },
    {
      type: 'category',
      label: 'Architecture',
      items: ['architecture/overview', 'architecture/frontend', 'architecture/backend', 'architecture/triage-agent', 'architecture/concepts-agent'],
    },
    {
      type: 'category',
      label: 'API Reference',
      items: ['api-reference/frontend-api', 'api-reference/backend-api', 'api-reference/triage-api', 'api-reference/concepts-api'],
    },
    {
      type: 'category',
      label: 'Skills and Agents',
      items: ['skills-and-agents/overview', 'skills-and-agents/frontend-skills', 'skills-and-agents/backend-skills', 'skills-and-agents/triage-agent', 'skills-and-agents/concepts-agent'],
    },
    {
      type: 'category',
      label: 'Deployment',
      items: ['deployment/k8s-overview', 'deployment/frontend', 'deployment/backend', 'deployment/triage', 'deployment/concepts', 'deployment/monitoring'],
    },
    {
      type: 'category',
      label: 'MCP Servers',
      items: ['mcp/overview', 'mcp/context-server', 'mcp/integration'],
    },
  ],
};

export default sidebars;
