const std = @import("std");
const fmt = std.fmt;
const heap = std.heap;
const mem = std.mem;
const meta = std.meta;
const common = @import("common.zig");
const vaxis = @import("vaxis");
const log = std.log.scoped(.main);
const model = @import("model.zig");

const ActiveSection = enum {
    top,
    mid,
    btm,
};

pub fn render(habits: []const model.Habit) !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.detectLeaks()) log.err("Memory leak detected!", .{});

    const alloc = gpa.allocator();

    // Build habit tally map and dates map
    var aggregated_habits = try buildHabitTallyMap(alloc, habits[0..]);
    defer {
        for (aggregated_habits.items) |item| {
            alloc.free(item.name);
            alloc.free(item.tally);
        }
        aggregated_habits.deinit(alloc);
    }

    var habit_dates_map = try buildHabitDatesMap(alloc, habits[0..]);
    defer {
        var it = habit_dates_map.iterator();
        while (it.next()) |entry| {
            alloc.free(entry.value_ptr.*);
        }
        habit_dates_map.deinit();
    }

    var habit_mal = std.MultiArrayList(model.HabitAggregate){};
    for (aggregated_habits.items) |habit| {
        try habit_mal.append(alloc, habit);
    }
    defer habit_mal.deinit(alloc);

    var buffer: [1024]u8 = undefined;
    var tty = try vaxis.Tty.init(&buffer);
    defer tty.deinit();

    const tty_writer = tty.writer();
    var vx = try vaxis.init(alloc, .{
        .kitty_keyboard_flags = .{ .report_events = true },
    });
    defer vx.deinit(alloc, tty.writer());

    var loop: vaxis.Loop(union(enum) {
        key_press: vaxis.Key,
        winsize: vaxis.Winsize,
        table_upd,
    }) = .{ .tty = &tty, .vaxis = &vx };
    try loop.init();
    try loop.start();
    defer loop.stop();
    try vx.enterAltScreen(tty.writer());
    try vx.queryTerminal(tty.writer(), 250 * std.time.ns_per_ms);

    const title_logo = vaxis.Cell.Segment{
        .text = common.logoSmall,
        .style = .{
            .fg = .{ .rgb = .{ 255, 255, 255 } },
            .bg = .{ .rgb = .{ 0, 0, 0 } },
        },
    };

    var title_segs = [_]vaxis.Cell.Segment{title_logo};

    var cmd_input = vaxis.widgets.TextInput.init(alloc);
    defer cmd_input.deinit();

    // Colors
    const active_bg: vaxis.Cell.Color = .{ .rgb = .{ 235, 168, 66 } };
    const selected_bg: vaxis.Cell.Color = .{ .rgb = .{ 128, 128, 128 } };
    const other_bg: vaxis.Cell.Color = .{ .rgb = .{ 0, 0, 0 } };

    // Table Context
    var demo_tbl: vaxis.widgets.Table.TableContext = .{
        .active_bg = active_bg,
        .active_fg = .{ .rgb = .{ 0, 0, 0 } },
        .row_bg_1 = .{ .rgb = .{ 32, 32, 20 } },
        .selected_bg = selected_bg,
        .header_names = .{ .custom = &.{ "Habit Name", "Tally" } },
        //.header_align = .left,
        .col_indexes = .{ .by_idx = &.{ 0, 1 } },
        //.col_align = .{ .by_idx = &.{ .left, .left, .center, .center, .left } },
        // .col_align = .{ .all = .center },
        //.header_borders = true,
        //.col_borders = true,
        // .col_width = .{ .static_all = 15 },
        // .col_width = .{ .dynamic_header_len = 3 },
        .col_width = .{ .static_individual = &.{
            20,
            80,
        } },
        //.col_width = .dynamic_fill,
        //.y_off = 10,
    };
    defer if (demo_tbl.sel_rows) |rows| alloc.free(rows);

    // TUI State
    var active: ActiveSection = .mid;
    var moving = false;
    var see_content = false;

    // Create an Arena Allocator for easy allocations on each Event.
    var event_arena = heap.ArenaAllocator.init(alloc);
    defer event_arena.deinit();
    while (true) {
        defer _ = event_arena.reset(.retain_capacity);
        defer tty_writer.flush() catch {};
        const event_alloc = event_arena.allocator();
        const event = loop.nextEvent();

        switch (event) {
            .key_press => |key| keyEvt: {
                // Close the Program
                if (key.matches('c', .{ .ctrl = true })) {
                    break;
                }
                // Refresh the Screen
                if (key.matches('l', .{ .ctrl = true })) {
                    vx.queueRefresh();
                    break :keyEvt;
                }
                // Enter Moving State
                if (key.matches('w', .{ .ctrl = true })) {
                    moving = !moving;
                    break :keyEvt;
                }
                // Command State
                if (active != .btm and
                    key.matchesAny(&.{ ':', '/', 'g', 'G' }, .{}))
                {
                    active = .btm;
                    cmd_input.clearAndFree();
                    try cmd_input.update(.{ .key_press = key });
                    break :keyEvt;
                }

                switch (active) {
                    .top => {
                        if (key.matchesAny(&.{ vaxis.Key.down, 'j' }, .{}) and moving) active = .mid;
                    },
                    .mid => midEvt: {
                        if (moving) {
                            if (key.matchesAny(&.{ vaxis.Key.up, 'k' }, .{})) active = .top;
                            if (key.matchesAny(&.{ vaxis.Key.down, 'j' }, .{})) active = .btm;
                            break :midEvt;
                        }
                        // Change Row
                        if (key.matchesAny(&.{ vaxis.Key.up, 'k' }, .{})) demo_tbl.row -|= 1;
                        if (key.matchesAny(&.{ vaxis.Key.down, 'j' }, .{})) demo_tbl.row +|= 1;
                        // Change Column
                        if (key.matchesAny(&.{ vaxis.Key.left, 'h' }, .{})) demo_tbl.col -|= 1;
                        if (key.matchesAny(&.{ vaxis.Key.right, 'l' }, .{})) demo_tbl.col +|= 1;
                        // Select/Unselect Row
                        if (key.matches(vaxis.Key.space, .{})) {
                            const rows = demo_tbl.sel_rows orelse createRows: {
                                demo_tbl.sel_rows = try alloc.alloc(u16, 1);
                                break :createRows demo_tbl.sel_rows.?;
                            };
                            var rows_list = std.ArrayList(u16).fromOwnedSlice(rows);
                            for (rows_list.items, 0..) |row, idx| {
                                if (row != demo_tbl.row) continue;
                                _ = rows_list.orderedRemove(idx);
                                break;
                            } else try rows_list.append(alloc, demo_tbl.row);
                            demo_tbl.sel_rows = try rows_list.toOwnedSlice(alloc);
                        }
                        // See Row Content
                        if (key.matches(vaxis.Key.enter, .{}) or key.matches('j', .{ .ctrl = true })) see_content = !see_content;
                    },
                    .btm => {
                        if (key.matchesAny(&.{ vaxis.Key.up, 'k' }, .{}) and moving) active = .mid
                            // Run Command and Clear Command Bar
                        else if (key.matchExact(vaxis.Key.enter, .{}) or key.matchExact('j', .{ .ctrl = true })) {
                            const cmd = try cmd_input.toOwnedSlice();
                            defer alloc.free(cmd);
                            if (mem.eql(u8, ":q", cmd) or
                                mem.eql(u8, ":quit", cmd) or
                                mem.eql(u8, ":exit", cmd)) return;
                            if (mem.eql(u8, "G", cmd)) {
                                demo_tbl.row = @intCast(aggregated_habits.items.len - 1);
                                active = .mid;
                            }
                            if (cmd.len >= 2 and mem.eql(u8, "gg", cmd[0..2])) {
                                const goto_row = fmt.parseInt(u16, cmd[2..], 0) catch 0;
                                demo_tbl.row = goto_row;
                                active = .mid;
                            }
                        } else try cmd_input.update(.{ .key_press = key });
                    },
                }
                moving = false;
            },
            .winsize => |ws| try vx.resize(alloc, tty.writer(), ws),
            else => {},
        }

        // Content
        seeRow: {
            if (!see_content) {
                demo_tbl.active_content_fn = null;
                demo_tbl.active_ctx = &{};
                break :seeRow;
            }
            const RowContext = struct {
                dates: []const u8,
                bg: vaxis.Color,
            };

            // Get the dates for the selected habit
            const selected_habit = if (demo_tbl.row < aggregated_habits.items.len)
                aggregated_habits.items[demo_tbl.row]
            else
                break :seeRow;

            const habit_dates = habit_dates_map.get(selected_habit.name) orelse break :seeRow;

            // Format dates as a comma-separated string
            var dates_buf = std.ArrayList(u8){};
            for (habit_dates, 0..) |date, i| {
                try dates_buf.appendSlice(event_alloc, date);
                if (i < habit_dates.len - 1) {
                    try dates_buf.appendSlice(event_alloc, ", ");
                }
            }

            const row_ctx = RowContext{
                .dates = try dates_buf.toOwnedSlice(event_alloc),
                .bg = demo_tbl.active_bg,
            };
            demo_tbl.active_ctx = &row_ctx;
            demo_tbl.active_content_fn = struct {
                fn see(win: *vaxis.Window, ctx_raw: *const anyopaque) !u16 {
                    const ctx: *const RowContext = @ptrCast(@alignCast(ctx_raw));
                    const lines_needed = @min((ctx.dates.len / win.width) + 2, 5);
                    win.height = @intCast(lines_needed);
                    const see_win = win.child(.{
                        .x_off = 0,
                        .y_off = 1,
                        .width = win.width,
                        .height = @intCast(lines_needed),
                    });
                    see_win.fill(.{ .style = .{ .bg = ctx.bg } });
                    const content_segs: []const vaxis.Cell.Segment = &.{
                        .{
                            .text = ctx.dates,
                            .style = .{ .bg = ctx.bg },
                        },
                    };
                    _ = see_win.print(content_segs, .{ .wrap = .word });
                    return see_win.height;
                }
            }.see;
            loop.postEvent(.table_upd);
        }

        // Sections
        // - Window
        const win = vx.window();
        win.clear();

        // - Top
        const top_div = 13;
        const top_bar = win.child(.{
            .x_off = 0,
            .y_off = 0,
            .width = win.width,
            .height = win.height / top_div,
        });
        for (title_segs[0..]) |*title_seg|
            title_seg.style.bg = if (active == .top) selected_bg else other_bg;
        top_bar.fill(.{ .style = .{
            .bg = if (active == .top) selected_bg else other_bg,
        } });
        const logo_bar = vaxis.widgets.alignment.center(
            top_bar,
            10,
            top_bar.height - (top_bar.height / 3),
        );
        _ = logo_bar.print(title_segs[0..], .{ .wrap = .word });

        // - Middle
        const middle_bar = win.child(.{
            .x_off = 0,
            .y_off = win.height / top_div,
            .width = win.width,
            .height = win.height - (top_bar.height + 1),
        });
        if (aggregated_habits.items.len > 0) {
            demo_tbl.active = active == .mid;
            try vaxis.widgets.Table.drawTable(
                event_alloc,
                middle_bar,
                habit_mal,
                &demo_tbl,
            );
        }

        // - Bottom
        const bottom_bar = win.child(.{
            .x_off = 0,
            .y_off = win.height - 1,
            .width = win.width,
            .height = 1,
        });
        if (active == .btm) bottom_bar.fill(.{ .style = .{ .bg = active_bg } });
        cmd_input.draw(bottom_bar);

        // Render the screen
        try vx.render(tty_writer);
    }
}

fn buildHabitTallyMap(allocator: mem.Allocator, habits_input: []const model.Habit) !std.ArrayList(model.HabitAggregate) {
    var tally_map = std.StringHashMap(usize).init(allocator);
    defer tally_map.deinit();

    // Count occurrences
    for (habits_input) |habit| {
        const entry = try tally_map.getOrPut(habit.name);
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }

    // Build result list
    var result = std.ArrayList(model.HabitAggregate){};
    var it = tally_map.iterator();
    while (it.next()) |entry| {
        const name = try allocator.dupe(u8, entry.key_ptr.*);

        // Create tally string with dots (● )
        const count = entry.value_ptr.*;
        const bytes_per_dot = 4; // UTF-8 ● is 3 bytes + 1 byte space
        var tally_buf = try allocator.alloc(u8, count * bytes_per_dot); // UTF-8 ● is 3 bytes
        var idx: usize = 0;
        for (0..count) |_| {
            @memcpy(tally_buf[idx .. idx + 3], "●");
            tally_buf[idx + 3] = ' ';
            idx += 4;
        }

        try result.append(allocator, .{
            .name = name,
            .tally = tally_buf,
        });
    }

    return result;
}

fn buildHabitDatesMap(allocator: mem.Allocator, habits_input: []const model.Habit) !std.StringHashMap([]const []const u8) {
    var dates_map = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);
    defer {
        var dates_it = dates_map.iterator();
        while (dates_it.next()) |entry| {
            entry.value_ptr.deinit(allocator);
        }
        dates_map.deinit();
    }

    // Collect dates for each habit
    for (habits_input) |habit| {
        const dates_entry = try dates_map.getOrPut(habit.name);
        if (!dates_entry.found_existing) {
            dates_entry.value_ptr.* = std.ArrayList([]const u8){};
        }
        try dates_entry.value_ptr.append(allocator, habit.date);
    }

    // Build final map
    var result = std.StringHashMap([]const []const u8).init(allocator);
    var it = dates_map.iterator();
    while (it.next()) |entry| {
        const dates_slice = try allocator.dupe([]const u8, entry.value_ptr.items);
        try result.put(entry.key_ptr.*, dates_slice);
    }

    return result;
}
