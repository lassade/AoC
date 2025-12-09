var coords: [8 * 1024]i32 = undefined;
var count: usize = 0;
fn parse(input: []const u8) void {
    count = 0;
    var num: i32 = 0;
    for (input) |ch| {
        const digit = ch -% '0';
        if (digit < 10) {
            num = num * 10 + digit;
        } else {
            coords[count] = num;
            count += 1;
            num = 0;
        }
    }
    count = @divExact(count, 2);
}
pub fn part1(input: []const u8) usize {
    parse(input);
    var big: isize = 0;
    for (0..count) |i| {
        const p0: @Vector(2, i32) = coords[i * 2 ..][0..2].*;
        for (i + 1..count) |j| {
            const p1: @Vector(2, i32) = coords[j * 2 ..][0..2].*;
            const min = @min(p0, p1);
            const max = @max(p0, p1);
            var size: @Vector(2, isize) = @intCast(max - min);
            size += @splat(1);
            const local = size[0] * size[1];
            if (big < local) big = local;
        }
    }
    return @intCast(big);
}
pub fn part2(input: []const u8) usize {
    parse(input);
    assert(count > 4);

    // add hole points
    var holes = count;
    for (0..count) |i| {
        const j = @mod(i + 1, count);
        const k = @mod(i + 2, count);
        const pbegin: @Vector(2, i32) = coords[i * 2 ..][0..2].*;
        const p: @Vector(2, i32) = coords[j * 2 ..][0..2].*;
        const pend: @Vector(2, i32) = coords[k * 2 ..][0..2].*;
        const v = pend - pbegin;
        const u = p - pbegin;
        const cross = (v[0] * u[1]) - (v[1] * u[0]); // 2d cross product
        if (cross > 0) {
            // ccw
            var mid = (pbegin + pend);
            mid /= @splat(2);
            coords[holes * 2] = mid[0];
            coords[holes * 2 + 1] = mid[1];
            holes += 1;
        } else {
            // cw
        }
    }

    var big: isize = 0;
    for (0..count) |i| {
        for (i + 1..count) |j| {
            const p0: @Vector(2, i32) = coords[i * 2 ..][0..2].*;
            const p1: @Vector(2, i32) = coords[j * 2 ..][0..2].*;
            const min = @min(p0, p1);
            const max = @max(p0, p1);

            // must not contain any other point, including (excluding the edge)
            var valid = true;
            for (0..holes) |k| {
                if (i == k or j == k) continue;
                const p: @Vector(2, i32) = coords[k * 2 ..][0..2].*;
                if (min[0] < p[0] and p[0] < max[0] and
                    min[1] < p[1] and p[1] < max[1])
                {
                    valid = false;
                    break;
                }
            }

            if (valid) {
                var size: @Vector(2, isize) = @intCast(max - min);
                size += @splat(1);
                const local = size[0] * size[1];
                if (big < local) big = local;
            }
        }
    }

    return @intCast(big);
}
test {
    const input = @embedFile("day9.txt");
    try std.testing.expectEqual(4777816465, part1(input));
    try std.testing.expectEqual(1410501884, part2(input));
}
// pub fn main() !void {
test {
    const input =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
        \\
    ;
    try std.testing.expectEqual(50, part1(input));
    try std.testing.expectEqual(24, part2(input));
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
