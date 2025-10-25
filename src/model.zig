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

    /// Returns today's date
    pub fn now() Date {
        const timestamp = std.time.timestamp();
        const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(timestamp) };
        const epoch_day = epoch_seconds.getEpochDay();
        const year_day = epoch_day.calculateYearDay();
        const month_day = year_day.calculateMonthDay();
        return Date{ .year = @intCast(year_day.year), .month = @intFromEnum(month_day.month), .day = month_day.day_index };
    }

    /// Formats the date as YYYY.MM.DD
    pub fn toStringFull(self: Date, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d:0>4}.{d:0>2}.{d:0>2}", .{ self.year, self.month, self.day });
    }

    /// Formats the date as MM.DD
    pub fn toStringMMDD(self: Date, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d:0>2}.{d:0>2}", .{ self.month, self.day });
    }
};
