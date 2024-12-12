const std = @import("std");
const fs = std.fs;
const Order = std.math.Order;
const Allocator = std.mem.Allocator;

const File = struct { id: u64, start: usize, size: usize, rearranged: bool };

fn lessThan(context: void, a: usize, b: usize) Order {
    _ = context;

    return std.math.order(a, b);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day9.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    var free_spaces: [10]std.PriorityQueue(usize, void, lessThan) = undefined;
    var files = std.ArrayList(File).init(allocator);
    defer files.deinit();

    for (0..free_spaces.len) |i| {
        free_spaces[i] = std.PriorityQueue(usize, void, lessThan).init(allocator, void{});
    }
    defer {
        for (free_spaces) |free_space| {
            free_space.deinit();
        }
    }

    const reader = file.reader();

    var buf: [20001]u8 = undefined;

    const line = try reader.readUntilDelimiterOrEof(&buf, '\n');
    var start: usize = 0;
    var id: u64 = 0;

    for (line.?, 0..) |d, i| {
        if (i % 2 == 0) {
            const new_file = File{
                .id = id,
                .start = start,
                .size = @intCast(d - '0'),
                .rearranged = false,
            };
            id += 1;
            try files.append(new_file);
        } else {
            try free_spaces[d - '0'].add(start);
        }
        start += d - '0';
    }

    var i = files.items.len - 1;

    while (i > 0) : (i -= 1) {
        const file_size = files.items[i].size;

        var new_start: ?usize = null;
        var new_empty_size: ?usize = null;

        for (file_size..10) |empty_size| {
            const possible_new_start = free_spaces[empty_size].peek();

            if (possible_new_start) |candidate| {
                std.debug.print("{d}: candidate: {d} {d}\n", .{ files.items[i].id, candidate, empty_size });
                if (candidate < files.items[i].start and (new_start == null or candidate < new_start.?)) {
                    new_start = candidate;
                    new_empty_size = empty_size;
                }
            }
        }

        if (new_empty_size) |ns| {
            const rearranged_start = free_spaces[ns].remove();

            files.items[i].start = rearranged_start;

            const remaining = ns - files.items[i].size;

            if (remaining > 0) {
                try free_spaces[remaining].add(rearranged_start + files.items[i].size);
            }
        }
    }

    var checksum: usize = 0;

    for (files.items) |f| {
        for (0..f.size) |n| {
            checksum += (n + f.start) * f.id;
        }
    }

    std.debug.print("{d}\n", .{checksum});
}
