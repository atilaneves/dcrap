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

public string jsonAnalyzeOnlyOutput(
    in imported!"dcrap.metrics".FunctionScore[] scores,
) @safe
{
    import std.array : appender;
    import std.format : formattedWrite;

    auto output = appender!string;

    output ~= "[";

    foreach (const index, const score; scores) {
        if (index != 0) {
            output ~= ",";
        }

        output ~= `{"qualifiedName":`;
        output ~= score.qualifiedName.jsonString;
        output ~= `,"filePath":`;
        output ~= score.filePath.jsonString;
        output ~= `,"lineRange":{"firstLine":`;
        formattedWrite(output, "%s", score.lineRange.firstLine);
        output ~= `,"lastLine":`;
        formattedWrite(output, "%s", score.lineRange.lastLine);
        output ~= `},"cyclomaticComplexity":`;
        formattedWrite(output, "%s", score.cyclomaticComplexity);
        output ~= `,"coveredLines":`;
        formattedWrite(output, "%s", score.coveredLines);
        output ~= `,"executableLines":`;
        formattedWrite(output, "%s", score.executableLines);
        output ~= `,"coveragePercent":`;
        output ~= (score.coverage * 100).jsonNumber;
        output ~= `,"crapScore":`;
        output ~= score.crapScore.jsonNumber;
        output ~= "}";
    }

    output ~= "]";

    return output.data;
}

private string jsonString(in string value) @safe
{
    import std.array : appender;
    import std.format : formattedWrite;

    auto output = appender!string;

    output ~= `"`;

    foreach (const c; value) {
        switch (c) {
            case '"':
                output ~= `\"`;
                break;

            case '\\':
                output ~= `\\`;
                break;

            case '\b':
                output ~= `\b`;
                break;

            case '\f':
                output ~= `\f`;
                break;

            case '\n':
                output ~= `\n`;
                break;

            case '\r':
                output ~= `\r`;
                break;

            case '\t':
                output ~= `\t`;
                break;

            default:
                if (c < 0x20) {
                    formattedWrite(output, `\u%04X`, cast(uint) c);
                } else {
                    output ~= c;
                }
                break;
        }
    }

    output ~= `"`;

    return output.data;
}

private string jsonNumber(in double value) @safe
{
    import std.algorithm.searching : canFind;
    import std.format : format;

    const formatted = "%.15g".format(value);

    if (formatted.canFind(".")
            || formatted.canFind("e")
            || formatted.canFind("E")) {
        return formatted;
    }

    return formatted ~ ".0";
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
