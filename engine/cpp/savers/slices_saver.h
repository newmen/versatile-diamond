#ifndef SLICES_SAVER_H
#define SLICES_SAVER_H

#include <vector>
#include <unordered_map>
#include <unordered_set>
#include "file_saver.h"
#include "one_file.h"

namespace vd
{

template <class HB>
class SlicesSaver : public OneFile<FileSaver>
{
    enum : ushort { COLUMN_WIDTH = 12 };
    enum : uint { NUMBER_OF_SKIPPING_SLICES = 2 };

    typedef OneFile<FileSaver> ParentType;
    typedef std::unordered_map<ushort, uint> TypesCounter;
    typedef std::vector<TypesCounter *> SlicesCounter;

public:
    template <class... Args> SlicesSaver(Args... args) : ParentType(args...) {}

    void save(const SavingReactor *reactor) override;

protected:
    void writeHeader(std::ostream &os, const SavingReactor *reactor) override;
    void writeBody(std::ostream &os, const SavingReactor *reactor) override;

private:
    void writeCurrentTime(std::ostream &os, const SavingReactor *reactor);

    TypesCounter *emptyTypesCounter() const;
    SlicesCounter *countAtomTypes(const SavingReactor *reactor) const;
    void appendCrystalQuantities(SlicesCounter *slicesCounter, const SavingCrystal *crystal) const;
    void appendAmorphQuantities(SlicesCounter *slicesCounter, const SavingAmorph *amorph) const;
    void appendAtomType(TypesCounter *typesCounter, const SavingAtom *atom) const;
    bool isTargetAtom(const SavingAtom *atom) const;
    bool isEmptyCounter(const TypesCounter &typesCounter) const;

    const char *ext() const override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
void SlicesSaver<HB>::save(const SavingReactor *reactor)
{
    if (!config()->atomTypes().empty())
    {
        ParentType::save(reactor);
    }
}

template <class HB>
void SlicesSaver<HB>::writeHeader(std::ostream &os, const SavingReactor *reactor)
{
    for (ushort atomType : config()->atomTypes())
    {
        os.width(COLUMN_WIDTH);
        os << atomType;
    }
    os << "\n" << std::endl;
}

template <class HB>
void SlicesSaver<HB>::writeBody(std::ostream &os, const SavingReactor *reactor)
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

template <class HB>
void SlicesSaver<HB>::writeCurrentTime(std::ostream &os, const SavingReactor *reactor)
{
    static uint n = 0;
    os << n++ << " = " << reactor->currentTime() << " s\n";
}

template <class HB>
typename SlicesSaver<HB>::TypesCounter *SlicesSaver<HB>::emptyTypesCounter() const
{
    TypesCounter *typesCounter = new TypesCounter();
    for (ushort atomType : config()->atomTypes())
    {
        typesCounter->insert(TypesCounter::value_type(atomType, 0));
    }
    return typesCounter;
}

template <class HB>
typename SlicesSaver<HB>::SlicesCounter *SlicesSaver<HB>::countAtomTypes(const SavingReactor *reactor) const
{
    SlicesCounter *slicesCounter = new SlicesCounter();
    appendCrystalQuantities(slicesCounter, reactor->crystal());
    appendAmorphQuantities(slicesCounter, reactor->amorph());
    return slicesCounter;
}

template <class HB>
void SlicesSaver<HB>::appendCrystalQuantities(SlicesCounter *slicesCounter,
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

template <class HB>
void SlicesSaver<HB>::appendAmorphQuantities(SlicesCounter *slicesCounter, const SavingAmorph *amorph) const
{
    amorph->eachAtom([this, slicesCounter](SavingAtom *amorphAtom) {
        if (isTargetAtom(amorphAtom))
        {
            SavingAtom *crystalAtom = amorphAtom->firstCrystalNeighbour();
            if (crystalAtom->lattice()->coords().z >= (int)NUMBER_OF_SKIPPING_SLICES)
            {
                uint sliceN = crystalAtom->lattice()->coords().z - NUMBER_OF_SKIPPING_SLICES;
                appendAtomType((*slicesCounter)[sliceN], amorphAtom);
            }
        }
    });
}

template <class HB>
void SlicesSaver<HB>::appendAtomType(TypesCounter *typesCounter, const SavingAtom *atom) const
{
    for (TypesCounter::iterator it = typesCounter->begin(); it != typesCounter->end(); it++)
    {
        if (HB::atomIs(atom->type(), it->first))
        {
            ++it->second;
        }
    }
}

template <class HB>
bool SlicesSaver<HB>::isTargetAtom(const SavingAtom *atom) const
{
    for (ushort type : config()->atomTypes())
    {
        if (HB::atomIs(atom->type(), type))
        {
            return true;
        }
    }
    return false;
}

template <class HB>
bool SlicesSaver<HB>::isEmptyCounter(const TypesCounter &typesCounter) const
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

template <class HB>
const char *SlicesSaver<HB>::ext() const
{
    static const char value[] = ".sls";
    return value;
}

}

#endif // SLICES_SAVER_H
