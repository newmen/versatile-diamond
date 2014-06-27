#include "sdf_saver.h"

namespace vd {

void SdfSaver::writeFrom(Atom *atom, double currentTime, const Detector *detector)
{
    static uint counter = 0;
    if (counter > 0)
    {
        _out << "$$$$" << "\n";
    }
    ++counter;

    this->writeToFrom(_out, atom, currentTime, detector);
}

const char *SdfSaver::ext() const
{
    static const char value[] = ".sdf";
    return value;
}

std::string SdfSaver::filename() const
{
    std::stringstream ss;
    ss << this->name() << ext();
    return ss.str();
}

}
