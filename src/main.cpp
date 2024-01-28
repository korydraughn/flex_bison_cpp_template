#include "project_template/driver.hpp"

#include <iostream>
#include <stdexcept>

int main(int _argc, char* _argv[])
{
    namespace pt = project_template;

    try {
        pt::driver driver;
        const auto ec = driver.parse(_argv[1]);
        std::cout << ec << '\n';
    }
    catch (const std::exception& e) {
        std::cerr << "error: " << e.what() << '\n';
    }

    return 0;
}
