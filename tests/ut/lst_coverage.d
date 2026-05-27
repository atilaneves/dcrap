module ut.lst_coverage;

import ut;

@("DMD LST parser classifies actual generated coverage lines")
unittest
{
    import std.file : exists, mkdirRecurse, readText, rmdirRecurse, tempDir,
        write;
    import std.path : buildPath;
    import std.process : Config, execute;
    import std.string : outdent, stripRight;

    const testDirectory = buildPath(tempDir, "dcrap-lst-coverage-test");
    if (testDirectory.exists) {
        testDirectory.rmdirRecurse;
    }
    testDirectory.mkdirRecurse;
    scope (exit) {
        if (testDirectory.exists) {
            testDirectory.rmdirRecurse;
        }
    }

    const source = q{module sample;

        int covered()
        {
            return 1;
        }

        int uncovered()
        {
            return 2;
        }

        void main()
        {
            covered;
        }
    }.outdent.stripRight;
    const sourceFile = "sample.d";
    buildPath(testDirectory, sourceFile).write(source);

    execute(["dmd", "-cov", sourceFile], null, Config.none, size_t.max,
        testDirectory).status.should == 0;
    execute(["./sample"], null, Config.none, size_t.max, testDirectory)
        .status.should == 0;

    const coverageText = buildPath(testDirectory, "sample.lst").readText;
    auto coverageLines = coverageText.parseLstCoverage;

    coverageLines.should == [
        LstCoverageLine(1, LstLineKind.nonExecutable, 0),
        LstCoverageLine(2, LstLineKind.nonExecutable, 0),
        LstCoverageLine(3, LstLineKind.nonExecutable, 0),
        LstCoverageLine(4, LstLineKind.nonExecutable, 0),
        LstCoverageLine(5, LstLineKind.covered, 1),
        LstCoverageLine(6, LstLineKind.nonExecutable, 0),
        LstCoverageLine(7, LstLineKind.nonExecutable, 0),
        LstCoverageLine(8, LstLineKind.nonExecutable, 0),
        LstCoverageLine(9, LstLineKind.nonExecutable, 0),
        LstCoverageLine(10, LstLineKind.uncovered, 0),
        LstCoverageLine(11, LstLineKind.nonExecutable, 0),
        LstCoverageLine(12, LstLineKind.nonExecutable, 0),
        LstCoverageLine(13, LstLineKind.nonExecutable, 0),
        LstCoverageLine(14, LstLineKind.nonExecutable, 0),
        LstCoverageLine(15, LstLineKind.covered, 1),
        LstCoverageLine(16, LstLineKind.nonExecutable, 0),
    ];
}
