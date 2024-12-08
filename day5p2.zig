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

        var all_pages = std.ArrayList(u32).init(allocator);
        defer all_pages.deinit();

        while (pages.next()) |page| {
            const pg = try std.fmt.parseInt(u32, page, 10);
            try all_pages.append(pg);
        }

        var valid = true;
        check_loop: for (all_pages.items) |page| {
            const list = node_list.get(page);

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
            try previous.append(page);
        }

        if (!valid) {
            var degree = std.AutoHashMap(u32, u32).init(allocator);
            defer degree.deinit();

            for (all_pages.items) |page| {
                // std.debug.print("page = {d}\n", .{page});
                if (degree.get(page) == null) {
                    try degree.put(page, 0);
                }
                const list = node_list.get(page);

                if (list != null) {
                    for (list.?.items) |order| {
                        for (all_pages.items) |other_page| {
                            if (other_page == order) {
                                // std.debug.print("add degree for page = {d}\n", .{other_page});
                                const old_value = degree.get(other_page) orelse 0;
                                try degree.put(other_page, old_value + 1);
                                break;
                            }
                        }
                    }
                }
            }

            var reordered = std.ArrayList(u32).init(allocator);
            defer reordered.deinit();

            while (reordered.items.len < all_pages.items.len) {
                var iterator = degree.iterator();
                while (iterator.next()) |entry| {
                    // std.debug.print("key={d} value={d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
                    if (entry.value_ptr.* == 0) {
                        const page = entry.key_ptr.*;
                        try reordered.append(page);
                        _ = degree.remove(page);

                        const list = node_list.get(page);

                        if (list != null) {
                            for (list.?.items) |other| {
                                const old_value = degree.get(other);

                                if (old_value != null) {
                                    try degree.put(other, (old_value orelse 1) - 1);
                                }
                            }
                        }
                    }
                }
            }
            for (reordered.items) |item| {
                std.debug.print("{d}, ", .{item});
            }
            std.debug.print("\n", .{});
            sum += reordered.items[reordered.items.len / 2];
        }
    }

    std.debug.print("{d}\n", .{sum});

    var iterator = node_list.iterator();

    while (iterator.next()) |entry| {
        // for (entry.value_ptr.items) |v| {
        //     std.debug.print(" {d}", .{v});
        // }
        std.debug.print("\n", .{});
        entry.value_ptr.deinit();
    }
}
