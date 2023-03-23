const std = @import("std");

const c = @cImport({
    @cInclude("string.h");
    @cInclude("stdlib.h");
});

var _gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const gpa = _gpa.allocator();
    var map = std.StringHashMap(f32).init(gpa);

    defer map.deinit();

    try map.put("WAST", 1);
    try map.put("ET", 5);
    try map.put("EST", -5);
    try map.put("EDT", -4);
    try map.put("IST", -5.5);

    const sample_1 = "6:00";
    // const sample_2 = "10".*;

    const time_s = switchTimezones(map, sample_1, "WAST", "ET");
    std.debug.print("{}:{}\n", .{ time_s[0], time_s[1] });
}

fn split(string: []const u8, separator: u8) [3][2]u8 {
    var index: u8 = 0;
    var sub_index: u8 = 0;
    var split_arr: [3][2]u8 = undefined;
    for (string) |char| {
        if (char != separator) {
            split_arr[index][sub_index] = char;
            sub_index += 1;
        } else {
            index += 1;
            split_arr[index][0] = char;
            split_arr[index][1] = ' ';
            index += 1;
            sub_index = 0;
        }
    }
    return split_arr;
}

// convert a differentiator value to correspond time difference
// by subtracting hours by the integer part of the value
// and subtracting the minutes by the fractional part, k, multiplied by 60 -> k*60
fn getSubtractors(timeDiff: f32) [2]i32 {
    var hours = @floor(timeDiff);
    hours = if (timeDiff < 0) hours + 1 else hours;
    const minutes = ((@ceil(timeDiff) - @floor(timeDiff)) * 0.5 * 60);
    const result: [2]i32 = [2]i32{ @floatToInt(i32, hours), @floatToInt(i32, minutes) };
    return result;
}

fn switchTimezones(map: std.StringHashMap(f32), time: []const u8, original_tz: []const u8, target_tz: []const u8) [2]u32 {
    const startDiff = map.get(original_tz);
    const targetDiff = map.get(target_tz);

    // first convert to GMT
    const start_subtractors = getSubtractors(startDiff.?);
    const time_nums = timeComp(split(time, ':'));

    const gmt_time = [2]u32{ time_nums[0] + @intCast(u32, start_subtractors[0]), time_nums[1] + @intCast(u32, start_subtractors[1]) };

    // convert the gmt time to target time zone
    const target_subtractors = getSubtractors(targetDiff.?);

    const target_time = [2]u32{ gmt_time[0] + @intCast(u32, target_subtractors[0]), gmt_time[1] + @intCast(u32, target_subtractors[1]) };

    return target_time;
}

fn timeComp(timeArr: [3][2]u8) [2]u32 {
    const hoursNum = c.atoi(&timeArr[0]);
    const minNum = c.atoi(&timeArr[2]);

    const result = [2]u32{ @intCast(u32, hoursNum), @intCast(u32, minNum) };
    return result;
}

fn no_use(something: []const u8) void {
    _ = something;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
