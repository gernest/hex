// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;

const hex_tables = "0123456789abcdef";

pub fn encodeLen(n: usize) usize {
    return n * 2;
}

pub fn encode(dst: []u8, src: []const u8) usize {
    assert(dst.len >= encodeLen(src.len));
    var j: usize = 0;
    for (src) |v| {
        dst[j] = hex_tables[@intCast(usize, v) >> 4];
        dst[j + 1] = hex_tables[@intCast(usize, v) & 0x0f];
        j += 2;
    }
    return src.len * 2;
}

test "encode" {
    var buf = &try std.Buffer.init(std.debug.global_allocator, "");
    defer buf.deinit();
    const Case = struct {
        e: []const u8,
        d: []const u8,
    };
    const encoded_cases = [_]Case{
        Case{ .e = "0001020304050607", .d = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7 } },
    };
    for (encoded_cases) |tc| {
        try buf.resize(encodeLen(tc.d.len));
        _ = encode(buf.toSlice(), tc.d);
        testing.expectEqualSlices(u8, tc.e, buf.toSlice());
    }
}
