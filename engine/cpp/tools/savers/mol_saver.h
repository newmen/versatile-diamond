#ifndef MOL_SAVER_H
#define MOL_SAVER_H

#include <fstream>
#include <string>
#include "mol_accumulator.h"

namespace vd
{

class MolSaver
{
    std::string _name;

public:
    MolSaver(const char *name);
    virtual ~MolSaver() {}

    virtual void writeFrom(Atom *atom, double currentTime);

protected:
    void writeToFrom(std::ostream &os, Atom *atom, double currentTime);

    const std::string &name() const { return _name; }

    virtual const char *ext() const;
    virtual std::string filename() const;

private:
    void writeHeader(std::ostream &os, double currentTime) const;
    void writeFooter(std::ostream &os) const;

    const char *mainPrefix() const;
    std::string timestamp() const;

    void accumulateToFrom(MolAccumulator &acc, Atom *atom) const;
};

}

#endif // MOL_SAVER_H
