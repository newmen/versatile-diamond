#include "yaml_config_reader.h"

namespace vd
{

YAMLConfigReader::YAMLConfigReader(const std::string &filePath) :
    _root(YAML::LoadFile(filePath.c_str()))
{
}

bool YAMLConfigReader::recursiveIsDefined(const YAML::Node &node, const char *key) const
{
    return node[key].IsDefined();
}

}
