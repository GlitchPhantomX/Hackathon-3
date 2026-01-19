# Skill Development Guide

## Introduction

This guide provides instructions for developing and maintaining skills in the Skills Library. Each skill should follow consistent patterns for documentation, implementation, and testing.

## Skill Structure

Every skill should include the following components:

- `SKILL.md`: Describes what the skill does, its capabilities, input parameters, and output
- `REFERENCE.md`: Provides technical details about the skill's architecture and implementation
- `scripts/`: Contains any executable scripts or code that implements the skill

## Creating New Skills

When creating a new skill, follow these steps:

1. Choose a descriptive name for your skill that indicates its purpose
2. Create a folder under `.claude/skills/{skill-name}/`
3. Add the required documentation files (`SKILL.md` and `REFERENCE.md`)
4. Include any necessary scripts or code in the `scripts/` folder
5. Test the skill thoroughly before committing

## Documentation Standards

### SKILL.md Content

The `SKILL.md` file should contain:

- Clear description of the skill's purpose
- List of capabilities and features
- Input parameters with descriptions
- Expected output or results

### REFERENCE.md Content

The `REFERENCE.md` file should contain:

- Technical architecture details
- Component descriptions
- Configuration options
- Integration points

## Best Practices

- Keep skills focused on a single, well-defined purpose
- Ensure skills are reusable across different contexts
- Document any dependencies or prerequisites
- Include examples of usage when possible
- Follow consistent naming conventions