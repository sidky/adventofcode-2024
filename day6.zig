const std = @import("std");
const fs = std.fs;

const Position = struct { r: usize, c: usize };
const Direction = struct { r: i4, c: i4 };

const dir = [_]Direction{
    Direction{ .r = -1, .c = 0 },
    Direction{ .r = 0, .c = 1 },
    Direction{ .r = 1, .c = 0 },
    Direction{ .r = 0, .c = -1 },
};

const State = struct { p: Position, dir: u4 };

fn find_guard(grid: [][]const u8) !Position {
    for (grid, 0..) |line, r| {
        for (line, 0..) |ch, c| {
            if (ch == '^') {
                return Position{ .r = r, .c = c };
            }
        }
    }
    unreachable;
}

fn simulate(grid: [][]const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const allocator = gpa.allocator();
    var position = try find_guard(grid);
    var direction: u8 = 0;
    var visited = std.AutoHashMap(Position, struct {}).init(allocator);
    defer visited.deinit();

    while (true) {
        try visited.put(position, .{});
        const d = dir[direction];

        if ((d.r < 0 and position.r == 0) or (d.r > 0 and position.r + 1 >= grid.len)) break;
        if ((d.c < 0 and position.c == 0) or (d.c > 0 and position.c + 1 >= grid[position.r].len)) break;

        var new_r: i32 = @intCast(position.r);
        new_r += d.r;
        var new_c: i32 = @intCast(position.c);
        new_c += d.c;

        const new_pos = Position{ .r = @as(usize, @intCast(new_r)), .c = @as(usize, @intCast(new_c)) };

        if (grid[new_pos.r][new_pos.c] == '#') {
            direction = (direction + 1) % 4;
        } else {
            position = new_pos;
        }
    }

    return visited.count();
}

pub fn main() !void {
    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day6.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();

    var grid = std.ArrayList([]const u8).init(allocator);
    defer {
        for (grid.items) |line| {
            allocator.free(line);
        }
        grid.deinit();
    }

    var buf: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const grid_line = try allocator.alloc(u8, line.len);

        @memcpy(grid_line, line);

        try grid.append(grid_line[0..]);
    }

    for (grid.items) |line| {
        std.debug.print("{s}\n", .{line});
    }

    const total = try simulate(grid.items);

    std.debug.print("{d}\n", .{total});
}
