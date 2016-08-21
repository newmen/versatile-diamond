#ifndef FILE_SAVER_H
#define FILE_SAVER_H

#include "base_saver.h"

namespace vd
{

class FileSaver : public BaseSaver
{
protected:
    template <class... Args> FileSaver(Args... args) : BaseSaver(args...) {}

    std::string fullFilename() const;
    virtual std::string filename() const = 0;
    virtual const char *ext() const = 0;
};

}

#endif // FILE_SAVER_H
