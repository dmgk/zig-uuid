# Fast, allocation-free v4 UUIDs in Zig

## Example

```zig
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
```

```
$ zig run example.zig 
78c33481-4c67-4202-ba8d-11ee1dfaad24
3df6f0e4-f9b1-4e34-ad70-33206069b995
```

### Tests
```bash
zig test uuid.zig
```
```bash
Test [3/3] test.check to_string works... 
First  call to_string 851d0256-c62c-43b0-bf15-71da00bafb30 
Second call to_string 851d0256-c62c-43b0-bf15-71da00bafb30 
All 3 tests passed.
```