const std = @import("std");
const queue = @import("queue.zig");
const fs = std.fs;
const Order = std.math.Order;
const Allocator = std.mem.Allocator;

const dr = [_]i32{ -1, 0, 1, 0 };
const dc = [_]i32{ 0, -1, 0, 1 };

const Position = struct { row: usize, col: usize };

const Solver = struct {
    grid: []const []const u8,
    visited: [][]bool,
    allocator: Allocator,

    pub fn new_solver(allocator: Allocator, grid: []const []const u8) !Solver {
        var visited = try allocator.alloc([]bool, grid.len);

        for (0..grid.len) |i| {
            visited[i] = try allocator.alloc(bool, grid[i].len);
            @memset(visited[i], false);
        }

        return Solver{
            .grid = grid,
            .visited = visited,
            .allocator = allocator,
        };
    }

    pub fn deinit(s: *Solver) void {
        for (s.visited) |row| {
            s.allocator.free(row);
        }
        s.allocator.free(s.visited);
    }

    pub fn fenceCost(s: *Solver, r: usize, c: usize) !usize {
        var q = try queue.CircularQueue(Position).init(s.allocator, 100_000);
        defer q.deinit();

        try q.push(Position{
            .row = r,
            .col = c,
        });
        s.visited[r][c] = true;

        var area: usize = 1;
        var perimeter: usize = 0;

        while (!q.isEmpty()) {
            const p = try q.pop();

            for (0..dr.len) |di| {
                if (dr[di] < 0 and p.row == 0) {
                    perimeter += 1;
                    continue;
                }

                if (dc[di] < 0 and p.col == 0) {
                    perimeter += 1;
                    continue;
                }

                const nr: usize = @intCast(@as(i32, @intCast(p.row)) + dr[di]);
                const nc: usize = @intCast(@as(i32, @intCast(p.col)) + dc[di]);

                if (nr >= s.grid.len or nc >= s.grid[nr].len) {
                    perimeter += 1;
                    continue;
                }

                if (s.grid[nr][nc] != s.grid[p.row][p.col]) {
                    perimeter += 1;
                    continue;
                }

                if (s.visited[nr][nc]) continue;

                area += 1;
                s.visited[nr][nc] = true;
                try q.push(Position{
                    .row = nr,
                    .col = nc,
                });
            }
        }

        return area * perimeter;
    }

    pub fn totalFenceCost(s: *Solver) !usize {
        var cost: usize = 0;

        for (0..s.grid.len) |i| {
            for (0..s.grid[i].len) |j| {
                if (!s.visited[i][j]) {
                    cost += try s.fenceCost(i, j);
                }
            }
        }

        return cost;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day12.txt", .{ .mode = fs.File.OpenMode.read_only });
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
        const line_copy = try allocator.alloc(u8, line.len);
        @memcpy(line_copy, line);

        try grid.append(line_copy);
    }

    var solver = try Solver.new_solver(allocator, grid.items);
    defer solver.deinit();

    std.debug.print("{d}\n", .{try solver.totalFenceCost()});
}
