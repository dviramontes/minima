# Build configuration
default_mode := "Debug"

# Default target
default: build

# Build the project
build mode=default_mode:
    zig build -Doptimize={{mode}}

# Build and rename executable to 'hab'
hab mode=default_mode:
    zig build -Doptimize={{mode}}
    @echo "Built: zig-out/bin/hab"

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

# Build and install hab directly
install: hab
    @echo "Executable available at: zig-out/bin/hab"

# format
fmt:
    zig fmt .