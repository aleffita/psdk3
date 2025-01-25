# PSDK3

Modern PlayStation 3 Homebrew Development Kit. PSDK3 streamlines PS3 homebrew development by providing a containerized environment with all necessary tools pre-configured.

## Features

- Multi-architecture support (x86_64/ARM64)
- Pre-configured toolchain and PSL1GHT SDK
- Multimedia libraries included
- GitHub Actions integration

## Quick Start

### Using Docker

```bash
# Pull the image
docker pull ghcr.io/aleffita/psdk3:latest

# Run interactive shell
docker run -it --rm -v $(pwd):/src ghcr.io/aleffita/psdk3:latest

# Build a project
make
```

### Project Structure

```
/
├── .github/
│   └── workflows/
│       └── docker.yml    # CI pipeline
├── Dockerfile           # Build environment
├── README.md           # Documentation
└── examples/           # Sample projects
```

## Building from Source

```bash
git clone https://github.com/aleffita/psdk3.git
cd psdk3
docker build -t psdk3 .
```

## Next Steps

1. Create examples directory with Hello World template
2. Setup devcontainer configuration
3. Create template generator
4. Add remote debugging tools

## Contributing

Pull requests welcome. Please read CONTRIBUTING.md for guidelines.

## License

[MIT License](LICENSE)