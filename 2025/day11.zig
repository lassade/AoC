var names: [1024]u32 = undefined;
var nodes: [1024][1024]bool = undefined;
var count: u32 = undefined;
fn parse(input: []const u8) void {
    count = 0;
    nodes = @splat(@splat(false));
    var name: u32 = 0;
    var i: usize = 0;
    var parent: usize = 0xffff_ffff;
    while (i < input.len) : (i += 1) {
        const ch = input[i];
        if (ch == ':' or ch == ' ' or ch == '\n') {
            if (name == 0) continue;
            name = @byteSwap(name << 8);
            const index = std.mem.indexOfScalar(u32, names[0..count], name) orelse add: {
                names[count] = name;
                count += 1;
                break :add count - 1;
            };
            if (ch == ':') {
                parent = index;
            } else {
                nodes[parent][index] = true;
            }
            name = 0;
        } else {
            name = (name << 8) | ch;
        }
    }
}
pub fn part1() usize {
    const V = struct {
        var paths: usize = undefined;
        var out: usize = undefined;
        fn visit(node: usize) void {
            for (0..count) |i| {
                if (nodes[node][i]) {
                    if (i == out) {
                        paths += 1;
                        return; // reached destination
                    }
                    visit(i); // follow connections
                }
            }
        }
    };
    V.paths = 0;
    V.out = std.mem.indexOfScalar(u32, names[0..count], @bitCast("out".*)) orelse @panic("out");
    V.visit(std.mem.indexOfScalar(u32, names[0..count], @bitCast("you".*)) orelse @panic("you"));
    return V.paths;
}
pub fn part2() usize {
    const svr: u16 = @intCast(std.mem.indexOfScalar(u32, names[0..count], @bitCast("svr".*)) orelse @panic("svr"));
    const fft: u16 = @intCast(std.mem.indexOfScalar(u32, names[0..count], @bitCast("fft".*)) orelse @panic("fft"));
    const dac: u16 = @intCast(std.mem.indexOfScalar(u32, names[0..count], @bitCast("dac".*)) orelse @panic("dac"));
    const out: u16 = @intCast(std.mem.indexOfScalar(u32, names[0..count], @bitCast("out".*)) orelse @panic("out"));

    const v = struct {
        // https://www.reddit.com/r/adventofcode/comments/1pjp1rm/comment/ntk8lzs/
        var cache: [1024][1024]u64 = undefined;
        fn walk(node: u16, target: u16) u64 {
            var temp: u64 = cache[node][target];
            if (temp == 0xffff_ffff_ffff_ffff) {
                temp = 0;
                for (0..count) |i| {
                    if (nodes[node][i]) {
                        if (i == target) {
                            temp = 1;
                            break;
                        }
                        temp += walk(@intCast(i), target); // follow connections
                    }
                }
                cache[node][target] = temp;
            }
            return temp;
        }
    };
    v.cache = @splat(@splat(0xffff_ffff_ffff_ffff));

    var sum: usize = 0;
    sum += v.walk(svr, fft) * v.walk(fft, dac) * v.walk(dac, out);
    sum += v.walk(svr, dac) * v.walk(dac, fft) * v.walk(fft, out);

    return sum;
}
test {
    parse(
        \\aaa: you hhh
        \\you: bbb ccc
        \\bbb: ddd eee
        \\ccc: ddd eee fff
        \\ddd: ggg
        \\eee: out
        \\fff: out
        \\ggg: out
        \\hhh: ccc fff iii
        \\iii: out
        \\
    );
    try std.testing.expectEqual(5, part1());

    parse(
        \\svr: aaa bbb
        \\aaa: fft
        \\fft: ccc
        \\bbb: tty
        \\tty: ccc
        \\ccc: ddd eee
        \\ddd: hub
        \\hub: fff
        \\eee: dac
        \\dac: fff
        \\fff: ggg hhh
        \\ggg: out
        \\hhh: out
        \\
    );
    try std.testing.expectEqual(2, part2());
}
// pub fn main() !void {
test {
    parse(@embedFile("day11.txt"));
    try std.testing.expectEqual(603, part1());
    try std.testing.expectEqual(380961604031372, part2());
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
