const std = @import("std");

const RuleMap = std.HashMap([]const u8, []const u8, std.hash_map.StringHashFn);

fn readFile(file_name: []const u8) !std.ArrayList([]const u8) {
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var allocator = std.heap.page_allocator;
    var lines = std.ArrayList([]const u8).init(allocator);

    while (true) {
        var line = try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n');
        if (line.len == 0) break;
        try lines.append(line);
    }

    return lines;
}

fn createRuleMap(rules: [][]const u8) RuleMap {
    var allocator = std.heap.page_allocator;
    var map = RuleMap.init(allocator);

    for (rules) |rule| {
        const parts = std.mem.split(rule, "|");
        if (parts.len == 2) {
            map.put(parts[0], parts[1]);
        }
    }

    return map;
}

fn mapUpdates(updates: [][]const u8) [][][]const u8 {
    var allocator = std.heap.page_allocator;
    var result = std.ArrayList([][][]const u8).init(allocator);

    for (updates) |update| {
        if (update.len != 0) {
            var parts = std.mem.split(update, ",");
            try result.append(parts);
        }
    }

    return result.toOwnedSlice();
}

fn checkUpdate(update: [][]const u8, preRules: RuleMap) bool {
    var update_count = update.len;

    for (0..update_count) |pre| {
        for (pre+1..update_count) |post| {
            if (preRules.get(update[post]) == update[pre]) {
                return false;
            }
        }
    }

    return true;
}

fn reorderElements(update: [][]const u8, preRules: RuleMap, postRules: RuleMap) [][]const u8 {
    std.sort.sort(update, std.sort.comparator([]const u8, a, b) {
        if (preRules.get(a) == b) return -1;
        if (postRules.get(b) == a) return 1;
        return 0;
    });

    return update;
}

fn getMiddleElement(update: [][]const u8) i32 {
    return std.fmt.parseInt(i32, update[update.len / 2], 10);
}

pub fn main() !void {
    const file_name = "test-data.txt";
    const rules_updates = try readFile(file_name);
    const rules = rules_updates[0..rules_updates.len / 2];
    const updates = rules_updates[rules_updates.len / 2..];

    const preRules = createRuleMap(rules);
    const postRules = createRuleMap(rules);

    var result = 0;

    for (mapUpdates(updates)) |update| {
        if (!checkUpdate(update, preRules)) {
            result += getMiddleElement(reorderElements(update, preRules, postRules));
        }
    }

    std.debug.print("Result: {}\n", .{result});
}