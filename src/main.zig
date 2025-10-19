const std = @import("std");
const minima = @import("minima");
const argh = @import("argh");

pub fn main() !void {
    const logo =
        \\
        \\╭───────╮
        \\│ ○ ○ ○ │
        \\│ ○ ○ ○ │
        \\│ ○ ○ ● │ minima
        \\╰───────╯
        \\
        \\ A minimal habbit tracking CLI
        \\
    ;

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
        std.debug.print("{s}\n", .{logo});
        parser.printHelpWithOptions(.simple_grouped);
        return;
    }

    if (parser.args.len == 0) {
        // show TUI
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

        // for (parser.args) |arg| {
        //     std.debug.print("arg::{s}\n", .{arg});
        // }

        try writeHabbitRow(allocator);

        // write task to csv function

        // format
        // ------
        // date,task
        // 2025-10-11,read
        // 2025-10-11,exercise
        // 2025-10-13,read
    }
}

// let's write a function that can create a CSV of habits, we'll call the file habits.csv
pub fn writeHabbitRow(allocator: std.mem.Allocator) !void {
    const file = try std.fs.cwd().createFile("habits.csv", .{ .read = true });
    defer file.close();

    // make a new Date and call .now and .toString on it
    const now = Date.now();
    const now_str = try now.toString(allocator);
    // pass the now to writeCSV
    const csv_content = try writeCSV(allocator, now_str);
    try file.writeAll(csv_content);
}

// TODO: take a list of tasks
fn writeCSV(allocator: std.mem.Allocator, date: []const u8) ![]u8 {
    const tmpl = "date,task\n{s},read,zig,cook,meditate\n";
    return try std.fmt.allocPrint(allocator, tmpl, .{date});
}

pub const Date = struct {
    year: u16,
    month: u8,
    day: u8,

    // make a private function called now that can be called to return today's date
    fn now() Date {
        const timestamp = std.time.timestamp();
        const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(timestamp) };
        const epoch_day = epoch_seconds.getEpochDay();
        const year_day = epoch_day.calculateYearDay();
        const month_day = year_day.calculateMonthDay();
        return Date{ .year = @intCast(year_day.year), .month = @intFromEnum(month_day.month), .day = month_day.day_index };
    }

    pub fn toString(self: Date, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d:0>4}-{d:0>2}-{d:0>2}", .{ self.year, self.month, self.day });
    }
};
