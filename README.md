    ╭─────╮
    │ ✓ ○ │  hábito
    │ ○ ✓ │
    ╰─────╯

A habit tracker CLI written in [Zig]
Part of [Astoria Tech's Project-Project](https://astoria.app/project-project/)

## Usage

### Start tracking a new habit
```bash
hab add <HABIT>
```

### Mark habit as complete
```bash
hab done <HABIT>
hab + <HABIT>
```

### View all habits
```bash
hab list
```

### View habit statistics
```bash
hab stats <HABIT>
```

### Remove a habit
```bash
hab rm <HABIT>
```

## Examples

```bash
# Start tracking a daily meditation habit
hab add meditation

# Mark today's meditation as complete
hab done meditation

# View all tracked habits
hab list

# Check your meditation streak
hab stats meditation

# Stop tracking a habit
hab rm meditation
```

## Installation

Build from source:
```bash
just hab
```

The executable will be available at `zig-out/bin/hab`
