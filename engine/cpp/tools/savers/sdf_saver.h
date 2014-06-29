#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "mol_saver.h"
#include <sstream>

namespace vd
{

class SdfSaver : public MolSaver
{
    std::ofstream _out;

public:
    SdfSaver(const char *name) : MolSaver(name), _out(filename()) {}

    void writeFrom(Atom *atom, double currentTime, const Detector *detector);

protected:
    const char *ext() const override;
    std::string filename() const override;
};

}

#endif // SDF_SAVER_H
