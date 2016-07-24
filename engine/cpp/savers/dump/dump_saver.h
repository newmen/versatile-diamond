#ifndef DUMP_SAVER_H
#define DUMP_SAVER_H

#include "../many_files.h"
#include "../volume_saver.h"
#include "../bundle_saver.h"
#include "../mol_accumulator.h"
#include "dump_format.h"

namespace vd {

class DumpSaver : public ManyFiles<BundleSaver<MolAccumulator, DumpFormat>>
{
    uint _x, _y;

public:
    DumpSaver(const char *name, uint x, uint y): ManyFiles(name), _x(x), _y(y) {}

    uint x() const { return _x; }
    uint y() const { return _y; }

private:
    DumpSaver(const DumpSaver &) = delete;
    DumpSaver(DumpSaver &&) = delete;
    DumpSaver &operator = (const DumpSaver &) = delete;
    DumpSaver &operator = (DumpSaver &&) = delete;

    const char *ext() const override;
};

}
#endif // DUMP_SAVER_H
