#include <sstream>
#include <fstream>
#include "dump_saver.h"
#include "../mol_accumulator.h"
#include "dump_format.h"

namespace vd
{

void DumpSaver::save(double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector)
{
    std::ofstream os(filename());    
    MolAccumulator acc(detector);
    auto lambda = [&acc](const SavingAtom *atom) {
        atom->eachNeighbour([&acc, atom](SavingAtom *nbr) {
            acc.addBondedPair(atom, nbr);
        });
    };

    amorph->eachAtom(lambda);
    crystal->eachAtom(lambda);

    const DumpFormat format(*this, acc);
    format.render(os, currentTime);
}

std::string DumpSaver::filename() const
{
    static uint n = 0;

    std::stringstream ss;
    ss << this->name() << "_" << (n++) << this->ext();
    return ss.str();
}

const char *DumpSaver::ext() const
{
    static const char value[] = ".dump";
    return value;
}

}
