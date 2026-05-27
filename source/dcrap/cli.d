module dcrap.cli;

private:

public struct AnalyzeOnlyOptions
{
    public double threshold;
}

public AnalyzeOnlyOptions parseAnalyzeOnlyOptions(
    in string[] args,
) @safe @nogc nothrow pure
{
    enum defaultThreshold = 30.0;
    auto threshold = defaultThreshold; // Reassigned when an override is present.

    foreach (const index, const arg; args) {
        if (arg == "--threshold" && index + 1 < args.length) {
            threshold = args[index + 1].parseThresholdValue(defaultThreshold);
        }
    }

    return AnalyzeOnlyOptions(
        threshold: threshold,
    );
}

private double parseThresholdValue(
    in string value,
    in double fallback,
) @safe @nogc nothrow pure
{
    auto threshold = 0.0; // Built incrementally from digits.
    auto divisor = 1.0; // Tracks fractional decimal places.
    auto foundDigit = false;
    auto foundDecimalPoint = false;

    foreach (const digit; value) {
        if (digit == '.' && !foundDecimalPoint) {
            foundDecimalPoint = true;
            continue;
        }

        if (digit < '0' || digit > '9') {
            return fallback;
        }

        foundDigit = true;
        const valueDigit = cast(double) (digit - '0');

        if (foundDecimalPoint) {
            divisor *= 10.0;
            threshold += valueDigit / divisor;
        } else {
            threshold *= 10.0;
            threshold += valueDigit;
        }
    }

    if (!foundDigit) {
        return fallback;
    }

    return threshold;
}

public int analyzeOnlyExitCode(
    in imported!"dcrap.metrics".FunctionScore[] scores,
    in double threshold,
) @safe @nogc nothrow pure
{
    import dcrap.metrics : failsThreshold;

    foreach (const score; scores) {
        if (score.failsThreshold(threshold)) {
            return 1;
        }
    }

    return 0;
}
