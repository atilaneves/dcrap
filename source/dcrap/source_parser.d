module dcrap.source_parser;

private:

public import dcrap.coverage : LineRange;

public struct FunctionRange
{
    public string qualifiedName;
    public string filePath;
    public LineRange lineRange;
}

public FunctionRange[] parseFunctionRanges(in string filePath)
{
    import std.file : readText;

    return filePath.readText.parseFunctionRanges(filePath);
}

private FunctionRange[] parseFunctionRanges(in string source, in string filePath)
{
    import dparse.ast : ASTVisitor, FunctionDeclaration, Module;
    import dparse.lexer : LexerConfig, StringCache, getTokensForParser;
    import dparse.parser : ParserConfig, parseModule;
    import dparse.rollback_allocator : RollbackAllocator;

    final class FunctionRangeVisitor : ASTVisitor
    {
        public alias visit = ASTVisitor.visit;

        private string filePath;
        private string moduleName;
        private string source;
        private SourceLineMap lineMap;
        private string[] functionNameStack;
        public FunctionRange[] functionRanges;

        public this(
            in string filePath,
            in string moduleName,
            in string source,
            SourceLineMap lineMap,
        )
        {
            this.filePath = filePath;
            this.moduleName = moduleName;
            this.source = source;
            this.lineMap = lineMap;
        }

        public override void visit(const FunctionDeclaration declaration)
        {
            const lastLine = declaration.functionBody.tokens.length == 0
                ? lineMap.logicalLine(
                    source.lineAt(declaration.functionBody.endLocation),
                    declaration.functionBody.endLocation,
                )
                : lineMap.logicalLine(
                    declaration.functionBody.tokens[$ - 1].line,
                    declaration.functionBody.tokens[$ - 1].index,
                );

            functionRanges ~= FunctionRange(
                qualifiedName: qualifiedName(declaration.name.text),
                filePath: filePath,
                lineRange: LineRange(
                    firstLine: lineMap.logicalLine(
                        declaration.name.line,
                        declaration.name.index,
                    ),
                    lastLine: lastLine,
                ),
            );

            functionNameStack ~= declaration.name.text;
            scope (exit) {
                functionNameStack.length = functionNameStack.length - 1;
            }
            declaration.functionBody.accept(this);
        }

        private string qualifiedName(in string functionName)
        {
            import std.array : join;
            import std.conv : text;

            if (functionNameStack.length == 0) {
                return text(moduleName, ".", functionName);
            }

            return text(moduleName, ".", functionNameStack.join("."), ".",
                functionName);
        }
    }

    auto cache = StringCache(StringCache.defaultBucketCount);
    LexerConfig lexerConfig;
    auto tokens = getTokensForParser(source, lexerConfig, &cache);
    RollbackAllocator allocator;
    const Module parsedModule = ParserConfig(tokens, filePath, &allocator)
        .parseModule;

    auto visitor = new FunctionRangeVisitor(filePath, parsedModule.moduleName,
        source, tokens.sourceLineMap);
    parsedModule.accept(visitor);
    return visitor.functionRanges;
}

private struct SourceLineMap
{
    private LineDirective[] directives;

    public size_t logicalLine(in size_t physicalLine, in size_t index) const
    {
        foreach_reverse (directive; directives) {
            if (directive.index < index
                && physicalLine >= directive.physicalNextLine)
            {
                return directive.logicalNextLine + physicalLine
                    - directive.physicalNextLine;
            }
        }

        return physicalLine;
    }
}

private struct LineDirective
{
    public size_t index;
    public size_t physicalNextLine;
    public size_t logicalNextLine;
}

private SourceLineMap sourceLineMap(Tokens)(Tokens tokens)
{
    SourceLineMap lineMap;
    foreach (token; tokens) {
        foreach (trivia; token.leadingTrivia) {
            lineMap.addLineDirective(trivia);
        }
        foreach (trivia; token.trailingTrivia) {
            lineMap.addLineDirective(trivia);
        }
    }

    return lineMap;
}

private void addLineDirective(Trivia)(ref SourceLineMap lineMap, in Trivia trivia)
{
    import dparse.lexer : tok;

    if (trivia.type != tok!"specialTokenSequence") {
        return;
    }

    const logicalNextLine = trivia.text.lineDirectiveLogicalLine;
    if (logicalNextLine == 0) {
        return;
    }

    lineMap.directives ~= LineDirective(
        index: trivia.index,
        physicalNextLine: trivia.line + 1,
        logicalNextLine: logicalNextLine,
    );
}

private size_t lineDirectiveLogicalLine(in string directive)
    @safe @nogc nothrow pure
{
    enum prefix = "#line";
    if (directive.length < prefix.length
        || directive[0 .. prefix.length] != prefix)
    {
        return 0;
    }

    size_t index = prefix.length;
    while (index < directive.length && directive[index].isHorizontalSpace) {
        index++;
    }

    size_t line;
    while (index < directive.length && directive[index].isDigit) {
        line = line * 10 + directive[index] - '0';
        index++;
    }

    return line;
}

private bool isHorizontalSpace(in char value) @safe @nogc nothrow pure
{
    return value == ' ' || value == '\t';
}

private bool isDigit(in char value) @safe @nogc nothrow pure
{
    return value >= '0' && value <= '9';
}

private string moduleName(in imported!"dparse.ast".Module parsedModule)
{
    import std.algorithm : map;
    import std.array : join;

    if (parsedModule.moduleDeclaration is null) {
        return null;
    }

    return parsedModule.moduleDeclaration.moduleName.identifiers
        .map!(identifier => identifier.text)
        .join(".");
}

private size_t lineAt(in string source, in size_t byteOffset) @safe pure
{
    import std.algorithm : count;

    return source[0 .. byteOffset].count('\n') + 1;
}
