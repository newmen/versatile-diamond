#include "node.h"
#include "slice.h"

namespace vd
{

Node::Node(Slice *parent) : _parent(parent)
{
}

Slice *Node::parent()
{
    return _parent;
}

}
