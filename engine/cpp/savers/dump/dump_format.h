#ifndef DUMPFORMAT_H
#define DUMPFORMAT_H

#include "../mol_accumulator.h"
#include "dump_saver.h"

namespace vd
{

class DumpFormat
{
    const DumpSaver &_saver;
    const MolAccumulator &_acc;
public:
    DumpFormat(const DumpSaver &saver, const MolAccumulator &acc) : _saver(saver), _acc(acc) {}

    void render(std::ostream &os, double currentTime) const;

private:
    DumpFormat(const DumpFormat &) = delete;
    DumpFormat(DumpFormat &&) = delete;
    DumpFormat &operator = (const DumpFormat &) = delete;
    DumpFormat &operator = (DumpFormat &&) = delete;
};

}

#endif // DUMPFORMAT_H
