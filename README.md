# DevPod Workspace

This workspace contains three independent repositories that can be developed together:

## Repository Structure

1. **Main Repo** (this directory) - Contains the devcontainer configuration
2. **Backend API** - Located in the `backend` directory, cloned from devpod-odos-backend
3. **Frontend UI** - Located in the `frontend` directory, cloned from devpod-odos-frontend

## Usage

To use this workspace:

1. Open the `devpod.code-workspace` file in VS Code
2. The devcontainer will automatically:
   - Use the main repo configuration
   - Clone the backend and frontend repositories during container creation
   - Set up the development environment

## Configuration

The devcontainer is configured to:
- Automatically clone the backend and frontend repositories via the `postCreateCommand`
- Map ports 3000 and 8089
- Install recommended VS Code extensions

Each repository is an independent git repository, allowing changes to be committed from all three repos.
