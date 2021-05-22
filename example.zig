const std = @import("std");
const UUID = @import("uuid.zig").UUID;

pub fn main() !void {
    // generate
    const uuid1 = UUID.init();
    std.debug.print("{}\n", .{uuid1});

    // parse
    const uuid2 = try UUID.parse("3df6f0e4-f9b1-4e34-ad70-33206069b995");
    std.debug.print("{}\n", .{uuid2});
}
