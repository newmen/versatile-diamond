#include "slices_saver.h"

namespace vd
{

void SlicesSaver::save(const SavingReactor *reactor)
{
    if (!config()->atomTypes().empty())
    {
        ParentType::save(reactor);
    }
}

void SlicesSaver::writeHeader(std::ostream &os, const SavingReactor *reactor)
{
    for (ushort atomType : config()->atomTypes())
    {
        os.width(COLUMN_WIDTH);
        os << atomType;
    }
    os << "\n" << std::endl;
}

void SlicesSaver::writeBody(std::ostream &os, const SavingReactor *reactor)
{
    writeCurrentTime(os, reactor);

    SlicesCounter *slicesCounter = countAtomTypes(reactor);
    for (const TypesCounter *typesCounter : *slicesCounter)
    {
        if (!isEmptyCounter(*typesCounter))
        {
            for (ushort atomType : config()->atomTypes())
            {
                TypesCounter::const_iterator it = typesCounter->find(atomType);
                os.width(COLUMN_WIDTH);
                os << (double)it->second / config()->squire();
            }
            os << "\n";
        }
        delete typesCounter;
    }
    os << std::endl;
    delete slicesCounter;
}

void SlicesSaver::writeCurrentTime(std::ostream &os, const SavingReactor *reactor)
{
    static uint n = 0;
    os << n++ << " = " << reactor->currentTime() << " s\n";
}

SlicesSaver::TypesCounter *SlicesSaver::emptyTypesCounter() const
{
    TypesCounter *typesCounter = new TypesCounter();
    for (ushort atomType : config()->atomTypes())
    {
        typesCounter->insert(TypesCounter::value_type(atomType, 0));
    }
    return typesCounter;
}

SlicesSaver::SlicesCounter *SlicesSaver::countAtomTypes(const SavingReactor *reactor) const
{
    SlicesCounter *slicesCounter = new SlicesCounter();
    appendCrystalQuantities(slicesCounter, reactor->crystal());
    appendAmorphQuantities(slicesCounter, reactor->amorph());
    return slicesCounter;
}

void SlicesSaver::appendCrystalQuantities(SlicesCounter *slicesCounter,
                                          const SavingCrystal *crystal) const
{
    uint sliceNum = 0;
    crystal->eachSlice([this, slicesCounter, &sliceNum](SavingAtom **atoms) {
        if (++sliceNum > NUMBER_OF_SKIPPING_SLICES)
        {
            TypesCounter *typesCounter = emptyTypesCounter();
            for (uint i = 0; i < config()->squire(); ++i)
            {
                if (atoms[i] && isTargetAtom(atoms[i]))
                {
                    appendAtomType(typesCounter, atoms[i]);
                }
            }

            slicesCounter->push_back(typesCounter);
        }
    });
}

void SlicesSaver::appendAmorphQuantities(SlicesCounter *slicesCounter,
                                         const SavingAmorph *amorph) const
{
    amorph->eachAtom([this, slicesCounter](SavingAtom *amorphAtom) {
        if (isTargetAtom(amorphAtom))
        {
            SavingAtom *crystalAtom = amorphAtom->firstCrystalNeighbour();
            uint sliceN = crystalAtom->lattice()->coords().z - NUMBER_OF_SKIPPING_SLICES;
            appendAtomType(slicesCounter->at(sliceN), amorphAtom);
        }
    });
}

void SlicesSaver::appendAtomType(TypesCounter *typesCounter, const SavingAtom *atom) const
{
    TypesCounter::iterator it = typesCounter->find(atom->type());
    ++it->second;
}

bool SlicesSaver::isTargetAtom(const SavingAtom *atom) const
{
    return _setOfAtomTypes.find(atom->type()) != _setOfAtomTypes.cend();
}

bool SlicesSaver::isEmptyCounter(const TypesCounter &typesCounter) const
{
    for (auto &pr : typesCounter)
    {
        if (pr.second > 0)
        {
            return false;
        }
    }
    return true;
}

const char *SlicesSaver::ext() const
{
    static const char value[] = ".sls";
    return value;
}

}
