module dcrap.cli;

private:

public struct AnalyzeOnlyOptions
{
    public double threshold;
}

public AnalyzeOnlyOptions parseAnalyzeOnlyOptions(
    in string[] args,
) @safe @nogc nothrow pure
{
    return AnalyzeOnlyOptions(
        threshold: 30.0,
    );
}
