var fat: struct {
    d: [(1024 * 1024) / 2]usize,
    con: [(1024 * 1024) / 2]usize,
    len: u32,
    pub inline fn lessThan(c: *@This(), a: usize, b: usize) bool {
        return c.d[a] < c.d[b];
    }
    pub inline fn swap(c: *@This(), a: usize, b: usize) void {
        std.mem.swap(usize, &c.d[a], &c.d[b]);
        std.mem.swap(usize, &c.con[a], &c.con[b]);
    }
} = undefined;
pub fn solve(input: []const u8, con_limit: u32) struct { usize, usize } {
    // parse
    var boxes: [3 * 1024]i32 = undefined;
    var count: u32 = 0;
    var num: i32 = 0;
    for (input) |ch| {
        const digit = ch -% '0';
        if (digit < 10) {
            num = num * 10 + digit;
        } else {
            boxes[count] = num;
            count += 1;
            num = 0;
        }
    }
    count = @divExact(count, 3);
    assert(count < 1024);
    // build table
    fat.len = 0;
    for (0..count) |i| {
        const p0: @Vector(3, i32) = boxes[i * 3 ..][0..3].*;
        for (i + 1..count) |j| {
            const p1: @Vector(3, i32) = boxes[j * 3 ..][0..3].*;
            const delta: @Vector(3, isize) = @intCast(p1 - p0);
            assert(i < j);
            fat.d[fat.len] = @intCast(@reduce(.Add, delta * delta));
            fat.con[fat.len] = i << 32 | j;
            fat.len += 1;
        }
    }
    std.sort.pdqContext(0, fat.len, &fat);
    var x_wall: usize = 0;
    // connect
    var ckt: [1024]u32 = undefined;
    @memset(ckt[0..count], 0xffff_ffff);
    var con_rem: usize = 0; // todo: something might be worng
    for (0..fat.len) |i| {
        const con = fat.con[i];
        const a = (con >> 32) & 0xffff_ffff;
        const b = con & 0xffff_ffff;
        assert(a < b);
        // var valid = true;
        var id: u32 = @min(ckt[a], ckt[b]);
        if (id == 0xffff_ffff) {
            id = @intCast(@min(a, b)); // allocate a new id
        } else {
            if (ckt[a] == ckt[b]) {
                // valid = false; // already part of the same ckt
            } else if (ckt[a] == 0xffff_ffff or ckt[b] == 0xffff_ffff) {
                // valid conection reusing the ckt id
            } else {
                std.mem.replaceScalar(u32, ckt[0..count], @max(ckt[a], ckt[b]), id); // merge ckt
            }
        }
        // if (valid) {
        ckt[a] = id;
        ckt[b] = id;
        con_rem += 1;
        if (std.mem.allEqual(u32, ckt[0..count], id)) {
            const x0: isize = boxes[a * 3];
            const x1: isize = boxes[b * 3];
            x_wall = @intCast(x0 * x1);
            con_rem = con_limit; // nothing left to be done
        }
        if (con_rem >= con_limit) break;
        // }
    } else {
        unreachable;
    }
    assert(con_rem == con_limit);

    var len: [1024]u32 = undefined;
    for (0..count) |i| {
        var local: u32 = 1;
        const id = ckt[i];
        if (id != 0xffff_ffff) {
            ckt[i] = 0xffff_ffff;
            for (0..count) |j| {
                if (ckt[j] == id) {
                    local += 1;
                    ckt[j] = 0xffff_ffff;
                }
            }
        }
        len[i] = local;
    }
    std.sort.pdq(u32, len[0..count], {}, std.sort.desc(u32));

    var mul: usize = 1;
    for (0..3) |i| {
        mul *= len[i];
    }

    return .{ mul, x_wall };
}
// pub fn main() !void {
test {
    const input = @embedFile("day8.txt");
    const p1, _ = solve(input, 1000);
    _, const p2 = solve(input, 0xffff_ffff);
    try std.testing.expectEqual(123234, p1);
    try std.testing.expectEqual(9259958565, p2);
}
test {
    const input =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
        \\
    ;
    const p1, _ = solve(input, 10);
    _, const p2 = solve(input, 0xffff_ffff);
    try std.testing.expectEqual(40, p1);
    try std.testing.expectEqual(25272, p2);
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
