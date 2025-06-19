const std = @import("std");

const fs = std.fs;
const Allocator = std.mem.Allocator;

const ClawButton = struct {
    x: usize,
    y: usize,
};

const Position = struct {
    x: usize,
    y: usize,
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

    const x = try std.fmt.parseInt(usize, x_str[2..(x_str.len - 1)], 10);
    const y = try std.fmt.parseInt(usize, y_str[2..], 10);

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

    const x = try std.fmt.parseInt(usize, x_str[2..(x_str.len - 1)], 10);
    const y = try std.fmt.parseInt(usize, y_str[2..], 10);

    std.debug.print("Prize at {d}, {d}\n", .{ x, y });

    return Position{
        .x = x,
        .y = y,
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

    var total_token: usize = 0;

    // while (true) {}
    while (true) {
        const line_a = try reader.readUntilDelimiterOrEof(&buf, '\n');

        if (line_a == null) break;
        const a = try parseClawButton(line_a.?);

        const line_b = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse unreachable;
        const b = try parseClawButton(line_b);

        const line_prize = (try reader.readUntilDelimiterOrEof(&buf, '\n')) orelse unreachable;
        const prize = try parsePrize(line_prize);

        var min_token: usize = 1_000_000;

        for (0..110) |i| {
            const x_a = a.x * i;
            const y_a = a.y * i;

            if (x_a > prize.x or y_a > prize.y) break;

            const x_rem = prize.x - x_a;
            const y_rem = prize.y - y_a;

            // std.debug.print("rem_x = {d}, rem_y = {d}\n", .{ x_rem, y_rem });

            if (x_rem % b.x != 0 or y_rem % b.y != 0) continue;
            const j = x_rem / b.x;

            // std.debug.print("j = {d}\n", .{j});
            if (y_rem / b.y != j) continue;

            const cost = 3 * i + j;

            if (cost < min_token) {
                min_token = cost;
            }
        }

        if (min_token < 1_000_000) {
            // std.debug.print("tokens = {d}\n", .{min_token});
            total_token += min_token;
        }

        const empty = try reader.readUntilDelimiterOrEof(&buf, '\n');

        if (empty == null) {
            break;
        }
    }

    std.debug.print("{d}\n", .{total_token});
}
