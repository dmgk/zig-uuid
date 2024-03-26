const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("uuid", .{
        .root_source_file = .{ .path = "uuid.zig" },
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{ .root_source_file = .{ .path = "uuid.zig" } });
    const run_tests = b.addRunArtifact(tests);
    const tests_step = b.step("test", "Run tests");

    tests_step.dependOn(&run_tests.step);
}
