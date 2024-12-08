const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day1.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }

    const allocator = gpa.allocator();

    var buf: [1024]u8 = undefined;

    var list1 = try allocator.alloc(u32, 1000);
    defer allocator.free(list1);
    var list2 = try allocator.alloc(u32, 1000);
    defer allocator.free(list2);

    var index: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');

        list1[index] = try std.fmt.parseInt(u32, numbers.next() orelse "", 0);
        list2[index] = try std.fmt.parseInt(u32, numbers.next() orelse "", 0);

        index += 1;
    }

    std.mem.sort(u32, list1[0..index], {}, std.sort.asc(u32));

    var i: usize = 0;
    var score: u32 = 0;

    while (i < index) : (i += 1) {
        if (i > 0 and list1[i - 1] == list1[i]) {
            continue;
        }

        var j: usize = 0;
        var count: u32 = 0;

        while (j < index) : (j += 1) {
            if (list2[j] == list1[i]) {
                count += 1;
            }
        }

        score += list1[i] * count;
    }

    std.debug.print("{d}\n", .{score});
}
