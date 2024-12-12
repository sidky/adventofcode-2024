const std = @import("std");

const Allocator = std.mem.Allocator;

fn BinaryIndexTree(comptime T: type, comptime combineFn: fn (a: T, b: T) T) type {
    return struct {
        const Self = @This();

        // leaves: []?T,
        // inner: [][]T,
        allocator: Allocator,
        combineFn: fn (a: T, b: T) T,

        pub fn init(allocator: Allocator, size: usize) !Self {
            const leaves = try initializeLeaves(allocator, size);
            defer allocator.free(leaves);

            // const in: [][]T = undefined;
            //

            // const leaves = try allocator.alloc(T, size);
            // for (0..leaves.size) |i| {
            //     leaves[i] = null;
            // }
            // var levels: usize = 0;
            // var size: usize = 1;

            // while (size < leave_size) {
            //     levels += 1;
            //     size *= 2;
            // }

            // const inners = try allocator.alloc([]Value, levels);
            // size = 1;
            // for (0..levels) |i| {
            //     inners[i] = try allocator.alloc(Value, size);
            //     size *= 2;
            // }
            //
            // _ = leave_size;
            //
            // _ = size;

            return Self{
                // .leaves = leaves,
                // .inner = in,
                .combineFn = combineFn,
                .allocator = allocator,
            };
        }

        fn initializeLeaves(allocator: Allocator, size: usize) []?T {
            const leaves = try allocator.alloc(T, size);
            return leaves;
        }

        pub fn deinit(self: *const Self) void {
            // for (self.inner) |level| {
            //     self.allocator.free(level);
            // }
            // self.allocator.free(self.inner);
            // self.allocator.free(self.leaves);
            _ = self;
        }
    };
}

fn same(comptime T: type, default: T) fn (?T) T {
    return struct {
        fn call(v: ?T) T {
            return v or default;
        }
    }.call;
}

fn sum(a: u32, b: u32) u32 {
    return a + b;
}

test "new tree" {
    const bit = try BinaryIndexTree(u32, sum).init(std.testing.allocator, 20);
    defer bit.deinit();
}
