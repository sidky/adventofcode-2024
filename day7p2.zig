const std = @import("std");
const fs = std.fs;

// fn formulatable(items: []const u64, remaining: u64, start: usize) bool {
//     if (start >= items.len) {
//         return remaining == 0;
//     }

//     std.debug.print("remaining: {d} start: {d}\n", .{ remaining, start });

//     var partial: u64 = 1;

//     for (start..items.len) |j| {
//         partial *= items[j];

//         std.debug.print("{d}->{d}: partial: {d} remaining: {d}\n", .{ start, j, partial, remaining });

//         if (partial > remaining) break;

//         if (formulatable(items, remaining - partial, j + 1)) {
//             return true;
//         }
//     }
//     return false;
// }

fn append_num(src: u64, dst: u64) u64 {
    var target = src;
    var size_add = dst;

    if (dst == 0) return src * 10;

    while (size_add > 0) : (size_add /= 10) {
        target *= 10;
    }
    return target + dst;
}

fn formulatable(items: []const u64, target: u64, current: u64, start: usize) bool {
    if (start >= items.len) {
        return target == current;
    }

    if (current > target) return false;

    const add = formulatable(items, target, current + items[start], start + 1);
    const mul = current != 0 and formulatable(items, target, current * items[start], start + 1);
    const append = current != 0 and formulatable(items, target, append_num(current, items[start]), start + 1);

    return add or mul or append;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day7.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [1024]u8 = undefined;

    var sum: u64 = 0;

    // var max_length: usize = 0;
    // var max_target: u64 = 0;
    // var term_max: u64 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ':');
        const target = try std.fmt.parseInt(u64, parts.next() orelse "", 10);

        var values = std.mem.tokenizeScalar(u8, parts.next() orelse "", ' ');

        var terms_list = std.ArrayList(u64).init(allocator);
        defer terms_list.deinit();

        while (values.next()) |value_str| {
            const parsed = try std.fmt.parseInt(u64, value_str, 10);
            try terms_list.append(parsed);

            // term_max = @max(term_max, parsed);
        }
        // std.debug.print("Target: {d} length = {d}\n", .{ target, terms_list.items.len });

        // max_length = @max(max_length, terms_list.items.len);
        // max_target = @max(max_target, target);
        //
        if (formulatable(terms_list.items, target, 0, 0)) {
            std.debug.print("formulated {d}\n", .{target});
            sum += target;
        }
    }

    std.debug.print("{d}\n", .{sum});
}
