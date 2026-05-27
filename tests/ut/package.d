module ut;

public import unit_threaded;
public import dcrap.coverage;
public import dcrap.lst_coverage;
public import dcrap.metrics;

public string dedent(in string source)
{
    import std.string : outdent, stripRight;

    return source.outdent.stripRight;
}

public string writeDFile(
    ref const(Sandbox) sandbox,
    in string fileName,
    in string source,
)
{
    sandbox.writeFile(fileName, source.dedent);
    return sandbox.inSandboxPath(fileName);
}
