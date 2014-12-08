#include <iostream>
#include <fstream>

int main() {

    std::ifstream inFile;


    double x;
    inFile.read((char*)&x, sizeof(x));

    std::cout << x;

    return 0;
}
