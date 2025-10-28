const std = @import("std");
const model = @import("model.zig");

pub const CSVError = error{ InvalidFormat, EmptyFile, MissingDate };

/// Load habits from a CSV file
/// CSV Format:
///   date,habits
///   2025-10-26,read,meditate,cook
///   2025-10-27,cook,zig,project
///
/// Returns an ArrayList of Habit structs with dates converted to MM.DD format
pub fn loadHabits(allocator: std.mem.Allocator, file_path: []const u8) !std.ArrayList(model.Habit) {
    var habits = std.ArrayList(model.Habit){};
    errdefer habits.deinit(allocator);

    // Open the file
    const file = std.fs.cwd().openFile(file_path, .{}) catch |err| {
        std.debug.print("Error opening file '{s}': {any}\n", .{ file_path, err });
        return err;
    };
    defer file.close();

    // Read the file contents
    const file_size = try file.getEndPos();
    if (file_size == 0) {
        return CSVError.EmptyFile;
    }

    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    // Split into lines
    var lines_iter = std.mem.splitScalar(u8, content, '\n'); // parser
    var line_num: usize = 0;

    while (lines_iter.next()) |line| {
        line_num += 1;

        // skip empty lines
        const trimmed_line = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed_line.len == 0) continue;

        // Skip header line
        if (line_num == 1) continue;

        // Parse the CSV line
        var fields_iter = std.mem.splitScalar(u8, trimmed_line, ',');

        // First field is date (2025-10-01)
        const date_field = fields_iter.next() orelse {
            std.debug.print("Warning: Missing date on line {d}, skipping\n", .{line_num});
            continue;
        };

        // Skip empty date line
        const date_str = std.mem.trim(u8, date_field, &std.ascii.whitespace);
        if (date_str.len == 0) {
            std.debug.print("Warning: Empty date on line {d}, skipping\n", .{line_num});
            continue;
        }

        // Convert full date YYYY-MM-DD to short format MM-DD
        const short_date_dashes = try convertToShortDate(allocator, date_str);

        // Convert dashes to dots
        const short_date = try dashesToDots(allocator, short_date_dashes);
        allocator.free(short_date_dashes);

        // Parse remaining fields as habit names
        while (fields_iter.next()) |field| {
            const habit_name = std.mem.trim(u8, field, &std.ascii.whitespace);

            // Skip empty habit row
            if (habit_name.len == 0) continue;

            const habit = model.Habit{
                .name = try allocator.dupe(u8, habit_name),
                .date = short_date,
                .description = null,
            };

            // Add habit to habits list
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

pub fn fileExists(file_path: []const u8) bool {
    const file = std.fs.cwd().openFile(file_path, .{}) catch {
        return false;
    };
    file.close();

    return true;
}

/// Append habits to CSV file
/// If file doesn't exist, create it with header
/// Format: date,habit1,habit2,habit3
pub fn appendHabits(_: std.mem.Allocator, file_path: []const u8, date: []const u8, habit_names: []const []const u8) !void {
    // Try to open file, if it doesn't exist, create it
    const file = std.fs.cwd().openFile(file_path, .{ .mode = .read_write }) catch |err| {
        if (err == error.FileNotFound) {
            // Create new file
            const new_file = try std.fs.cwd().createFile(file_path, .{});
            defer new_file.close();

            // Write header
            try new_file.writeAll("date,habits\n");

            // Write the habits
            try new_file.writeAll(date);
            for (habit_names) |habit| {
                try new_file.writeAll(",");
                try new_file.writeAll(habit);
            }
            try new_file.writeAll("\n");
            return;
        }
        return err;
    };
    defer file.close();

    // If file exists, append to it
    try file.seekFromEnd(0);

    // Write the new line
    try file.writeAll(date);
    for (habit_names) |habit| {
        try file.writeAll(",");
        try file.writeAll(habit);
    }
    try file.writeAll("\n");
}

/// Update or add habits for a given date
/// If the date exists, appends new habits to existing ones (skips dups). Otherwise creates a new line.
pub fn updateHabits(allocator: std.mem.Allocator, file_path: []const u8, date: []const u8, habit_names: []const []const u8) !void {
    if (!fileExists(file_path)) {
        // File doesn't exist, create it
        return appendHabits(allocator, file_path, date, habit_names);
    }

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(content);

    // Build new content
    var new_lines = std.ArrayList([]const u8){};
    defer new_lines.deinit(allocator);

    var lines_iter = std.mem.splitScalar(u8, content, '\n');
    var line_num: usize = 0;
    var date_found = false;

    while (lines_iter.next()) |line| {
        line_num += 1;

        // Always keep header
        if (line_num == 1) {
            try new_lines.append(allocator, line);
            continue;
        }

        const trimmed_line = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed_line.len == 0) continue;

        var fields_iter = std.mem.splitScalar(u8, trimmed_line, ',');
        if (fields_iter.next()) |date_field| {
            const date_str = std.mem.trim(u8, date_field, &std.ascii.whitespace);
            if (std.mem.eql(u8, date_str, date)) {
                // Found the date, append with new habits if they don't already exist
                var new_line = std.ArrayList(u8){};
                defer new_line.deinit(allocator);

                // Start with existing line
                try new_line.appendSlice(allocator, line);
                // Parse existing habits from the line
                var existing_habits = std.StringHashMap(void).init(allocator);
                defer existing_habits.deinit();

                var habit_iter = fields_iter; // Continue from where we left off
                while (habit_iter.next()) |habit_field| {
                    const habit_str = std.mem.trim(u8, habit_field, &std.ascii.whitespace);
                    if (habit_str.len > 0) {
                        try existing_habits.put(habit_str, {});
                    }
                }
                // Append new habits that don't exists
                for (habit_names) |habit| {
                    if (!existing_habits.contains(habit)) {
                        try new_line.append(allocator, ',');
                        try new_line.appendSlice(allocator, habit);
                    }
                }

                try new_lines.append(allocator, try new_line.toOwnedSlice(allocator));
                date_found = true;
            } else {
                // Keep existing line
                try new_lines.append(allocator, line);
            }
        } else {
            try new_lines.append(allocator, line);
        }
    }

    // If date wasn't found, add it
    if (!date_found) {
        var new_line = std.ArrayList(u8){};
        defer new_line.deinit(allocator);

        try new_line.appendSlice(allocator, date);
        for (habit_names) |habit| {
            try new_line.append(allocator, ',');
            try new_line.appendSlice(allocator, habit);
        }

        try new_lines.append(allocator, try new_line.toOwnedSlice(allocator));
    }

    // Write new content to file
    const new_file = try std.fs.cwd().createFile(file_path, .{});
    defer new_file.close();

    for (new_lines.items, 0..) |line, i| {
        try new_file.writeAll(line);
        if (i < new_lines.items.len - 1 or line.len > 0) {
            try new_file.writeAll("\n");
        }
    }

    // Free allocated lines
    for (new_lines.items) |line| {
        if (line_num > 1) { // Don't free header or original lines
            var found_in_original = false;
            var check_iter = std.mem.splitScalar(u8, content, '\n');
            while (check_iter.next()) |orig_line| {
                if (std.mem.eql(u8, line, orig_line)) {
                    found_in_original = true;
                    break;
                }
            }
            if (!found_in_original) {
                allocator.free(line);
            }
        }
    }
}
