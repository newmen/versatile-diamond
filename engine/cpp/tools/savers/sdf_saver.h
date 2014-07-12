#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "one_file.h"
#include "mol_accumulator.h"
#include "mol_format.h"
#include "bundle_saver.h"

namespace vd
{

class SdfSaver : public OneFile<BundleSaver<MolAccumulator, MolFormat>>
{
public:
    SdfSaver(const char *name) : OneFile(name) {}

protected:
    const char *ext() const override;
    std::string separator() const;
};

}

#endif // SDF_SAVER_H
