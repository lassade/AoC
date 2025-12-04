pub fn findPaper(input: []const u8) usize {
    var sum: usize = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    var rows_buffer: [256][]const u8 = undefined;
    var rows: [][]const u8 = rows_buffer[0..0];
    while (it.next()) |row| {
        if (row.len == 0) break;
        rows.ptr[rows.len] = row;
        rows.len += 1;
    }
    const y_max = rows.len - 1;
    const x_len = rows[0].len;
    const x_max = x_len - 1;
    for (0..rows.len) |y| {
        for (0..x_len) |x| {
            if (rows[y][x] == '@') {
                var count: usize = 0;
                if (y > 0) {
                    if (x > 0 and rows[y - 1][x - 1] == '@') count += 1;
                    if (x < x_max and rows[y - 1][x + 1] == '@') count += 1;
                    if (rows[y - 1][x] == '@') count += 1;
                }
                if (y < y_max) {
                    if (x > 0 and rows[y + 1][x - 1] == '@') count += 1;
                    if (x < x_max and rows[y + 1][x + 1] == '@') count += 1;
                    if (rows[y + 1][x] == '@') count += 1;
                }
                if (x > 0 and rows[y][x - 1] == '@') count += 1;
                if (x < x_max and rows[y][x + 1] == '@') count += 1;
                if (count < 4) {
                    sum += 1;
                }
                // std.debug.print("{d}", .{count});
            } else {
                // std.debug.print(".", .{});
            }
        }
        // std.debug.print("\n", .{});
    }
    return sum;
}
pub fn removePaper(input: []const u8) usize {
    var input_buffer: [256 * 256]u8 = undefined;
    @memcpy(input_buffer[0..input.len], input);
    var sum: usize = 0;
    var it = std.mem.splitScalar(u8, input_buffer[0..input.len], '\n');
    var rows_buffer: [256][]u8 = undefined;
    var rows: [][]u8 = rows_buffer[0..0];
    while (it.next()) |row| {
        if (row.len == 0) break;
        rows.ptr[rows.len] = @constCast(row);
        rows.len += 1;
    }
    var remove_buffer: [4096]*u8 = undefined;
    var remove = std.ArrayList(*u8).fromOwnedSlice(&remove_buffer);
    while (true) {
        remove.clearRetainingCapacity();
        var next: usize = 0;
        const y_max = rows.len - 1;
        const x_len = rows[0].len;
        const x_max = x_len - 1;
        for (0..rows.len) |y| {
            for (0..x_len) |x| {
                if (rows[y][x] == '@') {
                    var count: usize = 0;
                    if (y > 0) {
                        if (x > 0 and rows[y - 1][x - 1] == '@') count += 1;
                        if (x < x_max and rows[y - 1][x + 1] == '@') count += 1;
                        if (rows[y - 1][x] == '@') count += 1;
                    }
                    if (y < y_max) {
                        if (x > 0 and rows[y + 1][x - 1] == '@') count += 1;
                        if (x < x_max and rows[y + 1][x + 1] == '@') count += 1;
                        if (rows[y + 1][x] == '@') count += 1;
                    }
                    if (x > 0 and rows[y][x - 1] == '@') count += 1;
                    if (x < x_max and rows[y][x + 1] == '@') count += 1;
                    if (count < 4) {
                        remove.appendAssumeCapacity(&rows[y][x]);
                        next += 1;
                    }
                    // std.debug.print("{d}", .{count});
                } else {
                    // std.debug.print(".", .{});
                }
            }
            // std.debug.print("\n", .{});
        }
        if (next == 0) break;
        sum += next;

        for (remove.items) |ptr| ptr.* = '.';

        // std.debug.print("{d}\n", .{next});
    }
    return sum;
}
test {
    const input = @embedFile("day4.txt");
    try std.testing.expectEqual(1363, findPaper(input));
    try std.testing.expectEqual(8184, removePaper(input));
}
test {
    const input =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;
    try std.testing.expectEqual(13, findPaper(input));
    try std.testing.expectEqual(43, removePaper(input));
}
const std = @import("std");
