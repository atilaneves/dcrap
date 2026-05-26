module ut.metrics;

import ut;

@("CRAP score is exactly cyclomatic complexity with full coverage")
unittest
{
    const scoreInput = CrapScoreInput(
        cyclomaticComplexity: 5,
        coverage: 1.0,
    );

    scoreInput.crapScore.should == scoreInput.cyclomaticComplexity;
}

@("CRAP score is cyclomatic complexity squared plus itself with no coverage")
unittest
{
    const scoreInput = CrapScoreInput(
        cyclomaticComplexity: 5,
        coverage: 0.0,
    );

    scoreInput.crapScore.should == 30.0;
}

@("CRAP score applies the canonical formula with partial coverage")
unittest
{
    const scoreInput = CrapScoreInput(
        cyclomaticComplexity: 4,
        coverage: 0.5,
    );

    scoreInput.crapScore.should == 6.0;
}

@("function score fails threshold only when CRAP score is greater than threshold")
unittest
{
    const threshold = 30.0;
    const scoreAtThreshold = FunctionScore(crapScore: threshold);
    const scoreAboveThreshold = FunctionScore(crapScore: threshold + 0.1);

    scoreAtThreshold.failsThreshold(threshold).should == false;
    scoreAboveThreshold.failsThreshold(threshold).should == true;
}

@("function score carries source identity, coverage, complexity, and CRAP")
unittest
{
    import std.path : absolutePath;

    immutable sandbox = Sandbox();
    sandbox.writeFile("source/sample.d");
    const filePath = sandbox.inSandboxPath("source/sample.d").absolutePath;

    const input = FunctionScoreInput(
        qualifiedName: "sample.covered",
        filePath: filePath,
        lineRange: LineRange(
            firstLine: 3,
            lastLine: 6,
        ),
        cyclomaticComplexity: 4,
        coverage: CoverageSummary(
            coveredLines: 1,
            executableLines: 2,
        ),
    );

    input.scoreFunction.should == FunctionScore(
        qualifiedName: "sample.covered",
        filePath: filePath,
        lineRange: LineRange(
            firstLine: 3,
            lastLine: 6,
        ),
        cyclomaticComplexity: 4,
        coveredLines: 1,
        executableLines: 2,
        coverage: 0.5,
        crapScore: 6.0,
    );
}
