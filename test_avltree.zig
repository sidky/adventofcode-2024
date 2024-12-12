const std = @import("std");
const avltree = @import("avltree.zig");
const expect = std.testing.expect;

fn lessThan(a: u32, b: u32) std.math.Order {
    return std.math.order(a, b);
}

test "new tree" {
    const tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();
    try expect(tree.root == null);
}

test "insert 1 value" {
    var tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();

    try tree.add(19);

    const expected_order = [_]u32{19};

    var it = tree.iterator();
    var i: usize = 0;

    while (it.next()) |v| {
        try expect(v == expected_order[i]);
        i += 1;
    }
}

test "insert 2 value" {
    var tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();

    try tree.add(19);
    try tree.add(8);

    var it = tree.iterator();

    var i: usize = 0;
    const expected_order = [_]u32{ 8, 19 };

    while (it.next()) |v| {
        try expect(v == expected_order[i]);
        i += 1;
    }
}

test "insert 3 value" {
    var tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();

    try tree.add(19);
    try tree.add(8);
    try tree.add(27);

    var it = tree.iterator();

    const expected_order = [_]u32{ 8, 19, 27 };
    var i: usize = 0;

    while (it.next()) |v| {
        try expect(v == expected_order[i]);
        i += 1;
    }
}

test "insert arbitrary value" {
    var tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();

    try tree.add(19);
    try tree.add(8);
    try tree.add(27);
    try tree.add(22);
    try tree.add(3);
    try tree.add(1);

    var it = tree.iterator();

    const expected_order = [_]u32{ 1, 3, 8, 19, 22, 27 };

    var i: usize = 0;

    while (it.next()) |v| {
        try expect(v == expected_order[i]);
        i += 1;
    }
}

test "insert find" {
    var tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();

    try tree.add(19);
    try tree.add(8);
    try tree.add(27);
    try tree.add(22);
    try tree.add(3);
    try tree.add(1);

    try expect(tree.find(22));
    try expect(tree.find(1));
    try expect(tree.find(24) == false);
}

test "delete item" {
    var tree = avltree.AVLTree(u32, lessThan).init(std.testing.allocator);
    defer tree.deinit();

    try tree.add(19);
    try tree.add(8);
    try tree.add(27);
    try tree.add(22);
    try tree.add(3);
    try tree.add(1);

    std.debug.print("before tree ", .{});
    tree.print();

    _ = try tree.remove(19);

    std.debug.print("after tree", .{});
    tree.print();
    const expected_order = [_]u32{ 1, 3, 8, 22, 27 };

    var i: usize = 0;
    var it = tree.iterator();

    while (it.next()) |v| {
        try expect(v == expected_order[i]);
        i += 1;
    }
}
