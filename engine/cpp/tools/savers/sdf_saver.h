#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "one_file.h"
#include "mol_saver.h"

namespace vd
{

class SdfSaver : public OneFile<MolSaver>
{
public:
    SdfSaver(const char *name) : OneFile(name) {}

protected:
    const char *ext() const override;
    const char *separator() const override;
};

}

#endif // SDF_SAVER_H
