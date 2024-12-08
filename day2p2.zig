const std = @import("std");
const fs = std.fs;
const expect = std.testing.expect;

fn sign(number: i32) i32 {
    return if (number < 0) -1 else if (number > 0) 1 else 0;
}

pub fn isSafe(report: []u32) bool {
    if (report.len < 2) return true;

    const direction = sign(diff(report[0], report[1]));
    // std.debug.print("direction = {d}\n", .{direction});
    if (direction == 0) return false;

    for (1..report.len) |index| {
        const d = diff(report[index - 1], report[index]);
        if (sign(d) != direction) return false;

        const absd = @abs(d);

        // std.debug.print("{d}, {d} => {d} abd {d}\n", .{ report[index - 1], report[index], d, absd });

        if (absd == 0 or absd > 3) return false;
    }

    return true;
}

fn diff(r1: u32, r2: u32) i32 {
    const signedR1: i32 = @intCast(r1);
    const signedR2: i32 = @intCast(r2);

    return signedR1 - signedR2;
}

test "safe report" {
    var report = [_]u32{ 7, 6, 4, 2, 1 };

    try expect(isSafe(report[0..report.len]) == true);
}

test "unsafe report" {
    var report = [_]u32{ 1, 2, 7, 8, 9 };

    try expect(isSafe(report[0..report.len]) == false);
}

test "unsafe report mixed" {
    var report = [_]u32{ 1, 3, 2, 4, 5 };

    try expect(isSafe(report[0..report.len]) == false);
}

test "unsafe report stay same" {
    var report = [_]u32{ 8, 6, 4, 4, 1 };

    try expect(isSafe(report[0..report.len]) == false);
}

test "safe 2" {
    var report = [_]u32{ 1, 3, 6, 7, 9 };

    std.debug.print("******************\n", .{});
    try expect(isSafe(report[0..report.len]) == true);
}

fn removeAt(report: []u32, indexAt: usize, updated: []u32) void {
    for (report, 0..) |value, index| {
        if (index < indexAt) {
            updated[index] = value;
        } else if (index > indexAt) {
            updated[index - 1] = value;
        }
    }
}

fn isSafeWithRemoval(report: []u32) bool {
    if (isSafe(report)) return true;

    var updated: [1000]u32 = undefined;

    for (0..report.len) |index| {
        removeAt(report, index, updated[0..]);

        if (isSafe(updated[0..(report.len - 1)])) {
            return true;
        }
    }

    return false;
}

pub fn main() !void {
    var file = try fs.openFileAbsolute("/home/sidky/workspace/contest/adventofcode/2024/day2.txt", .{ .mode = fs.File.OpenMode.read_only });
    defer file.close();

    const reader = file.reader();

    var report: [1000]u32 = undefined;
    var buf: [1024]u8 = undefined;
    var total_safe: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokenized = std.mem.tokenizeScalar(u8, line, ' ');

        var index: usize = 0;

        while (tokenized.next()) |token| {
            const number = try std.fmt.parseInt(u32, token, 10);

            report[index] = number;
            index += 1;
        }

        if (isSafeWithRemoval(report[0..index])) {
            total_safe += 1;
        }
    }

    std.debug.print("{d}\n", .{total_safe});
}
