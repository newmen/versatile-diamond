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
    explicit MolSaver(const char *name) : ManyFiles(name) {}

protected:
    const char *ext() const override;

private:
    MolSaver(const MolSaver &) = delete;
    MolSaver(MolSaver &&) = delete;
    MolSaver &operator = (const MolSaver &) = delete;
    MolSaver &operator = (MolSaver &&) = delete;
};

}

#endif // MOL_SAVER_H
