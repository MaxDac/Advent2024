using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

class Day5
{
    private const string RuleDivider = "|";
    private const string UpdatesDivider = ",";

    static void Main(string[] args)
    {
        var result = Part1("test-data");
        Console.WriteLine(result);
    }

    public static int Part1(string fileName = "test-data")
    {
        var (rules, updates) = ReadFile(fileName);
        var (preRules, postRules) = MapRules(rules);

        return updates
            .Select(MapUpdates)
            .Where(x => !CheckUpdate(x, preRules))
            .Select(x => ReorderElements(x, preRules, postRules))
            .Select(GetMiddleElement)
            .Sum();
    }

    private static (List<string>, List<string>) ReadFile(string fileName)
    {
        var lines = File.ReadAllLines($"./lib/{fileName}.txt").Select(line => line.Trim()).ToList();
        var splitIndex = lines.IndexOf("");
        return (lines.Take(splitIndex).ToList(), lines.Skip(splitIndex + 1).ToList());
    }

    private static (Dictionary<string, List<string>>, Dictionary<string, List<string>>) MapRules(List<string> rules)
    {
        var preRule = new List<(string, string)>();
        var postRule = new List<(string, string)>();

        foreach (var rule in rules)
        {
            var parts = rule.Split(RuleDivider);
            preRule.Add((parts[0], parts[1]));
            postRule.Add((parts[1], parts[0]));
        }

        return (CreateRuleMap(preRule), CreateRuleMap(postRule));
    }

    private static Dictionary<string, List<string>> CreateRuleMap(List<(string, string)> rules)
    {
        var map = new Dictionary<string, List<string>>();
        foreach (var (key, ruleItem) in rules)
        {
            if (!map.ContainsKey(key))
            {
                map[key] = new List<string>();
            }
            map[key].Add(ruleItem);
        }
        return map;
    }

    private static List<string> MapUpdates(string update)
    {
        return update.Split(UpdatesDivider).ToList();
    }

    private static bool CheckUpdate(List<string> update, Dictionary<string, List<string>> preRules)
    {
        var updateCount = update.Count;
        var indexes = from pre in Enumerable.Range(0, updateCount)
                      from post in Enumerable.Range(0, updateCount)
                      where pre < post
                      select (update[pre], update[post]);

        foreach (var (pre, post) in indexes)
        {
            if (preRules.ContainsKey(post))
            {
                var pres = preRules[post];
                if (pres.Contains(pre))
                {
                    return false;
                }
            }
        }
        return true;
    }

    public static List<string> ReorderElements(List<string> update, Dictionary<string, List<string>> preRules, Dictionary<string, List<string>> postRules)
    {
        return update.OrderBy(a =>
        {
            if (preRules.ContainsKey(a))
            {
                return preRules[a].Contains(a) ? -1 : 1;
            }
            if (postRules.ContainsKey(a))
            {
                return postRules[a].Contains(a) ? 1 : -1;
            }
            return 0;
        }).ToList();
    }

    private static int GetMiddleElement(List<string> update)
    {
        return int.Parse(update[update.Count / 2]);
    }
}