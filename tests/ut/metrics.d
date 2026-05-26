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
