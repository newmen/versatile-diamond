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

    SlicesCounter slicesCounter = countAtomTypes(reactor);
    for (const TypesCounter &typesCounter : slicesCounter)
    {
        for (const auto &pr : typesCounter)
        {
            os.width(COLUMN_WIDTH);
            os << (double)pr.second / config()->squire();
        }
        os << "\n";
    }
    os << std::endl;
}

void SlicesSaver::writeCurrentTime(std::ostream &os, const SavingReactor *reactor)
{
    static uint n = 0;
    os << n++ << " = " << reactor->currentTime() << " s\n";
}

SlicesSaver::TypesCounter SlicesSaver::emptyTypesCounter() const
{
    TypesCounter typesCounter;
    for (ushort atomType : config()->atomTypes())
    {
        typesCounter.insert(TypesCounter::value_type(atomType, 0));
    }
    return typesCounter;
}

SlicesSaver::SlicesCounter SlicesSaver::countAtomTypes(const SavingReactor *reactor) const
{
    SlicesCounter slicesCounter;
    appendCrystalQuantities(&slicesCounter, reactor->crystal());
    appendAmorphQuantities(&slicesCounter, reactor->amorph());
    return slicesCounter;
}

void SlicesSaver::appendCrystalQuantities(SlicesCounter *slicesCounter,
                                          const SavingCrystal *crystal) const
{
    uint sliceNum = 0;
    crystal->eachSlice([this, &slicesCounter, &sliceNum](SavingAtom **atoms) {
        if (++sliceNum > 2)
        {
            TypesCounter typesCounter = emptyTypesCounter();
            for (uint i = 0; i < config()->squire(); ++i)
            {
                if (atoms[i])
                {
                    appendAtomType(&typesCounter, atoms[i]);
                }
            }

            if (!isEmptyCounter(typesCounter))
            {
                slicesCounter->push_back(typesCounter);
            }
        }
    });
}

void SlicesSaver::appendAmorphQuantities(SlicesCounter *slicesCounter,
                                         const SavingAmorph *amorph) const
{
    TypesCounter typesCounter = emptyTypesCounter();
    amorph->eachAtom([this, &typesCounter](SavingAtom *atom) {
        appendAtomType(&typesCounter, atom);
    });

    if (!isEmptyCounter(typesCounter))
    {
        slicesCounter->push_back(typesCounter);
    }
}

void SlicesSaver::appendAtomType(TypesCounter *typesCounter, const SavingAtom *atom) const
{
    TypesCounter::iterator it = typesCounter->find(atom->type());
    if (it != typesCounter->end())
    {
        ++it->second;
    }
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
