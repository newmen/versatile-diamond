#include "file_saver.h"
#include <sstream>

namespace vd
{

std::string FileSaver::fullFilename()
{
    std::stringstream ss;
    ss << filename() << ext();
    return ss.str();
}

}
