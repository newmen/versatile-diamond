#include "sdf_saver.h"
#include <sstream>

namespace vd
{

SdfSaver::SdfSaver(const char *name) : MolSaver(name), _out(filename())
{
}

void SdfSaver::writeFrom(Atom *atom, double currentTime)
{
    static uint counter = 0;
    if (counter > 0)
    {
        _out << "$$$$" << "\n";
    }
    ++counter;

    writeToFrom(_out, atom, currentTime);
}

const char *SdfSaver::ext() const
{
    static const char value[] = ".sdf";
    return value;
}

std::string SdfSaver::filename() const
{
    std::stringstream ss;
    ss << name() << ext();
    return ss.str();
}

}
