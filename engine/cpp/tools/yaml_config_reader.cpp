#include "yaml_config_reader.h"

namespace vd
{

YAMLConfigReader::YAMLConfigReader(const char *filename) : _root(YAML::LoadFile(filename))
{
}

bool YAMLConfigReader::recursiveIsDefined(const YAML::Node &node, const char *key) const
{
    return node[key].IsDefined();
}

}
