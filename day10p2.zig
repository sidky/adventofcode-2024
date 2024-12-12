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
    cache: [][]i32,
    allocator: Allocator,

    pub fn deinit(self: *Self) void {
        for (0..self.cache.len) |r| {
            self.allocator.free(self.cache[r]);
        }
        self.allocator.free(self.cache);
    }

    pub fn score(self: *Self, r: usize, c: usize) !usize {
        if (self.cache[r][c] >= 0) return @intCast(self.cache[r][c]);
        if (self.grid[r][c] == '9') return 1;

        self.cache[r][c] = 0;
        const cs = self.grid[r][c];

        for (0..dr.len) |di| {
            if (dr[di] < 0 and r == 0) continue;
            if (dc[di] < 0 and c == 0) continue;
            if (dr[di] > 0 and r + 1 >= self.grid.len) continue;
            if (dc[di] > 0 and c + 1 >= self.grid[r].len) continue;

            const nr: usize = @intCast(@as(i32, @intCast(r)) + dr[di]);
            const nc: usize = @intCast(@as(i32, @intCast(c)) + dc[di]);

            const cn = self.grid[nr][nc];

            if (cn == cs + 1) {
                self.cache[r][c] += @as(i32, @intCast(try self.score(nr, nc)));
            }
        }

        return @intCast(self.cache[r][c]);
    }
};
pub fn newSolver(allocator: Allocator, grid: []const []const u8) !Solver {
    var cache = try allocator.alloc([]i32, grid.len);

    for (0..grid.len) |r| {
        cache[r] = try allocator.alloc(i32, grid[r].len);

        for (0..cache[r].len) |c| {
            cache[r][c] = -1;
        }
    }

    return Solver{
        .grid = grid,
        .cache = cache,
        .allocator = allocator,
    };
}

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

    var solver: Solver = try newSolver(allocator, grid.items);
    defer solver.deinit();

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
