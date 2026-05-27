module dcrap.coverage;

private:

public import dcrap.lst_coverage : LstCoverageLine;

public struct LineRange
{
    public size_t firstLine;
    public size_t lastLine;
}

public struct CoverageSummary
{
    public size_t coveredLines;
    public size_t executableLines;
}

public double coverageFraction(in CoverageSummary summary) @safe @nogc nothrow pure
{
    if (summary.executableLines == 0) {
        return 0.0;
    }

    return cast(double) summary.coveredLines / summary.executableLines;
}

public CoverageSummary coverageSummary(
    in LineRange range,
    in LstCoverageLine[] coverageLines,
) @safe @nogc nothrow pure
{
    import dcrap.lst_coverage : LstLineKind;

    CoverageSummary summary;

    foreach (const line; coverageLines) {
        if (line.lineNumber < range.firstLine || line.lineNumber > range.lastLine) {
            continue;
        }

        final switch (line.kind) with (LstLineKind) {
            case covered:
                ++summary.coveredLines;
                ++summary.executableLines;
                break;

            case uncovered:
                ++summary.executableLines;
                break;

            case nonExecutable:
                break;
        }
    }

    return summary;
}
