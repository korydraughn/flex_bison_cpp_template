%{
    #include "project_template/driver.hpp"

    #include <charconv>
    #include <cstdint>
    #include <string>
%}

%option c++ warn nodefault noyywrap nounput noinput batch

/*
 Informs flex that we've derived a class from yyFlexLexer and its
 name is "scanner". flex will then place the lexer implementation
 into <derived_class>::yylex.
*/
%option yyclass="scanner"

%{
    // Code run each time a pattern is matched.
    #define YY_USER_ACTION loc.columns(YYLeng());
%}

%%

%{
    // A handy shortcut to the location held by the driver.
    auto& loc = drv.location;

    // Code run each time yylex() is called.
    loc.step();
%}

[ \t\n]                ;
var                    return yy::parser::make_VAR(loc);
if                     return yy::parser::make_IF(loc);
";"                    return yy::parser::make_SEMICOLON(loc);
"="                    return yy::parser::make_EQUALS(loc);
-?[0-9]+               return yy::parser::make_INTEGER(YYText(), loc);
[_a-zA-Z][a-zA-Z0-9_]* return yy::parser::make_IDENTIFIER(YYText(), loc);
.                      throw yy::parser::syntax_error{loc, std::string{"bad character: "} + YYText()};
<<EOF>>                return yy::parser::make_END_OF_INPUT(loc);

%%
