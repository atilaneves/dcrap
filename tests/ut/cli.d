module ut.cli;

import ut;

@("analyze-only options use canonical CRAP failure threshold by default")
unittest {
    import dcrap.cli : parseAnalyzeOnlyOptions;

    const options = ["dcrap"].parseAnalyzeOnlyOptions;

    options.threshold.should == 30.0;
}

@("analyze-only options allow overriding the CRAP failure threshold")
unittest {
    import dcrap.cli : parseAnalyzeOnlyOptions;

    const options = ["dcrap", "--threshold", "12.5"].parseAnalyzeOnlyOptions;

    options.threshold.should == 12.5;
}

@("analyze-only gate succeeds when all CRAP scores are within threshold")
unittest {
    import dcrap.cli : analyzeOnlyExitCode;

    const scores = [
        FunctionScore(
            qualifiedName: "sample.ok",
            filePath: "/project/source/sample.d",
            lineRange: LineRange(
                firstLine: 1,
                lastLine: 3,
            ),
            cyclomaticComplexity: 5,
            coveredLines: 1,
            executableLines: 1,
            coverage: 1.0,
            crapScore: 30.0,
        ),
    ];

    scores.analyzeOnlyExitCode(30.0).should == 0;
}
