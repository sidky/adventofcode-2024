const std = @import("std");
const queue = @import("queue.zig");
const fs = std.fs;

const MAX_ITERATION = 75;

var memo: [1_000_001][MAX_ITERATION + 1]u64 = undefined;

pub fn digits(n: u64) u8 {
    if (n == 0) return 1;
    var l: u8 = 0;
    var num: u64 = n;

    while (num > 0) {
        num /= 10;
        l += 1;
    }
    return l;
}

pub fn countNumbers(number: u64, remain: usize) u64 {
    // std.debug.print("{d} {d} -- DEBUG {d}\n", .{ number, remain, memo[2][1] });
    if (number <= 1_000_000) {
        if (memo[@as(usize, @intCast(number))][remain] > 0) {
            // std.debug.print("cached {d}\n", .{memo[@as(usize, @intCast(number))][remain]});
            return memo[@as(usize, @intCast(number))][remain];
        }
    }

    if (remain == 0) return 1;

    var result: u64 = 0;

    if (number == 0) {
        // std.debug.print("0 -> 1\n", .{});
        result = countNumbers(1, remain - 1);
    } else if (digits(number) % 2 == 0) {
        var p: u64 = 1;
        const l = digits(number);
        const mask_len = l / 2;

        for (0..mask_len) |_| {
            p *= 10;
        }

        const p1 = number / p;
        const p2 = number % p;
        // std.debug.print("{d} -> {d} {d}\n", .{ number, p1, p2 });

        result = countNumbers(p1, remain - 1) + countNumbers(p2, remain - 1);
    } else {
        // std.debug.print("{d} -> {d}\n", .{ number, number * 2024 });
        result = countNumbers(number * 2024, remain - 1);
    }
    // std.debug.print("--------------------", .{});
    if (number <= 1_000_000) {
        memo[@as(usize, @intCast(number))][remain] = result;
    }

    // std.debug.print("{d} {d} = {d}\n", .{ number, remain, result });

    return result;
}

pub fn main() !void {
    for (0..memo.len) |i| {
        @memset(&memo[i], 0);
    }

    // @memset(&memo, 0);
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    // const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day11.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [20001]u8 = undefined;
    // var numbers = try queue.CircularQueue(StoneState).init(allocator, 10000000);
    // defer numbers.deinit();

    const line = try reader.readUntilDelimiterOrEof(&buf, '\n');

    var tokenized = std.mem.tokenizeScalar(u8, line.?, ' ');
    var total_numbers: u64 = 0;

    while (tokenized.next()) |token| {
        const num: u64 = try std.fmt.parseInt(u64, token, 10);

        total_numbers += countNumbers(num, MAX_ITERATION);
    }

    std.debug.print("{d}\n", .{total_numbers});
}
