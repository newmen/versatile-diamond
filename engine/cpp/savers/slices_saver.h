#ifndef SLICES_SAVER_H
#define SLICES_SAVER_H

#include <list>
#include <map>
#include "file_saver.h"
#include "one_file.h"

namespace vd
{

class SlicesSaver : public OneFile<FileSaver>
{
    enum : ushort { COLUMN_WIDTH = 12 };

    typedef OneFile<FileSaver> ParentType;
    typedef std::map<ushort, uint> TypesCounter;
    typedef std::list<TypesCounter> SlicesCounter;

public:
    template <class... Args> SlicesSaver(Args... args) :
        ParentType(args...) {}

    void save(const SavingReactor *reactor) override;

protected:
    void writeHeader(std::ostream &os, const SavingReactor *reactor) override;
    void writeBody(std::ostream &os, const SavingReactor *reactor) override;

private:
    void writeCurrentTime(std::ostream &os, const SavingReactor *reactor);

    TypesCounter emptyTypesCounter() const;
    SlicesCounter countAtomTypes(const SavingReactor *reactor) const;
    void appendCrystalQuantities(SlicesCounter *slicesCounter, const SavingCrystal *crystal) const;
    void appendAmorphQuantities(SlicesCounter *slicesCounter, const SavingAmorph *amorph) const;
    void appendAtomType(TypesCounter *typesCounter, const SavingAtom *atom) const;
    bool isEmptyCounter(const TypesCounter &typesCounter) const;

    const char *ext() const override;
};

}

#endif // SLICES_SAVER_H
