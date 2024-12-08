const std = @import("std");
const fs = std.fs;

const xmas = "XMAS";

fn isXmas(grid: [][]const u8, r1: i32, c1: i32, r2: i32, c2: i32) bool {
    if (r1 < 0 or r1 >= grid.len or c1 < 0 or c1 >= grid[@intCast(r1)].len) return false;
    if (r2 < 0 or r2 >= grid.len or c2 < 0 or c2 >= grid[@intCast(r2)].len) return false;

    const ch1 = grid[@intCast(r1)][@intCast(c1)];
    const ch2 = grid[@intCast(r2)][@intCast(c2)];

    return (ch1 == 'M' and ch2 == 'S') or (ch2 == 'M' and ch1 == 'S');
}

fn findXmas(grid: [][]const u8, r: usize, c: usize) u32 {
    const nr: i32 = @intCast(r);
    const nc: i32 = @intCast(c);

    if (grid[r][c] != 'A') return 0;

    return if (isXmas(grid, nr - 1, nc - 1, nr + 1, nc + 1) and isXmas(grid, nr - 1, nc + 1, nr + 1, nc - 1)) 1 else 0;
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
            total += findXmas(items, i, j);
        }
    }

    std.debug.print("{d}\n", .{total});

    for (0..items.len) |idx| {
        allocator.free(items[idx]);
    }
}
