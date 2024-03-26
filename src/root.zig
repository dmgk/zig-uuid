// Fast allocation-free v4 UUIDs.
// Inspired by the Go implementation at github.com/skeeto/uuid

const std = @import("std");
const crypto = std.crypto;
const fmt = std.fmt;
const testing = std.testing;

pub const Error = error{InvalidUUID};

pub const bytes_len = 16;
pub const slice_len = 36;

pub const UUID = struct {
    bytes: [bytes_len]u8,

    pub fn init() UUID {
        var uuid = UUID{ .bytes = undefined };

        crypto.random.bytes(&uuid.bytes);
        // Version 4
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x40;
        // Variant 1
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
        return uuid;
    }

    pub fn toSlice(self: UUID) [36]u8 {
        var buf: [slice_len]u8 = undefined;
        buf[8] = '-';
        buf[13] = '-';
        buf[18] = '-';
        buf[23] = '-';
        inline for (encoded_pos, 0..) |i, j| {
            buf[i + 0] = hex[self.bytes[j] >> 4];
            buf[i + 1] = hex[self.bytes[j] & 0x0f];
        }
        return buf;
    }

    pub fn copy(self: UUID, dest: *[slice_len]u8) void {
        const src = self.toSlice();
        @memcpy(dest, &src);
    }

    // Indices in the UUID string representation for each byte.
    const encoded_pos = [16]u8{ 0, 2, 4, 6, 9, 11, 14, 16, 19, 21, 24, 26, 28, 30, 32, 34 };

    // Hex
    const hex = "0123456789abcdef";

    // Hex to nibble mapping.
    const hex_to_nibble = [256]u8{
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    };

    pub fn format(self: UUID, comptime layout: []const u8, _: fmt.FormatOptions, writer: anytype) !void {
        if (layout.len != 0 and layout[0] != 's')
            @compileError("Unsupported format specifier for UUID type: '" ++ layout ++ "'.");

        const buf = self.toSlice();
        try fmt.format(writer, "{s}", .{buf});
    }

    pub fn isValid(s: []const u8) bool {
        return s.len == slice_len and s[8] == '-' and s[13] == '-' and s[18] == '-' and s[23] == '-';
    }

    pub fn parse(s: []const u8) Error!UUID {
        var buf: [bytes_len]u8 = [_]u8{0} ** bytes_len;

        if (!isValid(s))
            return Error.InvalidUUID;

        inline for (encoded_pos, 0..) |i, j| {
            const hi = hex_to_nibble[s[i + 0]];
            const lo = hex_to_nibble[s[i + 1]];

            if (hi == 0xff or lo == 0xff) {
                return Error.InvalidUUID;
            }
            buf[j] = hi << 4 | lo;
        }
        return .{ .bytes = buf };
    }
};

// Zero UUID
pub const zero: UUID = .{ .bytes = .{0} ** bytes_len };

test "parse and format" {
    const uuids = [_][]const u8{
        "d0cd8041-0504-40cb-ac8e-d05960d205ec",
        "3df6f0e4-f9b1-4e34-ad70-33206069b995",
        "f982cf56-c4ab-4229-b23c-d17377d000be",
        "6b9f53be-cf46-40e8-8627-6b60dc33def8",
        "c282ec76-ac18-4d4a-8a29-3b94f5c74813",
        "00000000-0000-0000-0000-000000000000",
    };

    for (uuids) |uuid| {
        try testing.expectFmt(uuid, "{}", .{try UUID.parse(uuid)});
    }
}

test "invalid UUID" {
    const uuids = [_][]const u8{
        "3df6f0e4-f9b1-4e34-ad70-33206069b99", // too short
        "3df6f0e4-f9b1-4e34-ad70-33206069b9912", // too long
        "3df6f0e4-f9b1-4e34-ad70_33206069b9912", // missing or invalid group separator
        "zdf6f0e4-f9b1-4e34-ad70-33206069b995", // invalid character
    };

    for (uuids) |uuid| {
        try testing.expectError(Error.InvalidUUID, UUID.parse(uuid));
    }
}

test "UUID.copy()" {
    const uuid = UUID.init();
    var s: [36]u8 = undefined;
    uuid.copy(&s);
}
