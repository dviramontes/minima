const std = @import("std");
const argh = @import("argh");
const tui = @import("tui.zig");
const common = @import("common.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Skip the first argument (program name) to avoid "unexpected positional argument" error
    const argsParser = if (args.len > 0) args[1..] else args;
    var parser = argh.Parser.init(allocator, argsParser);
    try parser.addFlag("--help", "-h", "Show help message");
    try parser.addOption("--task", "-t", "read", "Start tracking a new task");
    try parser.parse();

    // if errors
    if (parser.errors.items.len > 0) {
        parser.printErrors();
    }

    // if --help
    if (parser.flagPresent("--help") or parser.flagPresent("-h")) {
        std.debug.print("{s}\nA minimal habbit tracking CLI\n\n", .{common.logo});
        parser.printHelpWithOptions(.simple_grouped);
        return;
    }

    if (parser.args.len == 0) {
        try tui.main();
    } else {
        // input parsing
        // TODO: move this to inputParsing function
        // const minimabitInputs: type = enum { add, sum, reset };

        // const Input: type = union(minimabitInputs) {
        //     TUI: struct {},
        //     Store: struct {},
        // };

        // create a function that takes the name of a new task
        // get task
        const task = parser.getOption("--task") orelse "SKIP";
        std.debug.print("task::{s}\n", .{task});

        // write task to csv function

        // format
        // ------
        // date,task,completed
        // 2025-10-11,read,1
        // 2025-10-11,exercise,0
        // 2025-10-12,read,1

        // try file.writer().print("{s},{s},{d}\n", .{date, task, completed});
        // dependencies - Only need
        // stdlib: std.fs.File, std.mem.split

    }
}

// let's write a function that can create a CSV of habits, we'll call the file habits.csv

// Example zig code
//
// for (parser.args) |arg| {
//   std.debug.print("arg::{s}\n", .{arg});
// }
