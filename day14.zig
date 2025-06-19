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

pub fn quadrant(position: Pair, seconds: isize, velocity: Pair) Quadrant {
    const final_x = @mod(position.first + seconds * velocity.first, Width);
    const final_y = @mod(position.second + seconds * velocity.second, Height);

    std.debug.print("{d},{d} w/ {d},{d} => {d},{d}\n", .{ position.first, position.second, velocity.first, velocity.second, final_x, final_y });

    return if (final_x < @divTrunc(Width, 2) and final_y < @divTrunc(Height, 2)) Quadrant.TopLeft else if (final_x < @divTrunc(Width, 2) and final_y > @divTrunc(Height, 2)) Quadrant.TopRight else if (final_x > @divTrunc(Width, 2) and final_y < @divTrunc(Height, 2)) Quadrant.BottomLeft else if (final_x > @divTrunc(Width, 2) and final_y > @divTrunc(Height, 2)) Quadrant.BottomRight else Quadrant.None;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    _ = allocator;

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day14.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [1024]u8 = undefined;
    var guards = [1]usize{0} ** 5;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ' ');

        const position = try parsePair((parts.next() orelse unreachable)[2..]);
        const velocity = try parsePair((parts.next() orelse unreachable)[2..]);

        std.debug.print("position {d}, {d} w/ velocity {d}, {d}\n", .{ position.first, position.second, velocity.first, velocity.second });

        const q = quadrant(position, 100, velocity);

        if (q != Quadrant.None) {
            guards[@intFromEnum(q)] += 1;
        }
    }
    var m: usize = 1;

    for (0..4) |i| {
        std.debug.print("quadrant: {d}: {d}\n", .{ i, guards[i] });
        m *= guards[i];
    }

    std.debug.print("{d}\n", .{m});
}
