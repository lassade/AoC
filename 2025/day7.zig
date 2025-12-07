const Beans = struct {
    x: [128]usize = undefined,
    t: [128]usize = undefined,
    count: usize = 0,
    pub fn add(b: *@This(), pos: usize) usize {
        if (b.find(pos)) |i| {
            return i;
        } else {
            const i = b.count;
            b.x[i] = pos;
            b.t[i] = 0;
            b.count += 1;
            return i;
        }
    }
    pub fn remove(b: *@This(), i: usize) void {
        const last = b.count - 1;
        b.x[i] = b.x[last];
        b.t[i] = b.t[last];
        b.count -= 1;
    }
    pub fn find(b: *const @This(), pos: usize) ?usize {
        return std.mem.indexOfScalar(usize, b.x[0..b.count], pos);
    }
};
pub fn part1(input: []const u8) usize {
    var i: usize = 0;
    var x: u32 = 0;
    var y: u32 = 0;
    var beams = Beans{};
    var num_splits: usize = 0;
    while (i < input.len) {
        if (input[i] == '\n') {
            x = 0xffff_ffff;
            y += 1;
        } else if (input[i] == 'S') {
            assert(beams.count == 0);
            _ = beams.add(x);
        } else if (input[i] == '^') {
            if (beams.find(x)) |s| {
                beams.remove(s);
                _ = beams.add(x - 1);
                _ = beams.add(x + 1);
                num_splits += 1;
            } else {
                // does nothing
            }
        }
        i += 1;
        x +%= 1;
    }
    return num_splits;
}
pub fn part2(input: []const u8) usize {
    var i: usize = 0;
    var x: u32 = 0;
    var y: u32 = 0;
    var beams = Beans{};
    while (i < input.len) {
        if (input[i] == '\n') {
            x = 0xffff_ffff;
            y += 1;
        } else if (input[i] == 'S') {
            assert(beams.count == 0);
            _ = beams.add(x);
            beams.t[0] = 1;
        } else if (input[i] == '^') {
            if (beams.find(x)) |s| {
                const t = beams.t[s];
                beams.remove(s);
                beams.t[beams.add(x - 1)] += t;
                beams.t[beams.add(x + 1)] += t;
            } else {
                // does nothing
            }
        }
        i += 1;
        x +%= 1;
    }
    var timelines: usize = 0;
    for (beams.t[0..beams.count]) |t| timelines += t;
    return timelines;
}
test {
    const input = @embedFile("day7.txt");
    try std.testing.expectEqual(1658, part1(input));
    try std.testing.expectEqual(53916299384254, part2(input));
}
// pub fn main() !void {
test {
    const input =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;
    try std.testing.expectEqual(21, part1(input));
    try std.testing.expectEqual(40, part2(input));
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
