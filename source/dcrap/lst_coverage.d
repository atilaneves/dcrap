module dcrap.lst_coverage;

private:

public enum LstLineKind
{
    covered,
    uncovered,
    nonExecutable,
}

public struct LstCoverageLine
{
    public size_t lineNumber;
    public LstLineKind kind;
    public ulong count;
}

public LstCoverageLine[] parseLstCoverage(in string coverageText) @safe pure
{
    import std.algorithm : all;
    import std.array : appender;
    import std.conv : to;
    import std.string : lineSplitter, strip;

    enum coveragePrefixWidth = 7;
    auto lines = appender!(LstCoverageLine[]);
    size_t lineNumber;

    foreach (const line; coverageText.lineSplitter) {
        if (line.length <= coveragePrefixWidth
            || line[coveragePrefixWidth] != '|')
        {
            continue;
        }

        ++lineNumber;
        const prefix = line[0 .. coveragePrefixWidth];
        if (prefix.all!(character => character == ' ')) {
            lines ~= LstCoverageLine(
                lineNumber,
                LstLineKind.nonExecutable,
                0,
            );
        } else if (prefix == "0000000") {
            lines ~= LstCoverageLine(
                lineNumber,
                LstLineKind.uncovered,
                0,
            );
        } else {
            lines ~= LstCoverageLine(
                lineNumber,
                LstLineKind.covered,
                prefix.strip.to!ulong,
            );
        }
    }

    return lines.data;
}

