#include "yaml_config_reader.h"

namespace vd
{

YAMLConfigReader::YAMLConfigReader(const char *filename) : _config(YAML::LoadFile(filename))
{
}

}
