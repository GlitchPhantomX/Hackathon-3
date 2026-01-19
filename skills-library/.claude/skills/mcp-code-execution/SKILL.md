---
name: mcp-code-execution
description: Convert MCP servers to code execution pattern for token efficiency
---

# MCP Code Execution Pattern

## When to Use
Use this skill to optimize context windows by wrapping external APIs/MCP servers in code execution pattern.

## Instructions
1. Choose an example from `examples/` directory
2. Customize the script for your specific MCP server
3. Deploy the wrapped service

## Validation Checklist
- [ ] Direct MCP loads 50k+ tokens
- [ ] Code execution uses ~100 tokens + script
- [ ] 80-98% token reduction achieved
- [ ] Functionality preserved

For implementation details, see REFERENCE.md.