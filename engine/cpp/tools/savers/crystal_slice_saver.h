#ifndef CRYSTAL_SLICE_SAVER_H
#define CRYSTAL_SLICE_SAVER_H

#include <fstream>
#include <string>
#include <map>
#include "../../phases/saving_crystal.h"
#include "../common.h"

namespace vd
{

class CrystalSliceSaver
{
    enum : ushort { COLUMN_WIDTH = 12 };

    typedef std::map<ushort, uint> CounterType;

    CounterType _counterProto;
    const std::string _name;
    const uint _sliceMaxNum;

    std::ofstream _out;

public:
    CrystalSliceSaver(const char *name, uint sliceMaxNum, std::initializer_list<ushort> targetTypes);

    void writeBySlicesOf(const SavingCrystal *crystal, double currentTime);

private:
    CrystalSliceSaver(const CrystalSliceSaver &) = delete;
    CrystalSliceSaver(CrystalSliceSaver &&) = delete;
    CrystalSliceSaver &operator = (const CrystalSliceSaver &) = delete;
    CrystalSliceSaver &operator = (CrystalSliceSaver &&) = delete;

    void writeHeader();
    void writeSlice(const CounterType &counter);

    const char *ext() const;
    std::string filename() const;
};

}

#endif // CRYSTAL_SLICE_SAVER_H
