#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "mol_saver.h"
#include <sstream>

namespace vd
{

template <class D>
class SdfSaver : public MolSaver<D>
{
    std::ofstream _out;

public:
    SdfSaver(const char *name);

    void writeFrom(Atom *atom, double currentTime) override;

protected:
    const char *ext() const override;
    std::string filename() const override;
};

//////////////////////////////////////////////////////////////////////

template <class D>
SdfSaver<D>::SdfSaver(const char *name) : MolSaver<D>(name), _out(filename())
{
}

template <class D>
void SdfSaver<D>::writeFrom(Atom *atom, double currentTime)
{
    static uint counter = 0;
    if (counter > 0)
    {
        _out << "$$$$" << "\n";
    }
    ++counter;

    this->writeToFrom(_out, atom, currentTime);
}

template <class D>
const char *SdfSaver<D>::ext() const
{
    static const char value[] = ".sdf";
    return value;
}

template <class D>
std::string SdfSaver<D>::filename() const
{
    std::stringstream ss;
    ss << this->name() << ext();
    return ss.str();
}

}

#endif // SDF_SAVER_H
