#ifndef SLICE_H
#define SLICE_H

#include <vector>
#include "node.h"

namespace vd
{

class Slice : public Node
{
    typedef std::vector<Node *> Nodes;
    Nodes _nodes;

    double _totalRate = 0.0;

public:
    Slice(Slice *parent = nullptr);
    ~Slice();

    void addNode(Node *node);

    void resetRate() final;
    void updateRate(double r);

    Reaction *selectEvent(double r) override;
    double commonRate() const override;
    void sort() override;
};

}

#endif // SLICE_H
