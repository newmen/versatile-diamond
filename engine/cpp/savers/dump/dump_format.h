#ifndef DUMPFORMAT_H
#define DUMPFORMAT_H

#include "../format.h"
#include "../mol_accumulator.h"

namespace vd
{

class DumpFormat : public Format<MolAccumulator>
{
public:
    DumpFormat(const VolumeSaver &saver, const MolAccumulator &acc) : Format(saver, acc) {}

    void render(std::ostream &os, double currentTime) const;

private:
    DumpFormat(const DumpFormat &) = delete;
    DumpFormat(DumpFormat &&) = delete;
    DumpFormat &operator = (const DumpFormat &) = delete;
    DumpFormat &operator = (DumpFormat &&) = delete;
};

}

#endif // DUMPFORMAT_H
