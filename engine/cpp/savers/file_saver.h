#ifndef FILE_SAVER_H
#define FILE_SAVER_H

#include "base_saver.h"

namespace vd
{

class FileSaver : public BaseSaver
{
protected:
    template <class... Args> FileSaver(Args... args) : BaseSaver(args...) {}

    std::string fullFilename();
    virtual std::string filename() = 0;
    virtual const char *ext() const = 0;
};

}

#endif // FILE_SAVER_H
