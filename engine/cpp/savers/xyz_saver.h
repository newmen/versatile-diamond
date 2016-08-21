#ifndef XYZ_SAVER_H
#define XYZ_SAVER_H

#include "wrapped_saver.h"
#include "many_files.h"
#include "xyz_format.h"

namespace vd
{

class XYZSaver : public WrappedSaver<ManyFiles, XYZFormat>
{
    typedef WrappedSaver<ManyFiles, XYZFormat> ParentType;

public:
    template <class... Args> XYZSaver(Args... args) : ParentType(args...) {}

protected:
    const char *ext() const override;
};

}

#endif // XYZ_SAVER_H
