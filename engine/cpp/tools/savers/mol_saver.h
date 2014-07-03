#ifndef MOL_SAVER_H
#define MOL_SAVER_H

#include <fstream>
#include <string>
#include <ctime>
#include <sstream>
#include "mol_accumulator.h"
#include "volume_saver.h"

namespace vd
{

class MolSaver : public VolumeSaver
{
public:
    MolSaver(const char *name) : VolumeSaver(name) {}

    void writeFrom(Atom *atom, double currentTime, const Detector *detector) override;

protected:
    void writeToFrom(std::ostream &os, Atom *atom, double currentTime, const Detector *detector);

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
