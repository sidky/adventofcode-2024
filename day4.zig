const std = @import("std");
const fs = std.fs;

const xmas = "XMAS";

fn find_xmas(grid: [][]const u8, r: usize, c: usize) u32 {
    var dr: i32 = -1;

    var total: u32 = 0;

    while (dr <= 1) : (dr += 1) {
        var dc: i32 = -1;

        while (dc <= 1) : (dc += 1) {
            if (dr == 0 and dc == 0) continue;

            for (xmas, 0..) |ch, idx| {
                var nr: i32 = @intCast(r);
                var nc: i32 = @intCast(c);

                const m: i32 = @intCast(idx);

                nr += m * dr;
                nc += m * dc;

                if (nr < 0 or nr >= grid.len or nc < 0 or nc >= grid[@intCast(nr)].len) {
                    break;
                }

                if (grid[@intCast(nr)][@intCast(nc)] != ch) {
                    break;
                }

                if (idx + 1 >= xmas.len) {
                    total += 1;
                }
            }
        }
    }

    return total;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day4.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const copied = try allocator.alloc(u8, line.len);
        @memcpy(copied, line);
        try grid.append(copied);
        // std.debug.print("read: {s}\n", .{line});
    }

    const items = grid.items;
    var total: u32 = 0;

    for (0..items.len) |i| {
        for (0..items[i].len) |j| {
            total += find_xmas(items, i, j);
        }
    }

    std.debug.print("{d}\n", .{total});

    for (0..items.len) |idx| {
        allocator.free(items[idx]);
    }
}
