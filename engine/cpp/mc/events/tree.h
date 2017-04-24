#ifndef TREE_H
#define TREE_H

#include "../tools/common.h"
#include "slice.h"

namespace vd
{

class Tree
{
    Slice *_root = nullptr;

public:
    Tree(ushort typicalNums, ushort multiNums);
    ~Tree();
};

}

#endif // TREE_H
