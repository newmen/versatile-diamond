#ifndef MOL_SAVER_H
#define MOL_SAVER_H

#include "wrapped_saver.h"
#include "many_files.h"
#include "mol_format.h"

namespace vd
{

class MolSaver : public WrappedSaver<ManyFiles, MolFormat>
{
    typedef WrappedSaver<ManyFiles, MolFormat> ParentType;

public:
    template <class... Args> MolSaver(Args... args) : ParentType(args...) {}

protected:
    const char *ext() const override;
};

}

#endif // MOL_SAVER_H
