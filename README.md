    ╭─────╮
    │ ● ○ │  minima
    │ ○ ● │
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

Build from source:
```bash
just min
```

The executable will be available at `zig-out/bin/min`
