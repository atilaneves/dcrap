module dcrap.metrics;

private:

public struct CrapScoreInput
{
    public int cyclomaticComplexity;
    public double coverage;
}

public struct FunctionScore
{
    public double crapScore;
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
