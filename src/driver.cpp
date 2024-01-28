#include "project_template/driver.hpp"

#include <sstream>

namespace project_template
{
    auto driver::parse(const std::string& _s) -> int
    {
        location.initialize();

        std::istringstream iss{_s};
        lexer.switch_streams(&iss);

        yy::parser p{*this};
        return p.parse();
    } // driver::parse
} // namespace project_template
