#ifndef DUMPFORMAT_H
#define DUMPFORMAT_H

#include "../mol_accumulator.h"
#include "../volume_saver.h"

namespace vd
{

template <class S>
class DumpFormat
{
    const S &_saver;
    const MolAccumulator &_acc;
public:
    DumpFormat(const VolumeSaver &saver, const MolAccumulator &acc) : _saver(saver), _acc(acc) {}

    void render(std::ostream &os, double currentTime) const;

    const S &saver() const { return _saver; }
    const MolAccumulator &acc() const { return _acc; }

private:
    DumpFormat(const DumpFormat &) = delete;
    DumpFormat(DumpFormat &&) = delete;
    DumpFormat &operator = (const DumpFormat &) = delete;
    DumpFormat &operator = (DumpFormat &&) = delete;
};

}

#endif // DUMPFORMAT_H
