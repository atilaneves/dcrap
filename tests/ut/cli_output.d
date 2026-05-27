module ut.cli_output;

import ut;

@("analyze-only rows expose scored function audit fields")
unittest
{
    import dcrap.coverage : LineRange;
    import dcrap.metrics : FunctionScore;
    import dcrap.cli_output : analyzeOnlyRows;

    const scores = [
        FunctionScore(
            qualifiedName: "sample.risky",
            filePath: "/project/source/sample.d",
            lineRange: LineRange(
                firstLine: 3,
                lastLine: 8,
            ),
            cyclomaticComplexity: 5,
            coveredLines: 1,
            executableLines: 2,
            coverage: 0.5,
            crapScore: 20.625,
        ),
    ];

    const rows = scores.analyzeOnlyRows;

    rows.length.should == 1;

    const row = rows[0];
    row.qualifiedName.should == "sample.risky";
    row.filePath.should == "/project/source/sample.d";
    row.lineRange.should == "3-8";
    row.cyclomaticComplexity.should == "5";
    row.coveredLines.should == "1";
    row.executableLines.should == "2";
    row.coveragePercent.should == "50.00%";
    row.crapScore.should == "20.62";
}
