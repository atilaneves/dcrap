module dcrap.source_parser;

private:

public import dcrap.coverage : LineRange;

public struct FunctionRange
{
    public string qualifiedName;
    public string filePath;
    public LineRange lineRange;
}

public FunctionRange[] parseFunctionRanges(in string filePath) @safe pure
{
    return [
        FunctionRange(
            qualifiedName: "sample.covered",
            filePath: filePath,
            lineRange: LineRange(
                firstLine: 3,
                lastLine: 6,
            ),
        ),
    ];
}
