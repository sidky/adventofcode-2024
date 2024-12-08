const std = @import("std");
const expect = std.testing.expect;

test "safe report" {
    const report: []u32 = .{ 7, 6, 4, 2, 1 };

    expect(isSafe(report) == true);
}
