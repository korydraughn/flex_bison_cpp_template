%skeleton "lalr1.cc" /* Enables C++ */
%require "3.0" /* position.hh and stack.hh are deprecated in 3.2 and later. */
%language "C++" /* Redundant? */
%defines /* Doesn't work in version 3.0 - %header */

/* The name of the parser class. Defaults to "parser" in C++. */
/* %define api.parser.class { parser } */

/*
Request that symbols be handled as a whole (type, value, and possibly location)
in the scanner. In C++, only works when variant-based semantic values are enabled.
This option causes make_* functions to be generated for each token kind.
*/
%define api.token.constructor 

/* The type used for semantic values. */
%define api.value.type variant

/* Enables runtime assertions to catch invalid uses. In C++, detects improper use of variants. */
%define parse.assert

%define parse.trace
%define parse.error verbose /* Can produce incorrect information if LAC is not enabled. */

/* An argument passed to both the lexer and the parser. */
%param {project_template::driver& drv}

%locations

/* Code to be included in the parser's header and implementation file. */
%code provides {
    #undef YY_DECL

    #define YY_DECL \
        yy::parser::symbol_type project_template::scanner::yylex(project_template::driver& drv)
}

/* Code to be included in the parser's implementation file. */
%code requires {
    #include <string>
    #include <variant>
    #include <vector>

    // TODO This appears to work, but perhaps it would be better to include the driver.hpp header?
    namespace project_template
    {
        class driver;
    } // namespace project_template

    namespace pt = project_template;
}

%code {
    #include "project_template/driver.hpp"

    auto yylex(project_template::driver&) -> yy::parser::symbol_type;
}

%define api.token.prefix {PROJECT_TEMPLATE_}
%token
    DEFER
    SEMICOLON ";"
    COMMA ","
    IMPORT
    VAR
    CONST
    FN
    RETURN
    IF
    ELSE
    LOOP
    BREAK
    CONTINUE
    OP_ASSIGNMENT "="
    OP_EQUALITY "=="
    OP_NOT_EQUAL "!="
    OP_GREATER_THAN_OR_EQUAL ">="
    OP_GREATER_THAN ">"
    OP_LESS_THAN_OR_EQUAL "<="
    OP_LESS_THAN "<"
    LPAREN "("
    RPAREN ")"
    LBRACE "{"
    RBRACE "}"
;
%token <std::string>
    IDENTIFIER
    INTEGER
;
%token END_OF_INPUT 0

/*
%left is the same as %token, but defines associativity.
%token does not define associativity or precedence.
%precedence does not define associativity.

Operator precedence is determined by the line ordering of the declarations. 
The further down the page the line is, the higher the precedence. For example,
NOT has higher precedence than AND.

While these directives support specifying a semantic type, Bison recommends not
doing that and using these directives to specify precedence and associativity
rules only.
*/
/*
%left OR
%left AND
%precedence NOT
*/

/*
%type <pt::selections> selections;
*/

%start program /* Defines where grammar starts */

%%

program:
    statements
|   %empty
;

statements:
    statement ";" {}
|   statements statement ";" {}
|   statements function_definition {}
|   statements if_stmt {}
|   statements loop {}
|   %empty
;

statement:
    import {}
|   variable_definition {}
|   variable_assignment {}
|   BREAK {}
|   CONTINUE {}
;

import:
    IMPORT name
;

variable_definition:
    VAR name "=" value {}
|   CONST name "=" value {}
;

variable_assignment:
    name "=" value {}
;

name:
    IDENTIFIER {}
;

value:
    INTEGER {}
;

parameters:
    parameter {}
|   parameters "," parameter {}
|   %empty {}
;

parameter:
    IDENTIFIER {}
;

function_definition:
    FN name "(" parameters ")" "{" statements "}" {}
|   FN name "(" parameters ")" "{" statements RETURN ";" "}" {}
|   FN name "(" parameters ")" "{" statements RETURN IDENTIFIER ";" "}" {}
;

if_stmt:
    IF "(" boolean_expression ")" "{" statements "}"
|   IF "(" boolean_expression ")" "{" statements "}" ELSE "{" statements "}"
;

loop:
    LOOP "{" statements "}" {}
;

boolean_expression:
    IDENTIFIER "==" IDENTIFIER {}
|   IDENTIFIER "!=" IDENTIFIER {}
|   IDENTIFIER ">=" IDENTIFIER {}
|   IDENTIFIER ">"  IDENTIFIER {}
|   IDENTIFIER "<=" IDENTIFIER {}
|   IDENTIFIER "<"  IDENTIFIER {}
;

%%

auto yy::parser::error(const yy::location& _loc, const std::string& _msg) -> void
{
    std::string s = _msg;
    s += " at position ";
    s += std::to_string(_loc.begin.column);
    throw std::invalid_argument{s};
} // yy::parser::error

auto yylex(project_template::driver& drv) -> yy::parser::symbol_type
{
    return drv.lexer.yylex(drv);
} // yylex
