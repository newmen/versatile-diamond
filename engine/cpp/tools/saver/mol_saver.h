#ifndef MOL_SAVER_H
#define MOL_SAVER_H

#include <fstream>
#include <string>
#include <unordered_map>
#include "mol_accumulator.h"

namespace vd
{

class MolSaver
{
    std::string _name;

public:
    MolSaver(const std::string &name);
    ~MolSaver();

    void writeFrom(Atom *atom) const;

private:
    const std::string &name() const { return _name; }

    std::string ext() const { return ".mol"; }
    std::string filename() const;

    void writeHeader(std::ostream &os) const;
    void writeFooter(std::ostream &os) const;

    const char *mainPrefix() const;
    std::string timestamp() const;

    void accumulateToFrom(MolAccumulator &acc, Atom *atom) const;
};

}

#endif // MOL_SAVER_H
