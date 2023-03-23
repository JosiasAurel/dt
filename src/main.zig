const std = @import("std");

const c = @cImport({
    @cInclude("stdlib.h");
});

var _gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const gpa = _gpa.allocator();
    var map = std.StringHashMap(f32).init(gpa);

    defer map.deinit();

    try map.put("wast", 1);
    try map.put("et", -4);
    try map.put("pt", -7);
    try map.put("ct", -5);
    try map.put("at", -4);
    try map.put("ist", 5.5);

    // const sample_1 = "15:31";
    // const sample_2 = "10".*;

    // const time_s = switchTimezones(map, sample_1, "wast", "ist");
    // std.debug.print("{}:{}\n", .{ time_s[0], time_s[1] });

    var args = std.process.args();

    _ = args.skip(); // skip executable name

    var time = args.next();
    var origin = args.next();
    var target = args.next();

    if (origin == null) {
        std.debug.print("Missing origin timezone \n", .{});
    } else if (target == null) {
        std.debug.print("Missing target timezone \n", .{});
    } else if (time == null) {
        std.debug.print("Missing time value \n", .{});
    } else {
        var origin_exist = map.get(origin.?);
        var target_exist = map.get(target.?);
        if (origin_exist == null) {
            std.debug.print("Origin timezone not known \n", .{});
        } else if (target_exist == null) {
            std.debug.print("Target timezone not known \n", .{});
        } else {
            const time_s = switchTimezones(map, time.?, origin.?, target.?);
            std.debug.print("{}:{} \n", .{ time_s[0], time_s[1] });
        }
    }
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

fn getTimeDiff(timeDiff: f32) f32 {
    return timeDiff * 60;
}

fn switchTimezones(map: std.StringHashMap(f32), time: []const u8, original_tz: []const u8, target_tz: []const u8) [2]u32 {
    const gmtDiff = map.get(original_tz).? * 60;
    const targetGmtDiff = map.get(target_tz).? * 60;

    const gmtTime = getTime(split(time, ':')) - gmtDiff;
    const targetTime = gmtTime + targetGmtDiff;

    const hours = @floor(targetTime / 60);
    const minutes = @rem(targetTime, 60);

    const result = [2]u32{ @floatToInt(u32, hours), @floatToInt(u32, minutes) };
    return result;
}

fn timeComp(timeArr: [3][2]u8) [2]u32 {
    const hoursNum = c.atoi(&timeArr[0]);
    const minNum = c.atoi(&timeArr[2]);

    const result = [2]u32{ @intCast(u32, hoursNum), @intCast(u32, minNum) };
    return result;
}

// returns the time in minutes
fn getTime(timeArr: [3][2]u8) f32 {
    const hours_and_mins = timeComp(timeArr);

    var time = hours_and_mins[1];
    time += hours_and_mins[0] * 60;

    return @intToFloat(f32, time);
}

fn no_use(something: []const u8) void {
    _ = something;
}
