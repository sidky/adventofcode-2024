const std = @import("std");

const fs = std.fs;
const Allocator = std.mem.Allocator;

const ClawButton = struct {
    x: isize,
    y: isize,
};

const Position = struct {
    x: isize,
    y: isize,
};

const ClawMachine = struct {
    a: ClawButton,
    b: ClawButton,
    prize: Position,
};

fn parseClawButton(line: []const u8) !ClawButton {
    // Button A: X+94, Y+34
    var terms = std.mem.tokenizeScalar(u8, line, ' ');

    _ = terms.next();
    _ = terms.next();
    const x_str = terms.next() orelse unreachable;
    const y_str = terms.next() orelse unreachable;

    std.debug.print("{s} {s}\n", .{ x_str, y_str });

    const x = try std.fmt.parseInt(isize, x_str[2..(x_str.len - 1)], 10);
    const y = try std.fmt.parseInt(isize, y_str[2..], 10);

    return ClawButton{
        .x = x,
        .y = y,
    };
}

fn parsePrize(line: []const u8) !Position {
    var terms = std.mem.tokenizeScalar(u8, line, ' ');

    _ = terms.next();
    const x_str = terms.next() orelse unreachable;
    const y_str = terms.next() orelse unreachable;

    const x = try std.fmt.parseInt(isize, x_str[2..(x_str.len - 1)], 10);
    const y = try std.fmt.parseInt(isize, y_str[2..], 10);

    std.debug.print("Prize at {d}, {d}\n", .{ x, y });

    return Position{
        .x = x + 10000000000000,
        .y = y + 10000000000000,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    _ = allocator;

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day13.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();
    var buf: [1024]u8 = undefined;

    var total_token: isize = 0;

    // while (true) {}
    while (true) {
        const line_a = try reader.readUntilDelimiterOrEof(&buf, '\n');

        if (line_a == null) break;
        const a = try parseClawButton(line_a.?);

        const line_b = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse unreachable;
        const b = try parseClawButton(line_b);

        const line_prize = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse unreachable;
        const prize = try parsePrize(line_prize);

        const D = (a.x * b.y - b.x * a.y);
        const Dx = (prize.x * b.y - b.x * prize.y);
        const Dy = (a.x * prize.y - prize.x * a.y);

        if (D == 0) {
            const j = @min(@divTrunc(prize.x, b.x), @divTrunc(prize.y, b.y));
            const rem_x = prize.x - b.x * j;
            const rem_y = prize.y - b.y * j;

            const i: isize = @min(@divTrunc(rem_x, a.x), @divTrunc(rem_y, a.y));

            if (a.x * i + b.x * j == prize.x and a.y * i + b.y * j == prize.y) {
                total_token += (3 * i + j);
            }
        } else {
            if (@mod(Dx, D) == 0 and @mod(Dy, D) == 0) {
                const i = @divExact(Dx, D);
                const j = @divExact(Dy, D);

                total_token += (3 * i + j);
            }
        }

        const empty = try reader.readUntilDelimiterOrEof(&buf, '\n');

        if (empty == null) {
            break;
        }
    }

    std.debug.print("{d}\n", .{total_token});
}
