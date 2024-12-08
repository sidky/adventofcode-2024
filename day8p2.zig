const std = @import("std");
const fs = std.fs;

const Position = struct {
    r: i32,
    c: i32,
};

fn isValid(p: Position, rows: i32, cols: i32) bool {
    if (p.r < 0 or p.c < 0) return false;

    if (p.r >= rows or p.c >= cols) return false;

    return true;
}

fn contains(haystack: []const Position, needle: Position) bool {
    for (haystack) |h| {
        if (h.r == needle.r and h.c == needle.c) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day8.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [1024]u8 = undefined;

    var antennas = std.AutoHashMap(u8, std.ArrayList(Position)).init(allocator);
    defer {
        var iter = antennas.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
        }
        antennas.deinit();
    }

    var r: usize = 0;
    var cols: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line, 0..) |ch, c| {
            if (ch != '.') {
                var old = antennas.get(ch);

                if (old == null) {
                    var new_list = std.ArrayList(Position).init(allocator);
                    try new_list.append(Position{ .r = @intCast(r), .c = @intCast(c) });
                    try antennas.put(ch, new_list);
                } else {
                    try old.?.append(Position{ .r = @intCast(r), .c = @intCast(c) });
                    try antennas.put(ch, old.?);
                }
            }
        }

        cols = @max(cols, line.len);
        r += 1;
    }

    var antinodes = std.AutoHashMap(Position, struct {}).init(allocator);
    defer antinodes.deinit();

    var it = antennas.iterator();

    const max_rows: i32 = @intCast(r);
    const max_cols: i32 = @intCast(cols);

    while (it.next()) |entry| {
        const nodes = entry.value_ptr.items;

        for (nodes, 0..) |p, i| {
            for (nodes[(i + 1)..]) |q| {
                const dr = q.r - p.r;
                const dc = q.c - p.c;

                var ap1 = Position{ .r = p.r, .c = p.c };

                try antinodes.put(p, .{});
                try antinodes.put(q, .{});

                while (true) {
                    ap1.r -= dr;
                    ap1.c -= dc;

                    if (!isValid(ap1, max_rows, max_cols)) break;

                    std.debug.print("antinode: {d},{d}\n", .{ ap1.r, ap1.c });

                    // if (!contains(nodes, ap1)) {
                    try antinodes.put(ap1, .{});
                    // }
                }

                var ap2 = Position{ .r = q.r, .c = q.c };

                while (true) {
                    ap2.r += dr;
                    ap2.c += dc;

                    if (!isValid(ap2, max_rows, max_cols)) break;
                    std.debug.print("antinode: {d},{d}\n", .{ ap2.r, ap2.c });
                    // if (!contains(nodes, ap2)) {
                    try antinodes.put(ap2, .{});
                    // }
                }
            }
        }
    }

    std.debug.print("{d}\n", .{antinodes.count()});
}
