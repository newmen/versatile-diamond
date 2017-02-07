#ifndef SLICES_SAVER_H
#define SLICES_SAVER_H

#include <vector>
#include <unordered_map>
#include <unordered_set>
#include "file_saver.h"
#include "one_file.h"

namespace vd
{

class SlicesSaver : public OneFile<FileSaver>
{
    enum : ushort { COLUMN_WIDTH = 12 };
    enum : uint { NUMBER_OF_SKIPPING_SLICES = 2 };

    typedef OneFile<FileSaver> ParentType;
    typedef std::unordered_map<ushort, uint> TypesCounter;
    typedef std::vector<TypesCounter *> SlicesCounter;
    typedef std::unordered_set<ushort> SetOfAtomTypes;

    const SetOfAtomTypes _setOfAtomTypes;

public:
    SlicesSaver(const Config *config) :
        ParentType(config),
        _setOfAtomTypes(config->atomTypes().cbegin(), config->atomTypes().cend()) {}

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

}

#endif // SLICES_SAVER_H
