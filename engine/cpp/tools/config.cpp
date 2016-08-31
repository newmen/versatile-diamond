#include "config.h"
#include <sstream>

namespace vd
{

std::string Config::filename() const
{
    std::stringstream ss;
    ss << _name << "-" << _sizeX << "x" << _sizeY << "-" << _totalTime << "s";
    return ss.str();
}

}
