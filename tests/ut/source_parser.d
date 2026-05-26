module ut.source_parser;

import ut;

@("source parser discovers module-level function ranges")
unittest
{
    import dcrap.source_parser : FunctionRange, parseFunctionRanges;
    import std.path : absolutePath;
    import std.string : outdent, stripRight;

    immutable sandbox = Sandbox();
    sandbox.writeFile("source/sample.d", q{module sample;

        int covered()
        {
            return 1;
        }
    }.outdent.stripRight);

    const filePath = sandbox.inSandboxPath("source/sample.d").absolutePath;

    filePath.parseFunctionRanges.should == [
        FunctionRange(
            qualifiedName: "sample.covered",
            filePath: filePath,
            lineRange: LineRange(
                firstLine: 3,
                lastLine: 6,
            ),
        ),
    ];
}
