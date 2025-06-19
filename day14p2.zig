const std = @import("std");

const fs = std.fs;
const Allocator = std.mem.Allocator;

const Pair = struct {
    first: isize,
    second: isize,
};

const Width = 101;
const Height = 103;

pub fn parsePair(string: []const u8) !Pair {
    var parts = std.mem.tokenizeScalar(u8, string, ',');

    const first = try std.fmt.parseInt(isize, parts.next() orelse unreachable, 10);
    const second = try std.fmt.parseInt(isize, parts.next() orelse unreachable, 10);

    return Pair{
        .first = first,
        .second = second,
    };
}

const Quadrant = enum { TopLeft, TopRight, BottomLeft, BottomRight, None };

var grid: [103][101]u8 = undefined;

pub fn clearGrid() void {
    for (0..grid.len) |i| {
        for (0..grid[i].len) |j| {
            grid[i][j] = ' ';
        }
    }
}

fn printGrid() void {
    for (grid) |row| {
        std.debug.print("{s}\n", .{row});
    }
}

pub fn place(position: Pair, seconds: isize, velocity: Pair) void {
    const final_x: usize = @intCast(@mod(position.first + seconds * velocity.first, Width));
    const final_y: usize = @intCast(@mod(position.second + seconds * velocity.second, Height));

    grid[final_y][final_x] = 'X';

    // std.debug.print("{d},{d} w/ {d},{d} => {d},{d}\n", .{ position.first, position.second, velocity.first, velocity.second, final_x, final_y });

    // return if (final_x < @divTrunc(Width, 2) and final_y < @divTrunc(Height, 2)) Quadrant.TopLeft else if (final_x < @divTrunc(Width, 2) and final_y > @divTrunc(Height, 2)) Quadrant.TopRight else if (final_x > @divTrunc(Width, 2) and final_y < @divTrunc(Height, 2)) Quadrant.BottomLeft else if (final_x > @divTrunc(Width, 2) and final_y > @divTrunc(Height, 2)) Quadrant.BottomRight else Quadrant.None;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day14.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [1024]u8 = undefined;

    var positions = std.ArrayList(Pair).init(allocator);
    defer positions.deinit();

    var velocities = std.ArrayList(Pair).init(allocator);
    defer velocities.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ' ');

        const position = try parsePair((parts.next() orelse unreachable)[2..]);
        const velocity = try parsePair((parts.next() orelse unreachable)[2..]);

        try positions.append(position);
        try velocities.append(velocity);
    }

    var T: isize = 0;
    const stdin = std.io.getStdIn().reader();

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |ln| {
        const p = std.fmt.parseInt(isize, ln, 10) catch -1;

        if (p >= 0) {
            T = p;
        }
        clearGrid();
        for (0..positions.items.len) |i| {
            place(positions.items[i], T, velocities.items[i]);
        }
        printGrid();
        std.debug.print("Time: {d}\n", .{T});
        T += 1;
    }

    // std.debug.print("{d}\n", .{m});
}
