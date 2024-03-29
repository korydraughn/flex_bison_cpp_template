#ifndef PROJECT_TEMPLATE_DRIVER_HPP
#define PROJECT_TEMPLATE_DRIVER_HPP

#include "project_template/scanner.hpp"

#include "parser.hpp" // Generated by Bison.

#ifndef yyFlexLexerOnce
#  include <FlexLexer.h>
#endif // yyFlexLexerOnce

#include <string>

namespace project_template
{
    class driver
    {
    public:
        driver() = default;

        auto parse(const std::string& _s) -> int;

        // The AST generated by the parser.
        // TODO Needs AST member variables.

        // The Flex scanner implementation.
        scanner lexer;

        // Holds the current location of the parser.
        yy::location location;
    }; // class driver
} // namespace project_template

#endif // PROJECT_TEMPLATE_DRIVER_HPP
