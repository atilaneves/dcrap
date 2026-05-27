module ut.source_parser;

import ut;

@("source parser discovers module-level function ranges")
unittest
{
    import dcrap.source_parser : FunctionRange, parseFunctionRanges;

    const sandbox = Sandbox();
    with (sandbox) {
        const filePath = sandbox.writeDFile("source/sample.d", q{module sample;

            int covered()
            {
                return 1;
            }
        });

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
}

@("source parser derives module name, function name, and range from source")
unittest
{
    import dcrap.source_parser : FunctionRange, parseFunctionRanges;

    const sandbox = Sandbox();
    with (sandbox) {
        const filePath = sandbox.writeDFile("source/other.d", q{module audit.sample;

            int changed(int value)
            {
                if (value > 0) {
                    return value;
                }

                return 0;
            }
        });

        filePath.parseFunctionRanges.should == [
            FunctionRange(
                qualifiedName: "audit.sample.changed",
                filePath: filePath,
                lineRange: LineRange(
                    firstLine: 3,
                    lastLine: 10,
                ),
            ),
        ];
    }
}

@("source parser discovers named nested function ranges")
unittest
{
    import dcrap.source_parser : FunctionRange, parseFunctionRanges;

    const sandbox = Sandbox();
    with (sandbox) {
        const filePath = sandbox.writeDFile("source/nested.d", q{module audit.nested;

            #line 4
            int outer()
            {
                #line 7
                int inner()
                {
                    return 1;
                }

                return inner();
            }
        });

        filePath.parseFunctionRanges.should == [
            FunctionRange(
                qualifiedName: "audit.nested.outer",
                filePath: filePath,
                lineRange: LineRange(
                    firstLine: 4,
                    lastLine: 13,
                ),
            ),
            FunctionRange(
                qualifiedName: "audit.nested.outer.inner",
                filePath: filePath,
                lineRange: LineRange(
                    firstLine: 7,
                    lastLine: 10,
                ),
            ),
        ];
    }
}
