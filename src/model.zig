const std = @import("std");

pub const Habit = struct {
    name: []const u8,
    date: []const u8,
    description: ?[]const u8 = null,
};

pub const HabitAggregate = struct {
    name: []const u8,
    tally: []const u8,
};

pub const HabitDates = struct {
    habit_name: []const u8,
    dates: []const []const u8,
};

pub const Date = struct {
    year: u16,
    month: u8,
    day: u8,

    /// Returns today's date in America/New_York timezone
    pub fn now() Date {
        const timestamp = std.time.timestamp();

        // America/New_York uses:
        // - EST (UTC-5) from November to March
        // - EDT (UTC-4) from March to November
        // For simplicity, using EDT offset (UTC-4) as default
        // TODO: Implement proper DST calculation for automatic switching
        const ny_offset: i64 = 3600 * -4; // EDT offset
        const ny_timestamp = timestamp + ny_offset;
        const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(ny_timestamp) };
        const epoch_day = epoch_seconds.getEpochDay();
        const year_day = epoch_day.calculateYearDay();
        const month_day = year_day.calculateMonthDay();

        // day_index is 0-indexed, so add 1 to get the actual day of month
        const day_of_month = month_day.day_index + 1;

        return Date{ .year = @intCast(year_day.year), .month = @intFromEnum(month_day.month), .day = day_of_month };
    }

    /// Formats the date as YYYY-MM-DD (ISO 8601 standard)
    pub fn toStringISO(self: Date, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d:0>4}-{d:0>2}-{d:0>2}", .{ self.year, self.month, self.day });
    }
};
