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
    id: [][]usize,
    allocator: Allocator,
    area: std.ArrayList(usize),

    global_id: usize = 1, // 0 = not visited

    pub fn new_solver(allocator: Allocator, grid: []const []const u8) !Solver {
        var id = try allocator.alloc([]usize, grid.len);

        for (0..grid.len) |i| {
            id[i] = try allocator.alloc(usize, grid[i].len);
            @memset(id[i], 0);
        }

        return Solver{
            .grid = grid,
            .id = id,
            .allocator = allocator,
            .area = std.ArrayList(usize).init(allocator),
        };
    }

    pub fn deinit(s: *Solver) void {
        for (s.id) |row| {
            s.allocator.free(row);
        }
        s.allocator.free(s.id);
        s.area.deinit();
    }

    fn fenceCost(s: *Solver, r: usize, c: usize) !void {
        var q = try queue.CircularQueue(Position).init(s.allocator, 100_000);
        defer q.deinit();

        try q.push(Position{
            .row = r,
            .col = c,
        });
        const id = s.global_id;
        s.global_id += 1;

        var area: usize = 1;
        s.id[r][c] = id;

        while (!q.isEmpty()) {
            const p = try q.pop();

            for (0..dr.len) |di| {
                if (dr[di] < 0 and p.row == 0) {
                    continue;
                }

                if (dc[di] < 0 and p.col == 0) {
                    continue;
                }

                const nr: usize = @intCast(@as(i32, @intCast(p.row)) + dr[di]);
                const nc: usize = @intCast(@as(i32, @intCast(p.col)) + dc[di]);

                if (nr >= s.grid.len or nc >= s.grid[nr].len) {
                    continue;
                }

                if (s.grid[nr][nc] != s.grid[p.row][p.col]) {
                    continue;
                }

                if (s.id[nr][nc] != 0) continue;

                area += 1;
                s.id[nr][nc] = id;
                try q.push(Position{
                    .row = nr,
                    .col = nc,
                });
            }
        }

        try s.area.append(area);
    }

    pub fn totalFenceCost(s: *Solver) !usize {
        try s.area.append(0);

        // compute area
        for (0..s.grid.len) |i| {
            for (0..s.grid[i].len) |j| {
                if (s.id[i][j] == 0) {
                    try s.fenceCost(i, j);
                }
            }
        }

        const rows = s.grid.len;
        const cols = s.grid[0].len;

        var sides = try s.allocator.alloc(usize, s.global_id);
        defer s.allocator.free(sides);

        @memset(sides, 0);

        // compute sides
        // horizontals
        for (0..(rows + 1)) |i| {
            var top: usize = 0;
            var bottom: usize = 0;

            for (0..cols) |j| {
                const ct = if (i > 0) s.id[i - 1][j] else 0;
                const cb = if (i < rows) s.id[i][j] else 0;

                if (ct != cb) {
                    if (ct != top) {
                        std.debug.print("{d}, {d}: horizontal to {}\n", .{ i, j, ct });
                        sides[ct] += 1;
                    }

                    if (cb != bottom) {
                        std.debug.print("{d}, {d}: horizontal to {}\n", .{ i, j, cb });
                        sides[cb] += 1;
                    }
                    top = ct;
                    bottom = cb;
                } else {
                    top = 0;
                    bottom = 0;
                }
            }
        }

        // verticals
        for (0..(cols + 1)) |j| {
            var left: usize = 0;
            var right: usize = 0;

            for (0..rows) |i| {
                const cl = if (j > 0) s.id[i][j - 1] else 0;
                const cr = if (j < cols) s.id[i][j] else 0;

                if (cl != cr) {
                    if (cl != left) {
                        std.debug.print("{d}, {d}: vertical to {}\n", .{ i, j, cl });
                        sides[cl] += 1;
                    }

                    if (cr != right) {
                        std.debug.print("{d}, {d}: vertical to {}\n", .{ i, j, cr });
                        sides[cr] += 1;
                    }
                    left = cl;
                    right = cr;
                } else {
                    left = 0;
                    right = 0;
                }
            }
        }

        var cost: usize = 0;

        for (1..s.global_id) |id| {
            std.debug.print("{d} {d}\n", .{ s.area.items[id], sides[id] });
            cost += s.area.items[id] * sides[id];
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
