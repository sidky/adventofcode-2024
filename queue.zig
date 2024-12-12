const std = @import("std");
const expect = std.testing.expect;

const QueueError = error{ BufferOverflow, EmptyQueue };

pub fn CircularQueue(comptime T: type) type {
    return struct {
        const Self = @This();

        buffer: []T,
        start: usize = 0,
        end: usize = 0,
        capacity: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            const buffer = try allocator.alloc(T, capacity);
            return Self{
                .buffer = buffer,
                .capacity = capacity,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        pub fn peek(self: *const Self) ?T {
            return if (self.start == self.end) null else self.buffer[self.start];
        }

        pub fn push(self: *Self, v: T) !void {
            if ((self.end + 1) % self.capacity == self.start) return QueueError.BufferOverflow;

            self.buffer[self.end] = v;
            self.end = (self.end + 1) % self.capacity;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.start == self.end;
        }

        pub fn pop(self: *Self) !T {
            if (self.isEmpty()) return QueueError.EmptyQueue;

            const ret = self.buffer[self.start];
            self.start = (self.start + 1) % self.capacity;

            return ret;
        }
    };
}

test "new queue" {
    var queue = try CircularQueue(u32).init(std.testing.allocator, 1000);
    defer queue.deinit();
    try expect(queue.isEmpty());
}

test "push and pop" {
    var queue = try CircularQueue(u32).init(std.testing.allocator, 1000);
    defer queue.deinit();
    try queue.push(102);
    try queue.push(103);
    try queue.push(104);
    try expect(queue.isEmpty() == false);

    try expect(try queue.pop() == 102);
    try expect(try queue.pop() == 103);
    try queue.push(101);
    try expect(try queue.pop() == 104);
    try expect(try queue.pop() == 101);
    try expect(queue.isEmpty());
}
