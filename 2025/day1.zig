pub fn decodePass(pos: i32, input: []const u8) u32 {
    var pass: u32 = 0;
    var dial: i32 = pos;
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var rot = std.fmt.parseInt(i32, line[1..], 10) catch @panic("NotInt");

        // 5161 < x < 6272

        const turns = @divFloor(rot, 100);
        rot -= turns * 100;
        // pass += @intCast(turns);

        if (line[0] == 'R') {
            dial += rot;
            if (dial >= 100) {
                dial -= 100;
                // pass += 1;
            }
        } else {
            dial -= rot;
            if (dial < 0) {
                dial += 100;
                // pass += 1;
            }
        }
        // std.debug.print("{s}: {d}\n", .{ line, dial });
        if (dial == 0) pass += 1;
    }
    return pass;
}
pub fn decodePass0x434C49434B(pos: i32, input: []const u8) u32 {
    var pass: u32 = 0;
    var dial: i32 = pos;
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var rot = std.fmt.parseInt(i32, line[1..], 10) catch @panic("NotInt");

        // dumb way (works)
        // if (line[0] == 'R') {
        //     for (0..rot) |_| {
        //         dial += 1;
        //         if (dial == 0) {
        //             pass += 1;
        //         } else if (dial >= 100) {
        //             dial -= 100;
        //             pass += 1; // goes back to 0
        //         }
        //     }
        // } else {
        //     for (0..rot) |_| {
        //         dial -= 1;
        //         if (dial == 0) {
        //             pass += 1;
        //         } else if (dial < 0) {
        //             dial += 100;
        //         }
        //     }
        // }

        // smart way
        const turns = @divFloor(rot, 100);
        rot -= turns * 100;
        pass += @intCast(turns);
        if (line[0] == 'R') {
            dial += rot;
            if (dial >= 100) {
                dial -= 100;
                pass += 1;
            }
        } else {
            const not_zero = dial > 0;
            dial -= rot;
            if (dial < 0) {
                dial += 100;
                if (not_zero) pass += 1; // crosses zero
            } else if (dial == 0) {
                pass += 1;
            }
        }

        std.debug.assert(0 <= dial and dial < 100);
        // std.debug.print("{s}: {d}\n", .{ line, dial });
    }
    return pass;
}
test {
    const input = @embedFile("day1.txt");
    try std.testing.expectEqual(1074, decodePass(50, input));
    try std.testing.expectEqual(6254, decodePass0x434C49434B(50, input));
}
test {
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    try std.testing.expectEqual(3, decodePass(50, input));
    try std.testing.expectEqual(6, decodePass0x434C49434B(50, input));
}
const std = @import("std");
