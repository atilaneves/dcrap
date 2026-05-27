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
