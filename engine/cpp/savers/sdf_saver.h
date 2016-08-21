#ifndef SDF_SAVER_H
#define SDF_SAVER_H

#include "wrapped_saver.h"
#include "one_file.h"
#include "mol_format.h"

namespace vd
{

class SdfSaver : public WrappedSaver<OneFile, MolFormat>
{
    typedef WrappedSaver<OneFile, MolFormat> ParentType;

public:
    template <class... Args> SdfSaver(Args... args) : ParentType(args...) {}

protected:
    const char *separator() const override;
    const char *ext() const override;
};

}

#endif // SDF_SAVER_H
