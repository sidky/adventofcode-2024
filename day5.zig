const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day5.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var node_list = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer node_list.deinit();
    var buffer: [1024]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (line.len == 0) break;

        var parts = std.mem.tokenizeScalar(u8, line, '|');
        const n1 = try std.fmt.parseInt(u32, parts.next() orelse "", 10);
        const n2 = try std.fmt.parseInt(u32, parts.next() orelse "", 10);

        var list = node_list.get(n1);

        if (list == null) {
            var new_list = std.ArrayList(u32).init(allocator);
            try new_list.append(n2);
            try node_list.put(n1, new_list);
        } else {
            try list.?.append(n2);
            try node_list.put(n1, list.?);
        }
    }

    var sum: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var pages = std.mem.tokenizeScalar(u8, line, ',');
        var previous = std.ArrayList(u32).init(allocator);
        defer previous.deinit();

        var valid = true;
        var all_pages = std.ArrayList(u32).init(allocator);
        defer all_pages.deinit();

        check_loop: while (pages.next()) |page| {
            const pg = try std.fmt.parseInt(u32, page, 10);
            try all_pages.append(pg);
            const list = node_list.get(pg);

            if (list != null) {
                for (previous.items) |prev| {
                    for (list.?.items) |order| {
                        if (order == prev) {
                            valid = false;
                            break :check_loop;
                        }
                    }
                }
            }
            try previous.append(pg);
        }
        if (!valid) {} else {
            std.debug.print("VALID!\n", .{});

            const len = all_pages.items.len;
            sum += all_pages.items[len / 2];
        }
    }

    std.debug.print("{d}\n", .{sum});

    var iterator = node_list.iterator();

    while (iterator.next()) |entry| {
        std.debug.print("{d}: ", .{entry.key_ptr.*});

        for (entry.value_ptr.items) |v| {
            std.debug.print(" {d}", .{v});
        }
        std.debug.print("\n", .{});
        entry.value_ptr.deinit();
    }
}
