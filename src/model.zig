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
