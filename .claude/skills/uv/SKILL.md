---
description: Quick reference for uv package manager commands. Covers package management, testing with pytest, linting/formatting with ruff, and building.
user-invocable: false
---

## Development Commands

### Package Management
This project uses **uv** as the package manager:
- `uv sync` - Install/update dependencies and sync the environment
- `uv add <package>` - Add a new dependency
- `uv add --dev <package>` - Add a dev only dependency
- `uv remove <package>` - Remove a dependency
- `uv remove --dev <package>` - Remove a dev only dependency
- `uv run <command>` - Run commands in the project environment

### Testing
- `uv run pytest` - Run all tests
- `uv run pytest tests/test_blah.py` - Run specific test file
- `uv run pytest -v` - Run tests with verbose output

### Linting & Formatting
- `uv run ruff check` - Check code style and quality
- `uv run ruff format` - Format code automatically
- `uv run ruff check --fix` - Fix auto-fixable issues

### Building
- `uv build` - Build source distribution and wheel packages
