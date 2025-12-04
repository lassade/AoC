pub fn maxJoltageSum(input: []const u8, battery_count: usize) usize {
    var sum: usize = 0;
    var banks = std.mem.splitScalar(u8, input, '\n');
    while (banks.next()) |bank| {
        if (bank.len == 0) break;

        var max: usize = 0;
        var rem: usize = 0;
        var lower: usize = undefined;

        var reserve = bank.len - (battery_count - 1);
        for (0..battery_count - 1) |_| {
            lower = 0;
            for (rem..reserve) |index| {
                if (bank[index] > lower) {
                    lower = bank[index];
                    rem = index + 1;
                }
            }
            max += (lower - '0');
            max *= 10;
            reserve += 1;
        }

        lower = 0;
        for (rem..bank.len) |index| {
            if (bank[index] > lower) lower = bank[index];
        }
        max += (lower - '0');

        // std.debug.print("{s}: {d}\n", .{ bank, max });
        sum += max;
    }
    return sum;
}
test {
    const input = @embedFile("day3.txt");
    try std.testing.expectEqual(17412, maxJoltageSum(input, 2));
    try std.testing.expectEqual(172681562473501, maxJoltageSum(input, 12));
}
test {
    const input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;
    try std.testing.expectEqual(357, maxJoltageSum(input, 2));
    try std.testing.expectEqual(3121910778619, maxJoltageSum(input, 12));
    // try std.testing.expectEqual(0, maxJoltageSum("123456789123111111", 12));
}
const std = @import("std");
