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
        private string[] functionNameStack;
        public FunctionRange[] functionRanges;

        public this(in string filePath, in string moduleName, in string source)
        {
            this.filePath = filePath;
            this.moduleName = moduleName;
            this.source = source;
        }

        public override void visit(const FunctionDeclaration declaration)
        {
            functionRanges ~= FunctionRange(
                qualifiedName: qualifiedName(declaration.name.text),
                filePath: filePath,
                lineRange: LineRange(
                    firstLine: declaration.name.line,
                    lastLine: declaration.functionBody.tokens.length == 0
                        ? source.lineAt(declaration.functionBody.endLocation)
                        : declaration.functionBody.tokens[$ - 1].line,
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
        source);
    parsedModule.accept(visitor);
    return visitor.functionRanges;
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
