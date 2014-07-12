#ifndef MOL_FORMAT_H
#define MOL_FORMAT_H

#include <ostream>
#include "mol_accumulator.h"
#include "volume_saver.h"

namespace vd
{

class MolFormat
{
    const VolumeSaver &_saver;
    const MolAccumulator &_acc;

public:
    MolFormat(const VolumeSaver &saver, const MolAccumulator &acc) : _saver(saver), _acc(acc) {}
    void render(std::ostream &os, double currentTime) const;

private:
    const char *prefix() const;
    void writeHeader(std::ostream &os, double currentTime) const;
    void writeBegin(std::ostream &os) const;
    void writeEnd(std::ostream &os) const;
    void writeCounts(std::ostream &os) const;
    void writeBonds(std::ostream &os) const;
    void writeAtoms(std::ostream &os) const;

    std::string timestamp() const;
    std::string atomsOptions(const AtomInfo *ai) const;
};

}
#endif // MOL_FORMAT_H
