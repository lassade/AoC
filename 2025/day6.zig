pub fn part1(input: []const u8) usize {
    var lines = std.mem.splitBackwardsScalar(u8, input, '\n');
    var line = lines.next() orelse return 0;
    while (line.len == 0) line = lines.next() orelse return 0;

    const max_columns = 1024;

    var ops_buffer: [max_columns]u8 = undefined;
    var ops_count: usize = 0;
    for (line) |op| {
        if (op != ' ') {
            ops_buffer[ops_count] = op;
            ops_count += 1;
        }
    }
    if (ops_count == 0) return 0;

    var num_buffer: [max_columns]usize = @splat(0);
    if (lines.next()) |next_line| {
        var numbs = std.mem.splitScalar(u8, next_line, ' ');
        var num_count: usize = 0;
        while (numbs.next()) |num| {
            if (num.len == 0) continue;
            num_buffer[num_count] = std.fmt.parseUnsigned(usize, num, 10) catch @panic("BadInt");
            num_count += 1;
        }
        assert(num_count == ops_count);
    } else {
        return 0; // edge case
    }
    while (lines.next()) |next_line| {
        var i: usize = 0;
        var ops = std.mem.splitScalar(u8, next_line, ' ');
        while (ops.next()) |num| {
            if (num.len == 0) continue;
            const value = std.fmt.parseUnsigned(usize, num, 10) catch @panic("BadInt");
            if (ops_buffer[i] == '+') {
                num_buffer[i] += value;
            } else if (ops_buffer[i] == '*') {
                num_buffer[i] *= value;
            } else {
                unreachable;
            }
            i += 1;
        }
        assert(i == ops_count);
    }

    var sum: usize = 0;
    for (num_buffer[0..ops_count]) |value| {
        // print("{d}\n", .{value});
        sum += value;
    }

    return sum;
}
pub fn part2(input: []const u8) usize {
    var op0: usize = input.len - 1;
    var op1: usize = undefined;
    if (input[op0] == '\n') op0 -= 1;
    op1 = op0;
    while (input[op0 - 1] != '\n') op0 -= 1; // return to the begin of the line

    var i: usize = 0;
    var j: usize = op0;
    var pos: [2]u32 = .{ 0xffff_ffff, 0 };
    var sheet: [4][1024]usize = undefined;
    // var num_rows: usize = 0;
    @memset(std.mem.sliceAsBytes(&sheet), 0);
    while (i < op0) {
        if (input[i] == '\n') {
            i += 1;
            j = op0;
            pos[0] = 0xffff_ffff;
            continue;
        }
        if (input[j] != ' ') {
            pos[0] +%= 1;
            pos[1] = 0;
        }
        if (input[i] == ' ') {
            pos[1] += 1;
        } else {
            const value = input[i] - '0';
            assert(0 <= value and value <= 9);
            const cell = &sheet[pos[1]][pos[0]];
            cell.* = 10 * (cell.*) + value;
            pos[1] += 1;
        }
        i += 1;
        j += 1;
    }

    var sum: usize = 0;
    var x: usize = 0;
    var op: usize = op0;
    while (op < op1) {
        var y: usize = 1;
        var parcial: usize = sheet[0][x];
        if (input[op] == '+') {
            op += 2;
            while (input[op] == ' ') {
                parcial += sheet[y][x];
                y += 1;
                op += 1;
            }
            if (input[op] == '\n') parcial += sheet[y][x];
        } else if (input[op] == '*') {
            op += 2;
            while (input[op] == ' ') {
                parcial *= sheet[y][x];
                y += 1;
                op += 1;
            }
            if (input[op] == '\n') parcial *= sheet[y][x];
        } else {
            unreachable;
        }
        sum += parcial;
        x += 1;
    }

    return sum;
}
test {
    const input = @embedFile("day6.txt");
    try std.testing.expectEqual(3525371263915, part1(input));
    try std.testing.expectEqual(6846480843636, part2(input));
}
test {
    const input =
        \\123 328  51 64 
        \\ 45 64  387 23 
        \\  6 98  215 314
        \\*   +   *   +  
        \\
    ;
    try std.testing.expectEqual(4277556, part1(input));
    try std.testing.expectEqual(3263827, part2(input));
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
