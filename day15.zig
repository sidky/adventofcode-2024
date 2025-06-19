const std = @import("std");

const fs = std.fs;
const Allocator = std.mem.Allocator;

const dr = [_]isize{ -1, 0, 1, 0 };
const dc = [_]isize{ 0, -1, 0, 1 };
const ds = [_]u8{ '^', '<', 'v', '>' };

const Position = struct {
    r: usize,
    c: usize,

    fn move(p: *Position, rows: usize, cols: usize, dfr: isize, dfc: isize) ?Position {
        if (p.r == 0 and dfr < 0) return null;
        if (p.c == 0 and dfc < 0) return null;

        const nr: usize = @intCast(@as(isize, @intCast(p.r)) + dfr);
        const nc: usize = @intCast(@as(isize, @intCast(p.c)) + dfc);

        if (nr >= rows or nc >= cols) return null;

        return Position{
            .r = nr,
            .c = nc,
        };
    }
};

const Simulator = struct {
    grid: [][]u8,
    robot: Position,

    fn apply(s: *Simulator, move: u8) void {
        var i: usize = 0;

        while (i < 4) : (i += 1) {
            if (ds[i] == move) break;
        }

        const np = s.robot.move(s.grid.len, s.grid[0].len, dr[i], dc[i]) orelse return;
        if (s.grid[np.r][np.c] == '#') return;

        var mp = np;

        while (true) {
            if (s.grid[mp.r][mp.c] == '.') {
                break;
            } else if (s.grid[mp.r][mp.c] == '#') {
                return;
            }

            mp = mp.move(s.grid.len, s.grid[0].len, dr[i], dc[i]) orelse return;
        }

        s.grid[mp.r][mp.c] = s.grid[np.r][np.c];
        s.grid[np.r][np.c] = '.';
        s.robot = np;
    }

    fn gpsSum(s: Simulator) usize {
        var sum: usize = 0;
        for (s.grid, 0..) |row, r| {
            for (row, 0..) |state, c| {
                if (state == 'O') {
                    sum += 100 * r + c;
                }
            }
        }

        return sum;
    }

    fn printGrid(s: Simulator) void {
        for (s.grid) |row| {
            std.debug.print("{s}\n", .{row});
        }
    }
};

fn newSimulator(grid: [][]u8) Simulator {
    var nr: usize = 0;
    var nc: usize = 0;

    robot_position: while (nr < grid.len) : (nr += 1) {
        nc = 0;

        while (nc < grid[nr].len) : (nc += 1) {
            if (grid[nr][nc] == '@') {
                grid[nr][nc] = '.';

                break :robot_position;
            }
        }
    }

    return Simulator{ .grid = grid, .robot = Position{
        .r = nr,
        .c = nc,
    } };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day15.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [25000]u8 = undefined;

    var grid = std.ArrayList([]u8).init(allocator);
    defer {
        for (grid.items) |item| {
            allocator.free(item);
        }
        grid.deinit();
    }

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) break;

        const row = try allocator.alloc(u8, line.len);
        @memcpy(row, line);

        try grid.append(row);
    }

    var s = newSimulator(grid.items);

    const moves = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;

    for (grid.items) |r| {
        std.debug.print("{s}\n", .{r});
    }

    for (moves) |m| {
        s.apply(m);
        // s.printGrid();
    }
    std.debug.print("{d}\n", .{s.gpsSum()});
}
