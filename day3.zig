const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day3.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var buf: [1000024]u8 = undefined;
    var result: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const prefix = "mul(";

        outer: for (0..(line.len - 5)) |start| {
            // std.debug.print("start = {d}\n", .{start});
            for (prefix, start..) |ch1, idx| {
                const ch2 = line[idx];
                if (ch1 != ch2) {
                    continue :outer;
                }
            }

            var end = start + 4;

            while (end < line.len) {
                if (line[end] == ')') break;

                end += 1;
            }

            if (end >= line.len) continue :outer;

            const params = line[(start + 4)..end];

            var splits = std.mem.tokenizeScalar(u8, params, ',');

            const s1 = splits.next();
            const s2 = splits.next();
            const s3 = splits.next();

            if (s3 != null) {
                continue :outer;
            }

            const n1: u32 = std.fmt.parseInt(u32, s1.?, 10) catch {
                continue :outer;
            };
            const n2: u32 = std.fmt.parseInt(u32, s2.?, 10) catch {
                continue :outer;
            };

            std.debug.print("{d} {d}\n", .{ n1, n2 });
            result += n1 * n2;
        }
    }

    std.debug.print("{d}\n", .{result});
}
