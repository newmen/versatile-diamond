#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "mol_saver.h"

namespace vd
{

class SdfSaver : public MolSaver
{
    std::ofstream _out;

public:
    SdfSaver(const char *name);

    void writeFrom(Atom *atom) override;

protected:
    const char *ext() const override;
    std::string filename() const override;
};

}

#endif // SDF_SAVER_H
