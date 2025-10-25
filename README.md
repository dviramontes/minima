    ╭─────╮
    │ ● ○ │
    │ ○ ○ │ minima
    ╰─────╯

### A minimal habit tracking CLI written in [Zig](https://ziglang.org/)
#### Part of [Astoria Tech's Project-Project](https://astoria.app/project-project/).

## Usage

### Start tracking a new minimal
```bash
min add <habit>
```

### Mark habit as complete
```bash
min done <habit>
min + <habit>
```

### View all habits
```bash
min list
```

### View habit statistics
```bash
min stats <habit>
```

### Remove a habit
```bash
min rm <habit>
```

## Examples

```bash
# Start tracking a daily meditation
min add meditation

# Mark today's meditation as complete
min done meditation

# View all tracked habits
min list

# Check your meditation streak
min stats meditation

# Stop tracking a habit
min rm meditation
```

## Installation

### Prerequisites

This project requires Zig 0.15.2. You can use [zvm](https://www.zvm.app/) to manage Zig versions:

```bash
# Install zvm (if not already installed)
# See https://www.zvm.app/guides/install-zvm/

# Install and use Zig 0.15.2
zvm install 0.15.2
zvm use 0.15.2

# Or simply use the .zigversion file
zvm use
```

### Build from source

```bash
zig build
```

The executable will be available at `zig-out/bin/min`
