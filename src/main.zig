const std = @import("std");
const habito = @import("habito");
const argh = @import("argh");

pub fn main() !void {
    const logo =
        \\╭─────╮
        \\│ ✓ ○ │ hábito
        \\│ ○ ✓ │ ──────
        \\╰─────╯
    ;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var parser = argh.Parser.init(allocator, args);
    try parser.addFlag("-h", "--help", "Show help message");
    try parser.addFlag("+", "add", "Add task to track");
    try parser.parse();

    if (parser.flagPresent("--help")) {
        std.debug.print("{s}\n", .{logo});
        parser.printHelpWithOptions(.simple_grouped);
        return;
    }
}

// TODO: persist task to SQLite
// fn track(name: c_char) bool {
// std.debug.print("now tracking {s}\n", .{name});
// }
