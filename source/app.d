module app;

private:

public int main(in string[] args)
{
    try {
        args.run;
    } catch (Exception) {
        return 1;
    } catch (Error) {
        return 2;
    }

    return 0;
}

public void run(Args)(in Args args)
{
    import dcrap.cli : analyzeOnlyExitCode, parseAnalyzeOnlyOptions;
    import dcrap.metrics : FunctionScore;
    import std.exception : enforce;

    const options = args.parseAnalyzeOnlyOptions;
    const scores = [
        FunctionScore(crapScore: 1.0),
    ];

    enforce(
        scores.analyzeOnlyExitCode(options.threshold) == 0,
        "CRAP threshold exceeded",
    );
}
