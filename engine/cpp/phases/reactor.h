#ifndef REACTOR_H
#define REACTOR_H

#include "../tools/config.h"
#include "../mc/common_mc_data.h"
#include "templated_reactor.h"
#include "amorph.h"
#include "crystal.h"
#include "saving_reactor.h"

namespace vd
{

template <class HB>
class Reactor :
        public TemplatedReactor
        <
            typename HB::SurfaceAmorph,
            typename HB::SurfaceCrystal
        >
{
    typedef TemplatedReactor<typename HB::SurfaceAmorph, typename HB::SurfaceCrystal> ParentType;

    CommonMCData _mcData;

public:
    Reactor(const Config *config);
    ~Reactor();

    typename HB::SurfaceAmorph *amorph() { return this->_amorph; }
    typename HB::SurfaceCrystal *crystal() { return this->_crystal; }

    double doEvent(); // gets delta time
    double currentTime() const;
    double totalRate() const;

    const SavingReactor *copy() const;
    const EventsCounter *evensCounter() const;

private:
    uint capacity() const;

    void fillCopies(SavingAmorph *savingAmorph, SavingCrystal *savingCrystal) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
Reactor<HB>::Reactor(const Config *config) :
    ParentType(&HB::amorph(), config->getCrystal<typename HB::SurfaceCrystal>())
{
    HB::mc().initCounter(&_mcData);
}

template <class HB>
Reactor<HB>::~Reactor()
{
    this->_amorph->clear();
    delete this->_crystal;
}

template <class HB>
double Reactor<HB>::doEvent()
{
    return HB::mc().doRandom(&_mcData);
}

template <class HB>
double Reactor<HB>::currentTime() const
{
    return HB::mc().totalTime();
}

template <class HB>
double Reactor<HB>::totalRate() const
{
    return HB::mc().totalRate();
}

template <class HB>
const SavingReactor *Reactor<HB>::copy() const
{
    SavingAmorph *savingAmorph = new SavingAmorph();
    SavingCrystal *savingCrystal = new SavingCrystal(this->_crystal);
    fillCopies(savingAmorph, savingCrystal);
    return new SavingReactor(savingAmorph, savingCrystal, currentTime(), totalRate());
}

template <class HB>
const EventsCounter *Reactor<HB>::evensCounter() const
{
    return _mcData.counter();
}

template <class HB>
uint Reactor<HB>::capacity() const
{
    return this->_crystal->maxAtoms() + this->_amorph->countAtoms();
}

template <class HB>
void Reactor<HB>::fillCopies(SavingAmorph *savingAmorph, SavingCrystal *savingCrystal) const
{
    std::unordered_map<const Atom *, SavingAtom *> mirror;
    mirror.reserve(capacity());

    this->eachAtom([&mirror, savingAmorph, savingCrystal](const Atom *atom) {
        SavingAtom *savingAtom = new SavingAtom(atom, nullptr);
        mirror[atom] = savingAtom;

        auto lattice = atom->lattice();
        if (lattice) {
            savingCrystal->insert(savingAtom, lattice->coords());
        } else {
            savingAmorph->insert(savingAtom);
        }
    });

    this->eachAtom([&mirror](const Atom *atom) {
        SavingAtom *savingAtom = mirror.find(atom)->second;
        atom->eachNeighbour([&mirror, savingAtom](const Atom *nbr) {
            savingAtom->bondWith(mirror.find(nbr)->second, 0);
        });
    });
}

}

#endif // REACTOR_H
