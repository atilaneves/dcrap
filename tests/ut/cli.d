module ut.cli;

import ut;

@("analyze-only options use canonical CRAP failure threshold by default")
unittest {
    import dcrap.cli : parseAnalyzeOnlyOptions;

    const options = ["dcrap"].parseAnalyzeOnlyOptions;

    options.threshold.should == 30.0;
}
