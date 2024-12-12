const std = @import("std");
const queue = @import("queue.zig");
const fs = std.fs;
const Allocator = std.mem.Allocator;

const dr = [_]i32{ -1, 0, 1, 0 };
const dc = [_]i32{ 0, -1, 0, 1 };

const Position = struct { row: usize, col: usize };

const Solver = struct {
    const Self = @This();

    grid: []const []const u8,

    fn score(self: *Self, r: usize, c: usize) !usize {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const allocator = gpa.allocator();

        var visited = try allocator.alloc([]bool, self.grid.len);
        for (0..self.grid.len) |rindex| {
            visited[rindex] = try allocator.alloc(bool, self.grid[rindex].len);
        }
        defer {
            for (visited) |row| {
                allocator.free(row);
            }
            allocator.free(visited);
        }

        var q: queue.CircularQueue(Position) = try queue.CircularQueue(Position).init(allocator, 1000);
        defer q.deinit();
        const start = Position{ .row = r, .col = c };
        try q.push(start);

        var total_score: usize = 0;

        while (!q.isEmpty()) {
            const curr = try q.pop();

            const cs = self.grid[curr.row][curr.col];

            if (cs == '9') {
                total_score += 1;
                continue;
            }

            for (0..dr.len) |di| {
                if (dr[di] < 0 and curr.row == 0) continue;
                if (dc[di] < 0 and curr.col == 0) continue;
                if (dr[di] > 0 and curr.row + 1 >= self.grid.len) continue;
                if (dc[di] > 0 and curr.col + 1 >= self.grid[curr.row].len) continue;

                const next = Position{ .row = @intCast(@as(i32, @intCast(curr.row)) + dr[di]), .col = @intCast(@as(i32, @intCast(curr.col)) + dc[di]) };

                const cn = self.grid[next.row][next.col];

                if (cn == cs + 1 and !visited[next.row][next.col]) {
                    visited[next.row][next.col] = true;
                    try q.push(next);
                }
            }
        }

        return total_score;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day10.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [20001]u8 = undefined;

    var grid = std.ArrayList([]const u8).init(allocator);
    defer {
        for (grid.items) |line| {
            allocator.free(line);
        }
        grid.deinit();
    }

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const copy = try allocator.alloc(u8, line.len);
        @memcpy(copy, line);

        try grid.append(copy);
    }

    for (grid.items) |item| {
        std.debug.print("{s}\n", .{item});
    }

    var solver = Solver{ .grid = grid.items };
    var score: usize = 0;

    for (grid.items, 0..) |item, i| {
        for (item, 0..) |c, j| {
            if (c == '0') {
                score += try solver.score(i, j);
            }
        }
    }

    std.debug.print("{d}\n", .{score});
}
