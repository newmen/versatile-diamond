#ifndef MOL_SAVER_H
#define MOL_SAVER_H

#include <fstream>
#include <string>
#include <ctime>
#include <sstream>
#include "mol_accumulator.h"
#include "named_saver.h"

namespace vd
{

template <class D>
class MolSaver : public NamedSaver
{
public:
    MolSaver(const char *name) : NamedSaver(name) {}

    void writeFrom(Atom *atom, double currentTime) override;

protected:
    void writeToFrom(std::ostream &os, Atom *atom, double currentTime);

    virtual const char *ext() const;
    virtual std::string filename() const;

private:
    void writeHeader(std::ostream &os, double currentTime) const;
    void writeFooter(std::ostream &os) const;

    const char *mainPrefix() const;
    std::string timestamp() const;

    void accumulateToFrom(MolAccumulator &acc, Atom *atom) const;
};

////////////////////////////////////////////////////////////////////////////

template <class D>
void MolSaver<D>::writeFrom(Atom *atom, double currentTime)
{
    std::ofstream out(filename());
    writeToFrom(out, atom, currentTime);
}

template <class D>
const char *MolSaver<D>::ext() const
{
    static const char value[] = ".mol";
    return value;
}

template <class D>
std::string MolSaver<D>::filename() const
{
    static uint n = 0;

    std::stringstream ss;
    ss << name() << "_" << (n++) << ext();
    return ss.str();
}

template <class D>
void MolSaver<D>::writeToFrom(std::ostream &os, Atom *atom, double currentTime)
{
    writeHeader(os, currentTime);

    MolAccumulator acc;
    accumulateToFrom(acc, atom);
    acc.writeTo<D>(os, mainPrefix());

    writeFooter(os);
}

template <class D>
void MolSaver<D>::writeHeader(std::ostream &os, double currentTime) const
{
    os << name() << " (" << currentTime << " s)\n"
       << "Writen at " << timestamp() << "\n"
       << "Versatile Diamond MOLv3000 writer" << "\n"
       << "  0  0  0     0 0             999 V3000" << "\n"

       << mainPrefix() << "BEGIN CTAB" << "\n";
}

template <class D>
void MolSaver<D>::writeFooter(std::ostream &os) const
{
    os << mainPrefix() << "END CTAB" << "\n"
       << "M  END" << std::endl;
}

template <class D>
const char *MolSaver<D>::mainPrefix() const
{
    static const char prefix[] = "M  V30 ";
    return prefix;
}

template <class D>
std::string MolSaver<D>::timestamp() const
{
    time_t rawtime;
    struct tm *timeinfo;
    char buffer[80];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(buffer, 80, "%d-%m-%Y %H:%M:%S", timeinfo);
    return buffer;
}

template <class D>
void MolSaver<D>::accumulateToFrom(MolAccumulator &acc, Atom *atom) const
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

#endif // MOL_SAVER_H
