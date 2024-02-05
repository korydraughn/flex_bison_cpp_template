#include "project_template/driver.hpp"

#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <iterator>
#include <stdexcept>

int main(int _argc, char* _argv[])
{
    namespace pt = project_template;

    try {
        pt::driver driver;
        int ec = 0;

        if (_argc == 2 && std::filesystem::is_regular_file(_argv[1])) {
            std::ifstream in{_argv[1]};

            std::string code;
            std::string line;

            while (std::getline(in, line)) {
                code += line;
            }

            //std::cout << "code => " << code << '\n';
            ec = driver.parse(code);
        }
        else {
            ec = driver.parse(_argv[1]);
        }

        std::cout << ec << '\n';
    }
    catch (const std::exception& e) {
        std::cerr << "error: " << e.what() << '\n';
    }

    return 0;
}
