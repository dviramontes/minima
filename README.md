    ╭─────╮
    │ ✓ ○ │  hábito
    │ ○ ✓ │
    ╰─────╯

A habit tracker CLI written in [Zig]
Part of [Astoria Tech's Project-Project](https://astoria.app/project-project/)

## Usage

### Track a new habit
```bash
hab track <HABIT>
```

### Mark habit as complete
```bash
hab done <HABIT>
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
hab remove <HABIT>
```

## Examples

```bash
# Start tracking a daily meditation habit
hab track meditation

# Mark today's meditation as complete
hab done meditation

# View all tracked habits
hab list

# Check your meditation streak
hab stats meditation

# Stop tracking a habit
hab remove meditation
```

## Installation

Build from source:
```bash
just hab
```

The executable will be available at `zig-out/bin/hab`
