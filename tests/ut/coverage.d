module ut.coverage;

import ut;

@("coverage summary counts only executable lines inside an inclusive range")
unittest
{
    const coverageLines = [
        LstCoverageLine(1, LstLineKind.covered, 1),
        LstCoverageLine(2, LstLineKind.nonExecutable, 0),
        LstCoverageLine(3, LstLineKind.uncovered, 0),
        LstCoverageLine(4, LstLineKind.covered, 1),
    ];
    const lineRange = LineRange(
        firstLine: 2,
        lastLine: 4,
    );

    lineRange.coverageSummary(coverageLines).should == CoverageSummary(
        coveredLines: 1,
        executableLines: 2,
    );
}

@("coverage fraction is zero when there are no executable lines")
unittest
{
    const summary = CoverageSummary(
        coveredLines: 0,
        executableLines: 0,
    );

    summary.coverageFraction.should == 0.0;
}
