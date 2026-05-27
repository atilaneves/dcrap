module dcrap.metrics;

private:

public import dcrap.coverage : CoverageSummary, LineRange;

public struct CrapScoreInput
{
    public int cyclomaticComplexity;
    public double coverage;
}

public struct FunctionScoreInput
{
    public string qualifiedName;
    public string filePath;
    public LineRange lineRange;
    public int cyclomaticComplexity;
    public CoverageSummary coverage;
}

public struct FunctionScore
{
    public string qualifiedName;
    public string filePath;
    public LineRange lineRange;
    public int cyclomaticComplexity;
    public size_t coveredLines;
    public size_t executableLines;
    public double coverage;
    public double crapScore;
}

public FunctionScore scoreFunction(in FunctionScoreInput input) @safe @nogc nothrow pure
{
    import dcrap.coverage : coverageFraction;

    const coverage = input.coverage.coverageFraction;

    return FunctionScore(
        input.qualifiedName,
        input.filePath,
        input.lineRange,
        input.cyclomaticComplexity,
        input.coverage.coveredLines,
        input.coverage.executableLines,
        coverage,
        CrapScoreInput(input.cyclomaticComplexity, coverage).crapScore,
    );
}

public bool failsThreshold(in FunctionScore score, in double threshold)
    @safe @nogc nothrow pure
{
    return score.crapScore > threshold;
}

public double crapScore(in CrapScoreInput input) @safe @nogc nothrow pure
{
    const uncovered = 1.0 - input.coverage;

    return input.cyclomaticComplexity ^^ 2 * uncovered ^^ 3
        + input.cyclomaticComplexity;
}
