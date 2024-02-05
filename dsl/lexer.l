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

[ \t]+                 loc.step();
\n+                    loc.lines(YYLeng()); loc.step();
import                 return yy::parser::make_IMPORT(loc);
defer                  return yy::parser::make_DEFER(loc);
var                    return yy::parser::make_VAR(loc);
const                  return yy::parser::make_CONST(loc);
if                     return yy::parser::make_IF(loc);
else                   return yy::parser::make_ELSE(loc);
loop                   return yy::parser::make_LOOP(loc);
break                  return yy::parser::make_BREAK(loc);
continue               return yy::parser::make_CONTINUE(loc);
fn                     return yy::parser::make_FN(loc);
return                 return yy::parser::make_RETURN(loc);
";"                    return yy::parser::make_SEMICOLON(loc);
","                    return yy::parser::make_COMMA(loc);
"("                    return yy::parser::make_LPAREN(loc);
")"                    return yy::parser::make_RPAREN(loc);
"{"                    return yy::parser::make_LBRACE(loc);
"}"                    return yy::parser::make_RBRACE(loc);
"="                    return yy::parser::make_OP_ASSIGNMENT(loc);
"=="                   return yy::parser::make_OP_EQUALITY(loc);
"!="                   return yy::parser::make_OP_NOT_EQUAL(loc);
">="                   return yy::parser::make_OP_GREATER_THAN_OR_EQUAL(loc);
">"                    return yy::parser::make_OP_GREATER_THAN(loc);
"<="                   return yy::parser::make_OP_LESS_THAN_OR_EQUAL(loc);
"<"                    return yy::parser::make_OP_LESS_THAN(loc);
-?[0-9]+               return yy::parser::make_INTEGER(YYText(), loc);
[_a-zA-Z][a-zA-Z0-9_]* return yy::parser::make_IDENTIFIER(YYText(), loc);
.                      throw yy::parser::syntax_error{loc, std::string{"bad character: "} + YYText()};
<<EOF>>                return yy::parser::make_END_OF_INPUT(loc);

%%
