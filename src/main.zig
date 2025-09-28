const std = @import("std");
const habito = @import("habito");

pub fn main() !void {
    const logo = 
    \\╭─────╮
    \\│ ✓ ○ │  hábito
    \\│ ○ ✓ │
    \\╰─────╯
    ;
    std.debug.print("{s}\n", .{logo});

    
    const subcommand = "track";
    // TODO: how do i comsume positional args in zig?
    const args = try std.process.argsAlloc(s);
    if (args.len < 2) {
        
    }
}

// TODO: persist task to SQLite
// fn track(name: c_char) bool {
    // std.debug.print("now tracking {s}\n", .{name});
// }
