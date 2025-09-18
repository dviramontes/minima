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
}
