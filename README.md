    ╭─────╮
    │ ● ○ │  minima
    │ ○ ● │
    ╰─────╯

A minimal tracker CLI written in [Zig]
Part of [Astoria Tech's Project-Project](https://astoria.app/project-project/)

## Usage

### Start tracking a new minimal
```bash
minima add <habit>
```

### Mark habit as complete
```bash
minima done <habit>
minima + <habit>
```

### View all habits
```bash
minima list
```

### View habit statistics
```bash
minima stats <habit>
```

### Remove a habit
```bash
minima rm <habit>
```

## Examples

```bash
# Start tracking a daily meditation
minima add meditation

# Mark today's meditation as complete
minima done meditation

# View all tracked habits
minima list

# Check your meditation streak
minima stats meditation

# Stop tracking a habit
minima rm meditation
```

## Installation

Build from source:
```bash
just minima
```

The executable will be available at `zig-out/bin/minima`
