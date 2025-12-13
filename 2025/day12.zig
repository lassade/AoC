const Shape = [3][3]bool;
const ShapeSlot = struct { shape: [8]Shape, volume: u8 };
const Space = struct { size: [2]u8, shapes: [6]u8 };
var shapes: [6]ShapeSlot = undefined;
var spaces: [1024]Space = undefined;
var count: u32 = undefined;
// fn printShape(shape: Shape) void {
//     for (0..3) |y| {
//         for (0..3) |x| print("{c}", .{@as(u8, if (shape[y][x]) '#' else '.')});
//         print("\n", .{});
//     }
//     print("\n", .{});
// }
fn parse(input: []const u8) void {
    count = 0;
    var num: u8 = 0;
    var i: usize = 0;
    while (i < input.len) : (i +%= 1) {
        var ch = input[i];
        if (ch == 'x') {
            i +%= 1;
            var space: Space = undefined;
            space.size[0] = num;

            // height
            num = 0;
            while (i < input.len) : (i +%= 1) {
                ch = input[i];
                const digit = ch -% '0';
                if (digit < 10) {
                    num = num * 10 + digit;
                } else {
                    break;
                }
            }
            space.size[1] = num;

            assert(ch == ':');
            i += 2; // skip space

            num = 0;
            var shape: u8 = 0;
            while (i < input.len) : (i +%= 1) {
                ch = input[i];
                const digit = ch -% '0';
                if (digit < 10) {
                    num = num * 10 + digit;
                } else {
                    space.shapes[shape] = num;
                    shape +%= 1;
                    num = 0;
                    if (ch == '\n') break;
                }
            }
            assert(shape == 6);

            spaces[count] = space;
            count += 1;
            num = 0;
        } else if (ch == ':') {
            i +%= 1;
            var volume: u8 = 0;
            var shape: Shape = undefined;
            var x: u8 = 255;
            var y: u8 = 255;
            while (i < input.len) : (i +%= 1) {
                ch = input[i];
                if (ch == '\n') {
                    x = 0;
                    y +%= 1;
                    if (y == 4) break;
                } else if (ch == '#') {
                    shape[y][x] = true;
                    volume +%= 1;
                    x +%= 1;
                } else if (ch == '.') {
                    shape[y][x] = false;
                    x +%= 1;
                } else {
                    unreachable;
                }
            }

            const slot = &shapes[num];
            slot.volume = volume;
            // note: super cool but not needed for the final solution
            // fliping in both directions account for a 180º rotation
            // // print("cw-90º\n", .{});
            // {
            //     slot.shape[0] = shape;
            //     // printShape(shape);
            //     // abc     gha
            //     // h d ->  f b
            //     // gfe     edc
            //     var rot: Shape = undefined;
            //     rot[0][0] = shape[2][0]; // g
            //     rot[0][1] = shape[1][0]; // h
            //     rot[0][2] = shape[0][0]; // a
            //     rot[1][0] = shape[2][1]; // f
            //     rot[1][1] = shape[1][1];
            //     rot[1][2] = shape[0][1]; // b
            //     rot[2][0] = shape[2][2]; // e
            //     rot[2][1] = shape[1][2]; // d
            //     rot[2][2] = shape[0][2]; // c
            //     slot.shape[1] = rot;
            //     // printShape(rot);
            // }
            // // print("v-flip\n", .{});
            // for (0..2) |j| { // v-flip
            //     shape = slot.shape[j];
            //     const tmp = shape[0];
            //     shape[0] = shape[2];
            //     shape[2] = tmp;
            //     slot.shape[j + 2] = shape;
            //     // printShape(shape);
            // }
            // // print("h-flip\n", .{});
            // for (0..4) |j| { // h-flip
            //     shape = slot.shape[j];
            //     for (0..3) |k| {
            //         const tmp = shape[k][0];
            //         shape[k][0] = shape[k][2];
            //         shape[k][2] = tmp;
            //     }
            //     slot.shape[j + 4] = shape;
            //     // printShape(shape);
            // }

            num = 0;
        } else {
            const digit = ch -% '0';
            if (digit < 10) {
                num = num * 10 + digit;
            } else {
                // todo:
            }
        }
    }
}
fn part1() usize {
    // find valid alternatives for each shape
    // var placeable: [(6 * 8)][(6 * 8)]bool = undefined;
    // for (0..6) |s0| {
    //     const slot0 = shapes[s0];
    //     for (0..6) |s1| {
    //         const slot1 = shapes[s1];
    //         for (0..8) |c0| {
    //             const shape0 = slot0.shape[c0];
    //             for (0..8) |c1| {
    //                 const shape1 = slot1.shape[c1];

    //                 // find the best position to match 2 presents, this means gives the smaller area

    //                 for (0..3) |x| {
    //                     for (0..3) |y| {
    //                         var fit = true;
    //                         const offset: usize = @bitCast(@as(isize, -1));
    //                         const a = y +% offset;
    //                         const b = x +% offset;
    //                         test_fit: for (0..3) |i| {
    //                             for (0..3) |j| {
    //                                 const u = i +% a;
    //                                 const v = j +% b;
    //                                 if (u < 3 and v < 3 and
    //                                     (shape0[i][j] and shape1[u][v]))
    //                                 {
    //                                     fit = false;
    //                                     break :test_fit;
    //                                 }
    //                             }
    //                         }
    //                         if (fit) {
    //                             print("a: ({d}, {d}) b: ({d}, {d}) offset: ({d}, {d})\n", .{ s0, c0, s1, c1, @as(isize, @bitCast(a)), @as(isize, @bitCast(b)) });
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }

    // simple area check
    var sum: usize = 0;
    for (spaces[0..count]) |space| {
        var total_count: usize = 0;
        var total_volume: usize = 0;
        for (space.shapes, 0..) |num, i| {
            total_count += @as(usize, num);
            total_volume += @as(usize, num) * shapes[i].volume;
        }
        const space_volume = @as(usize, space.size[0]) * space.size[1];
        if (total_volume > space_volume) {
            continue; // lowest upper bound
        }
        if (total_count * (3 * 3) > space_volume) {
            unreachable; // needs a complex packing algorithm
        } else {
            // trivially packable
        }

        // var board: [64][64]bool = @splat(@splat(false));

        sum += 1;
    }
    return sum;
}
// well not repesentative of the actuall problem data
// test {
//     parse(
//         \\0:
//         \\###
//         \\##.
//         \\##.
//         \\
//         \\1:
//         \\###
//         \\##.
//         \\.##
//         \\
//         \\2:
//         \\.##
//         \\###
//         \\##.
//         \\
//         \\3:
//         \\##.
//         \\###
//         \\##.
//         \\
//         \\4:
//         \\###
//         \\#..
//         \\###
//         \\
//         \\5:
//         \\###
//         \\.#.
//         \\###
//         \\
//         \\4x4: 0 0 0 0 2 0
//         \\12x5: 1 0 1 0 2 2
//         \\12x5: 1 0 1 0 3 2
//         \\
//     );
//     try std.testing.expectEqual(2, part1());
// }
test {
    parse(@embedFile("day12.txt"));
    try std.testing.expectEqual(569, part1());
}
const assert = std.debug.assert;
const print = std.debug.print;
const std = @import("std");
