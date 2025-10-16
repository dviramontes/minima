# Build configuration
default_mode := "Debug"

# Default target
default: build

# Build the project
build mode=default_mode:
    zig build -Doptimize={{mode}}

# Build and rename executable to 'min'
minima mode=default_mode:
    zig build -Doptimize={{mode}}
    @echo "Built: zig-out/bin/min"

# Run the application
run *args:
    zig build run -- {{args}}

# Run tests
test:
    zig build test

# Clean build artifacts
clean:
    rm -rf zig-out .zig-cache

# Build release version
release:
    zig build -Doptimize=ReleaseFast

# Build for size optimization
small:
    zig build -Doptimize=ReleaseSmall

# Build safe release version
safe:
    zig build -Doptimize=ReleaseSafe

# Build and install minima directly
install: minima
    @echo "Executable available at: zig-out/bin/min"

# format
fmt:
    zig fmt .

# validate CSV files
validate:
    python3 -c "import csv; list(csv.reader(open('habits.csv')))" && echo "Valid CSV"
