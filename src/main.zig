const std = @import("std");

const c = @cImport({
    @cInclude("stdlib.h");
});

const TimeError = error{InvalidTime};

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

    const help_doc =
        \\ dt <time> <origin_tz> <target_tz>
        \\ Example: dt 10:30 wast ist (converts from west african standard time to indian standard time)
        \\
        \\ Timezones:
        \\ wast: West African Standard Time
        \\ et: Easter Time
        \\ pt: Pacific Time
        \\ ct: Central Time
        \\ at: Atlantic Time
        \\ ist: Indian Standard Time
    ;

    var args = std.process.args();

    _ = args.skip(); // skip executable name

    var time = args.next();
    var origin = args.next();
    var target = args.next();

    if (origin == null and target == null and time == null) {
        std.debug.print(help_doc, .{});
    } else if (origin == null) {
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
            var isError = false;
            const time_s = switchTimezones(map, time.?, origin.?, target.?) catch |err| {
                isError = true;
                return err;
            };
            if (!isError) {
                std.debug.print("{}:{} and {} day(s) \n", .{ time_s[1], time_s[2], time_s[0] });
            }
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

fn getTimeDiff(timeDiff: f32) f32 {
    return timeDiff * 60;
}

fn switchTimezones(map: std.StringHashMap(f32), time: []const u8, original_tz: []const u8, target_tz: []const u8) ![3]i32 {
    const gmtDiff = map.get(original_tz).? * 60;
    const targetGmtDiff = map.get(target_tz).? * 60;

    const inTime = getTime(split(time, ':')) catch |err| return err;

    const gmtTime = inTime - gmtDiff;
    const targetTime = gmtTime + targetGmtDiff;

    var day: i32 = 0;
    var hours = @floor(targetTime / 60);
    var minutes = @rem(targetTime, 60);

    if (hours >= 24) {
        day += 1;
        hours = hours - 24;
    } else if (hours <= -1) {
        hours = if (hours == -1) 0 else 24 + hours;
    }

    if (minutes <= -1.0) {
        day -= 1;
        minutes = @intToFloat(f32, 60 + @floatToInt(i32, minutes));
        // std.debug.print("minutes = {}", .{@intToFloat(f32, 60 + @floatToInt(i32, minutes))});
        // minutes = @round(@intToFloat(f32, 60 + @truncate(i32, @floatToInt(i32, minutes))));
        // std.debug.print("minutes = {}", .{@bitCast(i32, minutes)});
    }

    const result = [3]i32{ day, @floatToInt(i32, hours), @floatToInt(i32, minutes) };
    return result;
}

fn timeComp(timeArr: [3][2]u8) [2]u32 {
    const hoursNum = c.atoi(&timeArr[0]);
    const minNum = c.atoi(&timeArr[2]);

    const result = [2]u32{ @intCast(u32, hoursNum), @intCast(u32, minNum) };
    return result;
}

// returns the time in minutes
fn getTime(timeArr: [3][2]u8) !f32 {
    const hours_and_mins = timeComp(timeArr);
    const hours = hours_and_mins[0];
    const mins = hours_and_mins[1];

    if (hours < 24 and mins < 60) {
        var time = mins;
        time += hours * 60;

        return @intToFloat(f32, time);
    } else {
        return TimeError.InvalidTime;
    }
}

fn no_use(something: []const u8) void {
    _ = something;
}
