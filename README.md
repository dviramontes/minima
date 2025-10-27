    ╭─────╮
    │ ● ○ │
    │ ○ ○ │ minima
    ╰─────╯

### A minimal habit tracking CLI written in [Zig](https://ziglang.org/)
#### Part of [Astoria Tech's Project-Project](https://astoria.app/project-project/).

## Usage

### Start tracking a new habit
```bash
min <habit-1> <habit-2> <habit-3>
```

### View all habits
```bash
min list
```

### Remove a habit
```bash
min rm <habit>
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
