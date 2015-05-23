#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../bundle_saver.h"
#include "../many_files.h"
#include "../mol_accumulator.h"
#include "dump_format.h"

namespace vd {

class DumpSaver : public ManyFiles<BundleSaver<MolAccumulator, DumpFormat>>
{
public:
    explicit DumpSaver(const char *name, uint x, uint y): ManyFiles(name, x, y) {}

protected:
    const char *ext() const override;

private:
    DumpSaver(const DumpSaver &) = delete;
    DumpSaver(DumpSaver &&) = delete;
    DumpSaver &operator = (const DumpSaver &) = delete;
    DumpSaver &operator = (DumpSaver &&) = delete;
};

}
#endif // DUMP_SAVER_H
