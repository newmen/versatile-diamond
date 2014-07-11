#ifndef MOL_SAVER_H
#define MOL_SAVER_H

#include "many_files.h"
#include "mol_accumulator.h"
#include "mol_format.h"
#include "bundle_saver.h"

namespace vd
{

class MolSaver : public ManyFiles<BundleSaver<MolAccumulator, MolFormat>>
{
public:
    MolSaver(const char *name) : ManyFiles(name) {}

protected:
    const char *ext() const override;

};

}

#endif // MOL_SAVER_H
