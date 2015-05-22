#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../../phases/saving_amorph.h"
#include "../../phases/saving_crystal.h"
#include "../../savers/detector.h"
#include <fstream>

#include "../bundle_saver.h"
#include "../many_files.h"
#include "../mol_accumulator.h"
#include "dump_format.h"

namespace vd {

class DumpSaver : public ManyFiles<BundleSaver<MolAccumulator, DumpFormat>>
{
public:
    explicit DumpSaver(uint x, uint y, const char *name): ManyFiles(x, y, name) {}

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
