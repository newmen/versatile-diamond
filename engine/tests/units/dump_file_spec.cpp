#include <iostream>
#include <istream>
#include <fstream>
#include "../../cpp/tools/common.h"

int main() {

    std::ifstream inFile("/home/Kindnes/projects/versatile-diamond/engine/build-engine-Desktop-Debug/end_version-5x5-0.2s_0.dump");

    vd::uint x, y;
    inFile.read((char*)&x, sizeof(x));
    inFile.read((char*)&y, sizeof(y));
    std::cout << "sizes x: " << x << " y: " << y << std::endl;

    double curTime;
    inFile.read((char*)&curTime, sizeof(curTime));
    std::cout << "current time: " << curTime << std::endl;

    vd::uint amorphNum;
    inFile.read((char*)&amorphNum, sizeof(amorphNum));
    std::cout << "amorph num: " << amorphNum << std::endl;

    for (int i = 0; i < amorphNum; i++)
    {
        vd::uint ind;
        vd::ushort type, noBonds;

        inFile.read((char*)&ind, sizeof(ind));
        inFile.read((char*)&type, sizeof(type));

        char buff[225];
        char c;
        int j = 0;
        do {
            inFile.get(c);
            buff[j++] = c;
        }
        while (c);
        std::string name(buff);

        inFile.read((char*)&noBonds, sizeof(noBonds));

        std::cout << "index: " << ind << " type: " << type << " name: " << name << " noBonds:" << noBonds << std::endl;
    }

    vd::uint crystalNum;
    inFile.read((char*)&crystalNum, sizeof(crystalNum));
    std::cout << "crystal num: " << crystalNum << std::endl;

    for (int i = 0; i < crystalNum; i++)
    {
        vd::uint ind;
        vd::ushort type, noBonds;
        vd::int3 crd;

        inFile.read((char*)&ind, sizeof(ind));
        inFile.read((char*)&type, sizeof(type));

        char buff[225];
        char c;
        int j = 0;
        do {
            inFile.get(c);
            buff[j++] = c;
        }
        while (c);
        std::string name(buff);

        inFile.read((char*)&noBonds, sizeof(noBonds));
        inFile.read((char*)&crd, sizeof(crd));

        std::cout << "index: " << ind
                  << " type: " << type
                  << " name: " << name
                  << " no bonds: " << noBonds
                  << " coord: " << crd
                  << std::endl;
    }

    vd::uint bondsNum;
    inFile.read((char*)&bondsNum, sizeof(bondsNum));
    std::cout << "bonds num : " << bondsNum << std::endl;

    for (int i = 0; i < amorphNum + crystalNum; i++)
    {
        vd::uint from, to;
        inFile.read((char*)&from, sizeof(from));
        inFile.read((char*)&to, sizeof(to));
        std::cout << "bond from : " << from << " bond to : " << to << std::endl;
    }

    return 0;
}
