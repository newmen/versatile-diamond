#ifndef WRAPPED_SAVER_H
#define WRAPPED_SAVER_H

#include "volume_saver.h"

namespace vd
{

template
<
        template <class> class FileWrapper,
        template <class> class FormatWrapper
>
class WrappedSaver : public FormatWrapper<FileWrapper<VolumeSaver>>
{
    typedef FormatWrapper<FileWrapper<VolumeSaver>> ParentType;

protected:
    template <class... Args> WrappedSaver(Args... args) : ParentType(args...) {}
};

}

#endif // WRAPPED_SAVER_H
