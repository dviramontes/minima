const std = @import("std");
const argh = @import("argh");
const tui = @import("tui.zig");
const common = @import("common.zig");
const model = @import("model.zig");

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
        std.debug.print("{s}\nA minimal habit tracking CLI\n\n", .{common.logo});
        parser.printHelpWithOptions(.simple_grouped);
        return;
    }

    if (parser.args.len == 0) {
        // TODO: if habits.csv is empty
        // render sample example_habits
        try tui.render(&example_habits);
        // else: load habits from ./habits.csv
        // try tui.render(loaded_habits);
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
    }
}

// Habits Array - Sample data
const example_habits = [_]model.Habit{
    .{ .name = "Meditation", .date = "10.01" },
    .{ .name = "Exercise", .date = "10.01" },
    .{ .name = "Read", .date = "10.01" },
    .{ .name = "Journal", .date = "10.01" },
    .{ .name = "Meditation", .date = "10.02" },
    .{ .name = "Read", .date = "10.02" },
    .{ .name = "Exercise", .date = "10.03" },
    .{ .name = "Read", .date = "10.03" },
    .{ .name = "Meditation", .date = "10.03" },
    .{ .name = "Ziglings", .date = "10.01" },
    .{ .name = "Ziglings", .date = "10.02" },
    .{ .name = "Ziglings", .date = "10.03" },
    .{ .name = "Ziglings", .date = "10.04" },
    .{ .name = "Ziglings", .date = "10.05" },
    .{ .name = "Ziglings", .date = "10.06" },
    .{ .name = "Ziglings", .date = "10.07" },
    .{ .name = "Ziglings", .date = "10.08" },
    .{ .name = "Ziglings", .date = "10.09" },
    .{ .name = "Ziglings", .date = "10.10" },
    .{ .name = "Ziglings", .date = "10.11" },
    .{ .name = "Ziglings", .date = "10.12" },
    .{ .name = "PT", .date = "10.01" },
    .{ .name = "PT", .date = "10.03" },
    .{ .name = "PT", .date = "10.05" },
    .{ .name = "Game", .date = "10.02" },
    .{ .name = "Game", .date = "10.04" },
    .{ .name = "Game", .date = "10.06" },
    .{ .name = "Game", .date = "10.08" },
    .{ .name = "Game", .date = "10.10" },

    .{ .name = "Project", .date = "10.01" },
    .{ .name = "Project", .date = "10.04" },
    .{ .name = "Project", .date = "10.07" },
    .{ .name = "Stretch", .date = "10.01" },
    .{ .name = "Stretch", .date = "10.02" },
    .{ .name = "Stretch", .date = "10.03" },
    .{ .name = "Stretch", .date = "10.04" },
    .{ .name = "Cook", .date = "10.02" },
    .{ .name = "Cook", .date = "10.03" },
    .{ .name = "Cook", .date = "10.05" },
    .{ .name = "Walk", .date = "10.01" },
    .{ .name = "Walk", .date = "10.02" },
    .{ .name = "Walk", .date = "10.22" },
    .{ .name = "Walk", .date = "10.23" },
    .{ .name = "Walk", .date = "10.28" },
    .{ .name = "Deep Work", .date = "10.01" },
    .{ .name = "Deep Work", .date = "10.03" },
    .{ .name = "Deep Work", .date = "10.04" },
    .{ .name = "Deep Work", .date = "10.05" },
    .{ .name = "Connect", .date = "10.02" },
    .{ .name = "Connect", .date = "10.03" },
    .{ .name = "Connect", .date = "10.06" },
    .{ .name = "Connect", .date = "10.07" },
    .{ .name = "Connect", .date = "10.14" },
    .{ .name = "8-sleep", .date = "10.01" },
    .{ .name = "8-sleep", .date = "10.04" },
    .{ .name = "8-sleep", .date = "10.22" },
};
