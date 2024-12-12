const std = @import("std");
const fs = std.fs;
const Order = std.math.Order;
const Allocator = std.mem.Allocator;

// AVL Tree

const RotationError = error{NoElement};

fn Node(comptime T: type, comptime cmpFn: fn (a: T, b: T) Order) type {
    return struct {
        const Self = @This();

        value: T,
        parent: ?*Self = null,
        left: ?*Self = null,
        right: ?*Self = null,
        height: usize = 0,
        allocator: Allocator,

        pub fn init(value: T, allocator: Allocator) !*Self {
            var nodes = try allocator.alloc(Self, 1);
            var new_node = &nodes[0];

            new_node.value = value;
            new_node.parent = null;
            new_node.left = null;
            new_node.right = null;
            new_node.height = 0;
            new_node.allocator = allocator;
            return new_node;
        }

        pub fn deinit(self: *Self) void {
            // std.debug.print("self {?}\n", .{self});
            if (self.left) |node| {
                // std.debug.print("{?}\n", .{self.left});
                node.deinit();
                self.allocator.destroy(node);
            }

            if (self.right) |node| {
                node.deinit();
                self.allocator.destroy(node);
            }
        }

        pub fn bf(self: *const Self) i32 {
            const lh: i32 = if (self.left) |*node|
                @intCast(node.*.height)
            else
                0;

            const rh: i32 = if (self.right) |*node|
                @intCast(node.*.height)
            else
                0;

            return lh - rh;
        }

        fn rotationRR(self: *Self) !*Self {
            if (self.right) |right| {
                const tempL = right.left;

                self.*.right = tempL;

                if (tempL) |new_left| {
                    new_left.parent = self;
                }
                right.*.left = self;
                self.*.parent = right;

                return right;
            } else {
                return RotationError.NoElement;
            }
        }

        fn rotationLL(self: *Self) !*Self {
            if (self.left) |left| {
                const tempR = left.right;

                self.*.left = tempR;
                if (tempR) |new_right| {
                    new_right.parent = self;
                }
                left.*.right = self;
                self.*.parent = left;

                return left;
            } else {
                return RotationError.NoElement;
            }
        }

        fn updateHeight(self: *Self) void {
            const left_height = if (self.left) |node| node.height else 0;
            const right_height = if (self.right) |node| node.height else 0;

            self.height = @max(left_height, right_height) + 1;
        }

        fn balance(self: *Self) !*Self {
            const factor = self.bf();

            if (factor >= -1 and factor <= 1) return self;

            if (factor < 0) {
                return self.rotationRR();
            } else {
                return self.rotationLL();
            }
        }

        fn balanceToRoot(self: *Self) !*Self {
            self.updateHeight();
            vartry self.balance();
        }

        fn add(self: *Self, new_value: T) !*Self {
            const order = cmpFn(self.value, new_value);

            switch (order) {
                .lt, .eq => {
                    if (self.right) |node| {
                        self.right = try node.add(new_value);
                    } else {
                        var new_node = try init(new_value, self.allocator);
                        new_node.parent = self;
                        self.right = new_node;
                    }
                },
                .gt => {
                    if (self.left) |node| {
                        self.left = try node.add(new_value);
                    } else {
                        var new_node = try init(new_value, self.allocator);
                        new_node.parent = self;
                        self.left = new_node;
                    }
                },
            }
            // std.debug.print("add {d}: {?}\n", .{ new_value, self });
            self.updateHeight();
            return try self.balance();
        }

        fn smallest(self: *Self) *Self {
            var ret = self;

            std.debug.print("smallest\n", .{});
            while (ret.left) |left| {
                left.print(0);
                std.debug.print("\n", .{});
                ret = left;
            }

            return ret;
        }

        fn modifyParent(self: *Self, new_node: ?*Self) void {
            if (self.parent) |parent| {
                std.debug.print("before ", .{});
                parent.print(0);
                std.debug.print("\n", .{});

                if (parent.left == self) {
                    parent.left = new_node;
                } else if (parent.right == self) {
                    parent.right = new_node;
                } else {
                    return;
                }

                std.debug.print("after ", .{});
                parent.print(0);
                std.debug.print("\n", .{});

                if (new_node) |node| {
                    node.parent = parent;
                }

                parent.updateHeight();
                try parent.balance();
            }
        }

        fn print(self: *const Self, depth: usize) void {
            if (depth > 10) return;
            std.debug.print("{d}(", .{self.value});
            if (self.left) |node| {
                node.print(depth + 1);
            } else {
                std.debug.print("null", .{});
            }
            std.debug.print(",", .{});
            if (self.right) |node| {
                node.print(depth + 1);
            } else {
                std.debug.print("null", .{});
            }
            std.debug.print(")", .{});
        }

        fn remove(self: *Self) void {
            self.modifyParent(null);
            self.parent = null;
        }
    };
}

pub fn AVLTree(comptime T: type, comptime cmpFn: fn (a: T, b: T) Order) type {
    return struct {
        const Self = @This();

        root: ?*Node(T, cmpFn),
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .root = null,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            if (self.root) |root_node| {
                root_node.deinit();
                self.allocator.destroy(root_node);
            }
        }

        pub fn add(self: *Self, new_value: T) !void {
            if (self.root) |node| {
                self.root = try node.add(new_value);
            } else {
                self.root = try Node(T, cmpFn).init(new_value, self.allocator);
            }
            // std.debug.print("root {?}\n", .{self});
        }

        pub fn iterator(self: *const Self) Iterator {
            if (self.root) |root| {
                return Iterator{ .node = root.smallest() };
            } else {
                return Iterator{ .node = null };
            }
        }

        pub fn find(self: *const Self, value: T) bool {
            var node = self.root;
            while (node) |n| {
                switch (cmpFn(n.value, value)) {
                    .eq => return true,
                    .gt => if (n.left) |left| {
                        node = left;
                    } else {
                        return false;
                    },
                    .lt => if (n.right) |right| {
                        node = right;
                    } else {
                        return false;
                    },
                }
            }

            return false;
        }

        fn findNode(self: Self, value: T) ?*Node(T, cmpFn) {
            if (self.root) |root| {
                var node = root;

                while (true) {
                    switch (cmpFn(node.value, value)) {
                        .eq => break,
                        .gt => if (node.left) |left| {
                            node = left;
                        } else {
                            return null;
                        },
                        .lt => if (node.right) |right| {
                            node = right;
                        } else {
                            return null;
                        },
                    }
                }
                return node;
            } else {
                return null;
            }
        }

        fn removeNode(self: *Self, value: T) !?*Node(T, cmpFn) {
            const find_node = self.findNode(value);
            if (find_node) |node| {
                std.debug.print("found node to remove ", .{});
                node.print(0);
                std.debug.print("\n", .{});

                // find new node to replace it with
                if (node.right) |right| {
                    var new_node = right.smallest();
                    new_node.remove();

                    new_node.left = node.left;
                    new_node.right = node.right;
                    new_node.updateHeight();

                    node.modifyParent(new_node);
                    if (new_node.parent == null) {
                        self.root = new_node;
                    }
                } else {
                    node.modifyParent(node.left);
                }

                var update_parent = node.parent;

                node.modifyParent(null);

                while (true) {
                    if (update_parent) |up| {
                        up.updateHeight();
                        _ = try up.balance();

                        std.debug.print("updated ", .{});
                        up.print(0);
                        std.debug.print("\n", .{});

                        update_parent = up.parent;
                    } else {
                        break;
                    }
                }

                return node;
            } else {
                return null;
            }
        }

        pub fn remove(self: *Self, value: T) !bool {
            const to_remove = self.findNode(value);

            if (to_remove) |node| {
                std.debug.print("found ", .{});
                node.print(0);
                std.debug.print("\n", .{});
                if (node.right) |right| {
                    var new_node = right;

                    while (new_node.left) |left| {
                        new_node = left;
                    }

                    new_node.modifyParent(null);
                    new_node.left = node.left;
                    new_node.right = node.right;

                    if (node.parent == null) {
                        self.root = new_node;
                        new_node.parent = null;
                    } else {
                        node.modifyParent(new_node);
                    }
                } else {
                    node.modifyParent(node.left);
                }

                node.left = null;
                node.right = null;
                node.parent = null;
                node.deinit();
                self.allocator.destroy(node);

                return true;
            } else {
                return false;
            }
        }

        pub fn print(self: *const Self) void {
            if (self.root) |root| {
                root.print(0);
                std.debug.print("\n", .{});
            }
        }

        pub const Iterator = struct {
            node: ?*const Node(T, cmpFn),

            pub fn next(it: *Iterator) ?T {
                if (it.node == null) return null;

                if (it.node) |node| {
                    const ret = node.value;

                    if (node.right) |right| {
                        var next_node = right;

                        it.node = next_node.smallest();
                    } else {
                        var child = node;
                        var parent = node.parent;

                        while (parent) |p| {
                            // std.debug.print("parent {?}\n\n child {?}\n", .{ parent, child });
                            if (p.right != child) break;

                            child = p;
                            parent = child.parent;
                        }
                        // std.debug.print("break: {?}\n", .{parent});

                        if (parent) |p| {
                            it.node = p;
                        } else {
                            it.node = null;
                        }
                    }
                    // std.debug.print("next node: {?}\n", .{it.node});
                    return ret;
                } else {
                    return null;
                }
            }
        };
    };
}
