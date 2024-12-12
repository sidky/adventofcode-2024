const std = @import("std");
const fs = std.fs;

const Region = struct { id: u64, empty: bool, start: usize, size: usize };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/adventofcode2024/day9.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [20001]u8 = undefined;

    const line = try reader.readUntilDelimiterOrEof(&buf, '\n');

    var regions = std.ArrayList(Region).init(allocator);
    defer regions.deinit();

    var start: usize = 0;

    var id: u64 = 0;

    for (line.?, 0..) |d, i| {
        const size = d - '0';

        if (i % 2 == 0) {
            try regions.append(Region{ .id = id, .empty = false, .start = start, .size = size });

            id += 1;
        } else {
            try regions.append(Region{ .id = 0, .empty = true, .start = start, .size = size });
        }

        start += size;
    }

    var last = regions.items.len - 1;

    var checksum: u64 = 0;

    for (0..regions.items.len) |i| {
        if (!regions.items[i].empty) {
            for (regions.items[i].start..(regions.items[i].start + regions.items[i].size)) |j| {
                const casted: u64 = @intCast(j);
                checksum += (regions.items[i].id * casted);
            }
        } else {
            var empty_index = regions.items[i].start;
            while (regions.items[i].size > 0) {
                while (regions.items[last].size == 0) : (last -= 2) {
                    if (last <= i) break;
                }
                if (last <= i) break;

                const max_fill = @min(regions.items[i].size, regions.items[last].size);

                for (0..max_fill) |_| {
                    checksum += empty_index * regions.items[last].id;
                    empty_index += 1;
                }

                regions.items[i].size -= max_fill;
                regions.items[last].size -= max_fill;
            }
        }
    }

    for (regions.items) |r| {
        std.debug.print("{s}:{d} {d}-{d}\n", .{ if (r.empty) "empty" else "file", r.id, r.start, r.size });
    }

    std.debug.print("{d}\n", .{checksum});
}
