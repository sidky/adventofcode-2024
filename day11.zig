const std = @import("std");
const queue = @import("queue.zig");
const fs = std.fs;

const StoneState = struct {
    value: u64,
    blinks: usize,
};

const MAX_ITERATION = 1;

var memo: [1_000_001][75]u64 = undefined;

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

pub fn main() !void {
    @memset(&memo, 0);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day11.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [20001]u8 = undefined;
    var numbers = try queue.CircularQueue(StoneState).init(allocator, 10000000);
    defer numbers.deinit();

    const line = try reader.readUntilDelimiterOrEof(&buf, '\n');

    var tokenized = std.mem.tokenizeScalar(u8, line.?, ' ');
    while (tokenized.next()) |token| {
        const num: u64 = try std.fmt.parseInt(u64, token, 10);
        try numbers.push(StoneState{ .value = num, .blinks = 0 });
    }
    var total_numbers: usize = 0;

    var t: i32 = 0;

    while (!numbers.isEmpty()) {
        var number: StoneState = try numbers.pop();
        std.debug.print("pop {d}\n", .{number.value});

        for ((number.blinks + 1)..(MAX_ITERATION + 1)) |iteration| {
            // std.debug.print("{d} {d}\n", .{ number.value, number.blinks });
            if (number.value == 0) {
                number = StoneState{ .value = 1, .blinks = iteration };
            } else if (digits(number.value) % 2 == 0) {
                var p: u64 = 1;
                const l = digits(number.value);
                const mask_len = l / 2;

                for (0..mask_len) |_| {
                    p *= 10;
                }

                const p1 = number.value / p;
                const p2 = number.value % p;

                // std.debug.print("split {d} {d}\n", .{ p1, p2 });

                number = StoneState{
                    .value = p1,
                    .blinks = iteration,
                };
                try numbers.push(StoneState{
                    .value = p2,
                    .blinks = iteration,
                });
            } else {
                number = StoneState{
                    .value = number.value * 2024,
                    .blinks = iteration,
                };
            }
            t += 1;
            // if (t == 50) return;
        }
        total_numbers += 1;
    }

    std.debug.print("{d}\n", .{total_numbers});
}
