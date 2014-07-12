#ifndef MOL_FORMAT_H
#define MOL_FORMAT_H

#include <ostream>
#include "format.h"
#include "mol_accumulator.h"

namespace vd
{

class MolFormat : public Format<MolAccumulator>
{
public:
    MolFormat(const VolumeSaver &saver, const MolAccumulator &acc) : Format(saver, acc) {}

    void render(std::ostream &os, double currentTime) const;

private:
    const char *prefix() const;
    void writeHeader(std::ostream &os, double currentTime) const;
    void writeBegin(std::ostream &os) const;
    void writeEnd(std::ostream &os) const;
    void writeCounts(std::ostream &os) const;
    void writeBonds(std::ostream &os) const;
    void writeAtoms(std::ostream &os) const;

    std::string atomsOptions(const AtomInfo *ai) const;
};

}

#endif // MOL_FORMAT_H
