#ifndef CRYSTAL_SLICE_SAVER_H
#define CRYSTAL_SLICE_SAVER_H

#include <fstream>
#include <string>
#include <map>
#include "../../phases/crystal.h"
#include "../common.h"

namespace vd
{

class CrystalSliceSaver
{
    enum : ushort { COLUMN_WIDTH = 8 };

    typedef std::map<ushort, uint> CounterType;

    CounterType _counterProto;
    const std::string _name;
    const uint _sliceMaxNum;

    std::ofstream _out;

public:
    CrystalSliceSaver(const char *name, uint sliceMaxNum, std::initializer_list<ushort> targetTypes);

    void writeBySlicesOf(const Crystal *crystal, double currentTime);

private:
    void writeHeader();
    void writeSlice(const CounterType &counter);

    const char *ext() const;
    std::string filename() const;
};

}

#endif // CRYSTAL_SLICE_SAVER_H
