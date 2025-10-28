const std = @import("std");
const argh = @import("argh");
const tui = @import("tui.zig");
const common = @import("common.zig");
const model = @import("model.zig");
const csv = @import("csv.zig");

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
    try parser.addPositionalWithCount("habits", "Habits to track", 0, 100);
    try parser.parse();

    // if errors
    if (parser.errors.items.len > 0) {
        parser.printErrors();
    }

    // if --help
    if (parser.flagPresent("--help") or parser.flagPresent("-h")) {
        std.debug.print("{s}\nA minimal habit tracking CLI\n\n", .{common.logo});
        parser.printHelpWithOptions(.flat);
        return;
    }

    // Check if any unparsed arguments remain (these would be positional arguments)
    if (parser.args.len == 0) {
        // Check if habits.csv exists
        const csv_path = "habits.csv";

        if (csv.fileExists(csv_path)) {
            // Load habits from CSV
            var loaded_habits = csv.loadHabits(allocator, csv_path) catch |err| {
                std.debug.print("Error loading habits from CSV: {any}\n", .{err});
                std.debug.print("Using example habits instead \n\n", .{});

                try tui.render(&example_habits);
                return;
            };
            defer loaded_habits.deinit(allocator);
            // Render habits
            try tui.render(loaded_habits.items);
            return;
        } else {
            // No file, rendering example habits
            std.debug.print("No habits.csv found, using example habits\n\n", .{});
            try tui.render(&example_habits);
        }
    } else {
        // Input parsing

        // Track each habit provided as positional arguments
        // Use parser.args which contains the remaining unparsed arguments
        const csv_path = "habits.csv";
        const today = model.Date.now();
        const today_str = try today.toStringISO(allocator);

        // Update/overwrite habits for today
        try csv.updateHabits(allocator, csv_path, today_str, parser.args);

        std.debug.print("✓ Logged {d} habit(s) for {s}:\n", .{ parser.args.len, today_str });
        for (parser.args) |habit| {
            std.debug.print("  - {s}\n", .{habit});
        }
    }
}

// Habits Array - Sample data
const example_habits = [_]model.Habit{
    .{ .name = "Meditation", .date = "2025-10-01" },
    .{ .name = "Exercise", .date = "2025-10-01" },
    .{ .name = "Read", .date = "2025-10-01" },
    .{ .name = "Journal", .date = "2025-10-01" },
    .{ .name = "Meditation", .date = "2025-10-02" },
    .{ .name = "Read", .date = "2025-10-02" },
    .{ .name = "Exercise", .date = "2025-10-03" },
    .{ .name = "Read", .date = "2025-10-03" },
    .{ .name = "Meditation", .date = "2025-10-03" },
    .{ .name = "Ziglings", .date = "2025-10-01" },
    .{ .name = "Ziglings", .date = "2025-10-02" },
    .{ .name = "Ziglings", .date = "2025-10-03" },
    .{ .name = "Ziglings", .date = "2025-10-04" },
    .{ .name = "Ziglings", .date = "2025-10-05" },
    .{ .name = "Ziglings", .date = "2025-10-06" },
    .{ .name = "Ziglings", .date = "2025-10-07" },
    .{ .name = "Ziglings", .date = "2025-10-08" },
    .{ .name = "Ziglings", .date = "2025-10-09" },
    .{ .name = "Ziglings", .date = "2025-10-10" },
    .{ .name = "Ziglings", .date = "2025-10-11" },
    .{ .name = "Ziglings", .date = "2025-10-12" },
    .{ .name = "PT", .date = "2025-10-01" },
    .{ .name = "PT", .date = "2025-10-03" },
    .{ .name = "PT", .date = "2025-10-05" },
    .{ .name = "Game", .date = "2025-10-02" },
    .{ .name = "Game", .date = "2025-10-04" },
    .{ .name = "Game", .date = "2025-10-06" },
    .{ .name = "Game", .date = "2025-10-08" },
    .{ .name = "Game", .date = "2025-10-10" },

    .{ .name = "Project", .date = "2025-10-01" },
    .{ .name = "Project", .date = "2025-10-04" },
    .{ .name = "Project", .date = "2025-10-07" },
    .{ .name = "Project", .date = "2025-10-10" },
    .{ .name = "Project", .date = "2025-10-13" },
    .{ .name = "Project", .date = "2025-10-16" },
    .{ .name = "Project", .date = "2025-10-19" },
    .{ .name = "Project", .date = "2025-10-22" },
    .{ .name = "Project", .date = "2025-10-25" },
    .{ .name = "Project", .date = "2025-10-28" },
    .{ .name = "Project", .date = "2025-10-29" },
    .{ .name = "Vim-motions", .date = "2025-10-01" },
    .{ .name = "Vim-motions", .date = "2025-10-02" },
    .{ .name = "Vim-motions", .date = "2025-10-03" },
    .{ .name = "Vim-motions", .date = "2025-10-04" },
    .{ .name = "Cook", .date = "2025-10-02" },
    .{ .name = "Cook", .date = "2025-10-03" },
    .{ .name = "Cook", .date = "2025-10-05" },
    .{ .name = "Walk", .date = "2025-10-01" },
    .{ .name = "Walk", .date = "2025-10-02" },
    .{ .name = "Walk", .date = "2025-10-22" },
    .{ .name = "Walk", .date = "2025-10-23" },
    .{ .name = "Walk", .date = "2025-10-28" },
    .{ .name = "Deep Work", .date = "2025-10-01" },
    .{ .name = "Deep Work", .date = "2025-10-03" },
    .{ .name = "Deep Work", .date = "2025-10-04" },
    .{ .name = "Deep Work", .date = "2025-10-05" },
    .{ .name = "Connect", .date = "2025-10-02" },
    .{ .name = "Connect", .date = "2025-10-03" },
    .{ .name = "Connect", .date = "2025-10-06" },
    .{ .name = "Connect", .date = "2025-10-07" },
    .{ .name = "Connect", .date = "2025-10-14" },
    .{ .name = "8-sleep", .date = "2025-10-01" },
    .{ .name = "8-sleep", .date = "2025-10-04" },
    .{ .name = "8-sleep", .date = "2025-10-22" },
};
