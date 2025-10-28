const std = @import("std");
const model = @import("model.zig");

pub const CsvError = error{
    InvalidFormat,
    EmptyFile,
    MissingDate,
};

/// Load habits from a CSV file
/// CSV Format:
///   date,habits
///   2025-10-26,read,meditate,cook
///   2025-10-27,cook,zig,project
///
/// Returns an ArrayList of Habit structs with dates converted to MM.DD format
pub fn loadHabitsFromCsv(allocator: std.mem.Allocator, file_path: []const u8) !std.ArrayList(model.Habit) {
    var habits = std.ArrayList(model.Habit){};
    errdefer habits.deinit(allocator);

    // Open the file
    const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
        std.debug.print("Error opening file '{s}': {any}\n", .{ file_path, err });
        return err;
    };
    defer file.close();

    // Read the entire file
    const file_size = try file.getEndPos();
    if (file_size == 0) {
        return CsvError.EmptyFile;
    }

    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    // Split into lines
    var lines_iter = std.mem.splitScalar(u8, content, '\n');
    var line_num: usize = 0;

    while (lines_iter.next()) |line| {
        line_num += 1;

        // Skip empty lines
        const trimmed_line = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed_line.len == 0) continue;

        // Skip header line
        if (line_num == 1) continue;

        // Parse the CSV line
        var fields_iter = std.mem.splitScalar(u8, trimmed_line, ',');

        // First field should be the date
        const date_field = fields_iter.next() orelse {
            std.debug.print("Warning: Line {d} missing date, skipping\n", .{line_num});
            continue;
        };

        const date_str = std.mem.trim(u8, date_field, &std.ascii.whitespace);
        if (date_str.len == 0) {
            std.debug.print("Warning: Line {d} has empty date, skipping\n", .{line_num});
            continue;
        }

        // Convert full date (YYYY-MM-DD) to short format (MM-DD)
        const short_date_dashes = try convertToShortDate(allocator, date_str);

        // Convert dashes to dots for display consistency with example habits
        const short_date = try dashesToDots(allocator, short_date_dashes);
        allocator.free(short_date_dashes);

        // Parse remaining fields as habit names
        while (fields_iter.next()) |field| {
            const habit_name = std.mem.trim(u8, field, &std.ascii.whitespace);

            // Skip empty habit names
            if (habit_name.len == 0) continue;

            // Create a new Habit struct
            const habit = model.Habit{
                .name = try allocator.dupe(u8, habit_name),
                .date = short_date,
                .description = null,
            };

            try habits.append(allocator, habit);
        }
    }

    return habits;
}

/// Convert date from YYYY-MM-DD format to MM-DD format
/// Much simpler with dashes!
fn convertToShortDate(allocator: std.mem.Allocator, full_date: []const u8) ![]const u8 {
    // Expected format: YYYY-MM-DD -> Extract MM-DD
    // Just find the first dash and take everything after it

    if (std.mem.indexOf(u8, full_date, "-")) |first_dash| {
        const short_date = full_date[first_dash + 1 ..];
        return try allocator.dupe(u8, short_date);
    }

    // If no dash found, return as-is (already in short format or invalid)
    return try allocator.dupe(u8, full_date);
}

/// Convert dashes to dots for display in TUI
/// e.g., "10-26" -> "10.26" or "2025-10-26" -> "2025.10.26"
pub fn dashesToDots(allocator: std.mem.Allocator, date_str: []const u8) ![]u8 {
    var result = try allocator.alloc(u8, date_str.len);
    for (date_str, 0..) |char, i| {
        result[i] = if (char == '-') '.' else char;
    }
    return result;
}

/// Check if a file exists
pub fn fileExists(file_path: []const u8) bool {
    const file = std.fs.cwd().openFile(file_path, .{}) catch {
        return false;
    };
    file.close();
    return true;
}
