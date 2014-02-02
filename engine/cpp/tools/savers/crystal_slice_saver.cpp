#include "crystal_slice_saver.h"
#include <sstream>
#include "../../atoms/atom.h"

namespace vd
{

CrystalSliceSaver::CrystalSliceSaver(const char *name, uint sliceMaxNum, std::initializer_list<ushort> targetTypes) :
    _name(name), _sliceMaxNum(sliceMaxNum), _out(filename())
{
    for (ushort type : targetTypes)
    {
        _counterProto[type] = 0;
    }

    writeHeader();
}

void CrystalSliceSaver::writeBySlicesOf(const Crystal *crystal, double currentTime)
{
    _out << "= " << currentTime << "\n";

    crystal->eachSlice([this](Atom **atoms) {
        auto counter = _counterProto;
        bool have = false;

        for (uint i = 0; i < _sliceMaxNum; ++i)
        {
            if (!atoms[i]) continue;

            ushort type = atoms[i]->type();
            auto it = counter.find(type);
            if (it != counter.cend())
            {
                ++it->second;
                have = true;
            }
        }

        if (have)
        {
            writeSlice(counter);
        }
    });

    _out << std::endl;
}

void CrystalSliceSaver::writeHeader()
{
    _out << _sliceMaxNum << "\n";
    for (auto pr : _counterProto)
    {
        _out.width(COLUMN_WIDTH);
        _out << pr.first;
    }
    _out << std::endl;
}

void CrystalSliceSaver::writeSlice(const CounterType &counter)
{
    for (auto pr : counter)
    {
        _out.width(COLUMN_WIDTH);
        _out << (double)pr.second/_sliceMaxNum;
    }
    _out << "\n";
}

const char *CrystalSliceSaver::ext() const
{
    static const char value[] = ".sls";
    return value;
}

std::string CrystalSliceSaver::filename() const
{
    std::stringstream ss;
    ss << _name << ext();
    return ss.str();
}

}
