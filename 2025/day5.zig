pub fn part1(input: []const u8) usize {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var range_buffer: [256][2]usize = undefined;
    var ranges: [][2]usize = range_buffer[0..0];
    // ranges
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const dash = std.mem.indexOfScalar(u8, line, '-') orelse @panic("InvalidRange");
        const a = std.fmt.parseInt(usize, line[0..dash], 10) catch @panic("BadInt");
        const b = std.fmt.parseInt(usize, line[dash + 1 ..], 10) catch @panic("BadInt");
        std.debug.assert(a <= b);
        ranges.ptr[ranges.len] = .{ a, b };
        ranges.len += 1;
    }
    // // faster lookup times
    // std.sort.pdq([2]usize, ranges, {}, struct {
    //     fn lt(_: void, a: [2]usize, b: [2]usize) bool {
    //         return a[0] < b[0];
    //     }
    // }.lt);
    // ingredients
    var sum: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) break;

        const id = std.fmt.parseInt(usize, line, 10) catch @panic("BadInt");

        // doesn't work with overlaping ranges
        // var index = std.sort.partitionPoint([2]usize, ranges, id, struct {
        //     fn p(local_id: usize, r: [2]usize) bool {
        //         return r[0] < local_id;
        //     }
        // }.p);
        // index -|= 1;
        // for (ranges[index..]) |r| {
        //     if (r[0] <= id and id <= r[1]) {
        //         sum += 1;
        //         break;
        //     } else if (id > r[0]) {
        //         break;
        //     }
        // }

        // fast enough
        for (ranges) |r| {
            if (r[0] <= id and id <= r[1]) {
                sum += 1;
                break;
            }
        }
    }
    return sum;
}
pub fn part2(input: []const u8) usize {
    var sum: usize = 0;
    var lines = std.mem.splitScalar(u8, input, '\n');
    var range_buffer: [256][2]usize = undefined;
    var ranges: [][2]usize = range_buffer[0..0];
    // ranges
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const dash = std.mem.indexOfScalar(u8, line, '-') orelse @panic("InvalidRange");
        const a = std.fmt.parseInt(usize, line[0..dash], 10) catch @panic("BadInt");
        const b = std.fmt.parseInt(usize, line[dash + 1 ..], 10) catch @panic("BadInt");
        std.debug.assert(a <= b);
        ranges.ptr[ranges.len] = .{ a, b };
        ranges.len += 1;
    }
    std.sort.pdq([2]usize, ranges, {}, struct {
        fn lt(_: void, a: [2]usize, b: [2]usize) bool {
            return a[0] < b[0]; // and a[1] < b[1];
        }
    }.lt);
    // smart
    var max: usize = 0;
    for (ranges) |r| {
        if (max < r[0]) {
            // no overlap
            sum += r[1] - r[0] + 1;
            max = r[1];
        } else if (r[1] > max) {
            // overlap
            sum += r[1] - max;
            max = r[1];
        } else {
            // overlap (already counted)
        }
    }
    // for (ranges) |r| std.debug.print("{d}-{d}\n", .{ r[0], r[1] });

    return sum;
}
test {
    const input = @embedFile("day5.txt");
    try std.testing.expectEqual(661, part1(input)); // dumb: 661, smart: 634
    try std.testing.expectEqual(359526404143208, part2(input)); // smart: 359526404143208
}
test {
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;
    try std.testing.expectEqual(3, part1(input));
    try std.testing.expectEqual(14, part2(input));
}
const std = @import("std");
