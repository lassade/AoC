const Machine = struct { on: u16, buttons: []u16, joltage: []u16 };
var machines: [256]Machine = undefined;
var count: u32 = undefined;
var pool: [8 * 1048]u16 = undefined;
fn parse(input: []const u8) void {
    count = 0;
    var num: u32 = 0;
    var mask: u16 = 0;
    var i: u32 = 0;
    var local: []u16 = pool[0..0];
    var machine: Machine = undefined;
    while (i < input.len) : (i += 1) {
        var ch = input[i];
        switch (ch) {
            '[' => {
                machine.on = 0;
                i += 1;
                num = 0;
                while (true) : (i += 1) {
                    ch = input[i];
                    if (ch == ']') {
                        break;
                    } else if (ch == '#') {
                        machine.on |= @as(u16, 1) << @intCast(num);
                    }
                    num += 1;
                }
                assert(machine.on != 0);
            },
            '(' => {
                i += 1;
                num = 0;
                mask = 0;
                while (true) : (i += 1) {
                    ch = input[i];
                    const digit = ch -% '0';
                    if (digit < 10) {
                        num = num * 10 + digit;
                    } else {
                        mask |= @as(u16, 1) << @intCast(num);
                        num = 0;
                        if (ch == ')') {
                            local.ptr[local.len] = mask;
                            local.len += 1;
                            break;
                        }
                    }
                }
            },
            '{' => {
                // commit buttons
                assert(local.len != 0);
                machine.buttons = local;
                local.ptr += local.len;
                local.len = 0;
                assert(local.ptr - @as([*]u16, &pool) < pool.len);

                i += 1;
                num = 0;
                while (true) : (i += 1) {
                    ch = input[i];
                    const digit = ch -% '0';
                    if (digit < 10) {
                        num = num * 10 + digit;
                    } else {
                        local.ptr[local.len] = @intCast(num);
                        local.len += 1;
                        num = 0;
                        if (ch == '}') break;
                    }
                }
                machine.joltage = local;
                local.ptr += local.len;
                local.len = 0;
                assert(local.ptr - @as([*]u16, &pool) < pool.len);
            },
            '\n' => {
                assert(local.len == 0);
                machines[count] = machine;
                count += 1;
            },
            else => {},
        }
    }
}
pub fn part1() usize {
    var sum: usize = 0;
    for (machines[0..count]) |machine| {
        var min: u16 = 0xffff;
        const combs = @as(usize, 1) << @intCast(machine.buttons.len);
        for (1..combs) |comb| { // comb == 0 means press no buttons
            var num: u16 = 0;
            var state: u16 = 0;
            var mask = comb;
            while (mask != 0) : (mask &= mask - 1) {
                const i = @ctz(mask);
                state ^= machine.buttons[i];
                num += 1;
            }
            if (state == machine.on and num < min) {
                min = num;
            }
        }
        assert(min != 0xffff); // was able to turn in on
        sum += min;
    }
    return sum;
}
// heavly inspired by https://git.tronto.net/aoc/file/2025/10/b.py.html
fn part2() usize {
    var sum: usize = 0;
    var table: [16][16]i32 = undefined;
    var vars: [16]i32 = undefined;
    for (machines[0..count]) |machine| {
        const rows = machine.joltage.len;
        const cols = machine.buttons.len;

        table = @splat(@splat(0)); // todo: optimize
        for (0..cols) |b| {
            var local: u16 = 0xffff;
            var mask = machine.buttons.ptr[b];
            while (mask != 0) : (mask &= mask - 1) {
                const j = @ctz(mask);
                local = @min(local, machine.joltage[j]);
                table[j][b] = 1;
            }
            assert(local != 0xffff);
            table[rows][b] = local;
        }
        for (0..rows) |j| {
            table[j][cols] = machine.joltage[j];
        }

        const rank = gaussElimination(&table, rows, cols);
        const max = table[rows][0..cols];

        var min: i32 = 0x7fff_ffff;
        @memset(vars[rank .. cols + 1], 0);
        while (true) {
            // check awnser
            var valid = true;
            var parcial: i32 = 0;
            for (0..rank) |r| {
                var y: i32 = 0;
                for (rank..cols) |c| {
                    y += vars[c] * table[r][c];
                }
                vars[r] = std.math.divExact(i32, (table[r][cols] - y), table[r][r]) catch -1;
                if (0 <= vars[r] and vars[r] <= max[r]) {
                    parcial += vars[r];
                } else {
                    valid = false;
                    break;
                }
            }
            if (valid) {
                for (rank..cols) |c| parcial += vars[c];
                min = @min(min, parcial);
            }

            // next configuration
            vars[rank] += 1;
            for (rank..cols) |c| {
                if (vars[c] > max[c]) {
                    vars[c] = 0;
                    vars[c + 1] += 1;
                } else {
                    break;
                }
            }
            if (vars[cols] != 0) break; // seached for every valid combination
        }

        assert(min > 0);
        sum += @intCast(min);
    }
    return sum;
}
fn gaussElimination(table: *[16][16]i32, rows: usize, cols: usize) usize {
    var rank = rows;
    for (0..rows) |d| {
        // find a row element at col `c` non zero
        next_row: for (d..rows) |r0| {
            if (table[r0][d] != 0) {
                if (r0 == d) break :next_row;
                // swap rows
                for (0..cols + 1) |c| {
                    const tmp = table[r0][c];
                    table[r0][c] = table[d][c];
                    table[d][c] = tmp;
                }
                break :next_row;
            }
            var c = r0 + 1;
            while (c < cols) : (c += 1) {
                if (table[r0][c] != 0) {
                    if (r0 != d) {
                        // swap rows
                        for (0..cols + 1) |i| {
                            const tmp = table[r0][i];
                            table[r0][i] = table[d][i];
                            table[d][i] = tmp;
                        }
                    }
                    // swap coluns
                    for (0..rows + 1) |r1| {
                        const tmp = table[r1][d];
                        table[r1][d] = table[r1][c];
                        table[r1][c] = tmp;
                    }
                    break :next_row;
                }
            }
        } else {
            rank = d;
            break; // nothing left todo
        }

        const pivot = table[d][0..];
        const x = pivot[d];
        assert(x != 0);
        for (0..rows) |r| {
            if (r == d) continue;
            const row = table[r][0..];
            if (row[d] == 0) continue; // nothing todo
            const y = row[d];
            const div: i32 = @intCast(std.math.gcd(@abs(x), @abs(y)));
            for (0..cols + 1) |c| row[c] = @divExact(row[c] * x - pivot[c] * y, div); // include results
        }
    }
    // print("{d}\n", .{rank});
    // for (0..rows) |j| {
    //     print("{any}\n", .{table[j][0 .. cols + 1]});
    // }
    // print("{any}\n", .{table[rows][0 .. cols + 1]});
    return rank;
}
// pub fn main() !void {
test {
    parse(@embedFile("day10.txt"));
    try std.testing.expectEqual(494, part1());
    try std.testing.expectEqual(19235, part2());
}
test {
    parse(
        \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
        \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
        \\
    );
    assert(count == 3);
    try std.testing.expectEqual(7, part1());
    try std.testing.expectEqual(33, part2());
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
