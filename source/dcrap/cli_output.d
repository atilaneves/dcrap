module dcrap.cli_output;

private:

public struct AnalyzeOnlyRow
{
    public string qualifiedName;
    public string filePath;
    public string lineRange;
    public string cyclomaticComplexity;
    public string coveredLines;
    public string executableLines;
    public string coveragePercent;
    public string crapScore;
}

public AnalyzeOnlyRow[] analyzeOnlyRows(
    in imported!"dcrap.metrics".FunctionScore[] scores,
) @safe
{
    AnalyzeOnlyRow[] rows;

    foreach (const score; scores) {
        rows ~= score.analyzeOnlyRow;
    }

    return rows;
}

private AnalyzeOnlyRow analyzeOnlyRow(
    in imported!"dcrap.metrics".FunctionScore score,
) @safe
{
    import std.conv : text;
    import std.format : format;

    return AnalyzeOnlyRow(
        qualifiedName: score.qualifiedName,
        filePath: score.filePath,
        lineRange: text(score.lineRange.firstLine, "-", score.lineRange.lastLine),
        cyclomaticComplexity: text(score.cyclomaticComplexity),
        coveredLines: text(score.coveredLines),
        executableLines: text(score.executableLines),
        coveragePercent: "%.2f%%".format(score.coverage * 100),
        crapScore: "%.2f".format(score.crapScore),
    );
}
