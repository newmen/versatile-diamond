#include "mol_saver.h"
#include <ctime>
#include <sstream>

namespace vd
{

MolSaver::MolSaver(const char *name) : _name(name)
{
}

void MolSaver::writeFrom(Atom *atom, double currentTime)
{
    std::ofstream out(filename());
    writeToFrom(out, atom, currentTime);
}

const char *MolSaver::ext() const
{
    static const char value[] = ".mol";
    return value;
}

std::string MolSaver::filename() const
{
    static uint n = 0;

    std::stringstream ss;
    ss << name() << "_" << (n++) << ext();
    return ss.str();
}

void MolSaver::writeToFrom(std::ostream &os, Atom *atom, double currentTime)
{
    writeHeader(os, currentTime);

    MolAccumulator acc;
    accumulateToFrom(acc, atom);
    acc.writeTo(os, mainPrefix());

    writeFooter(os);
}

void MolSaver::writeHeader(std::ostream &os, double currentTime) const
{
    os << name() << " (" << currentTime << " s)\n"
       << "Writen at " << timestamp() << "\n"
       << "Versatile Diamond MOLv3000 writer" << "\n"
       << "  0  0  0     0 0             999 V3000" << "\n"

       << mainPrefix() << "BEGIN CTAB" << "\n";
}

void MolSaver::writeFooter(std::ostream &os) const
{
    os << mainPrefix() << "END CTAB" << "\n"
       << "M  END" << std::endl;
}

const char *MolSaver::mainPrefix() const
{
    static const char prefix[] = "M  V30 ";
    return prefix;
}

std::string MolSaver::timestamp() const
{
    time_t rawtime;
    struct tm *timeinfo;
    char buffer[80];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(buffer, 80, "%d-%m-%Y %H:%M:%S", timeinfo);
    return buffer;
}

void MolSaver::accumulateToFrom(MolAccumulator &acc, Atom *atom) const
{
    atom->setVisited();
    atom->eachNeighbour([this, &acc, atom](Atom *nbr) {
        if (!nbr->isVisited())
        {
            accumulateToFrom(acc, nbr);
        }

        acc.addBond(atom, nbr);
    });
}

}
