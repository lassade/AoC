pub fn invalidRangesSumPart1(input: []const u8) usize {
    var sum: usize = 0;
    var temp: [64]u8 = undefined;
    var ranges = std.mem.splitScalar(u8, input, ',');
    while (ranges.next()) |range| {
        const split = std.mem.indexOfScalar(u8, range, '-') orelse break;
        const a = std.fmt.parseInt(usize, range[0..split], 10) catch @panic("NotInt");
        const b = std.fmt.parseInt(usize, range[split + 1 ..], 10) catch @panic("NotInt");
        for (a..b + 1) |id| {
            const num = std.fmt.bufPrint(&temp, "{d}", .{id}) catch @panic("OutOfMemory");
            if (num.len & 1 != 0) continue; // odd sequences can't be invalid
            if (std.mem.eql(u8, num[0 .. num.len / 2], num[num.len / 2 ..])) {
                sum += id;
            }
        }
    }
    return sum;
}
pub fn invalidRangesSumPart2(input: []const u8) usize {
    var sum: usize = 0;
    var temp: [64]u8 = undefined;
    var ranges = std.mem.splitScalar(u8, input, ',');
    while (ranges.next()) |range| {
        const split = std.mem.indexOfScalar(u8, range, '-') orelse break;
        const a = std.fmt.parseInt(usize, range[0..split], 10) catch @panic("NotInt");
        const b = std.fmt.parseInt(usize, range[split + 1 ..], 10) catch @panic("NotInt");
        next_id: for (a..b + 1) |id| {
            const num = std.fmt.bufPrint(&temp, "{d}", .{id}) catch @panic("OutOfMemory");
            const max = num.len / 2 + 1;
            next_seq: for (1..max) |len| {
                const div = std.math.divExact(usize, num.len, len) catch continue;
                if (div == 0) continue;

                var i = len;
                var repeat: usize = 0;
                const seq = num[0..len];
                while (i < num.len) : (i += len) {
                    if (std.mem.eql(u8, seq, num[i..][0..len])) {
                        repeat += 1;
                    } else {
                        continue :next_seq;
                    }
                }
                if (repeat >= 1) {
                    sum += id;
                    continue :next_id;
                }
            }
        }
    }
    return sum;
}
test {
    const input = @embedFile("day2.txt");
    try std.testing.expectEqual(24157613387, invalidRangesSumPart1(input));
    try std.testing.expectEqual(33832678380, invalidRangesSumPart2(input));
}
test {
    const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862";
    try std.testing.expectEqual(1227775554, invalidRangesSumPart1(input));
}
test {
    const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
    try std.testing.expectEqual(4174379265, invalidRangesSumPart2(input));
}
const std = @import("std");
