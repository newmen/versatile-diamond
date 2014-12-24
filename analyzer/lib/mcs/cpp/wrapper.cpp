#include "wrapper.h"

HR *createHanserRecursive()
{
    return new HR;
}

void addEdgeTo(HR *h, ObjectID f, ObjectID s, bool isExt)
{
    h->addEdge(f, s, isExt);
}

IntersecResult *collectIntersections(HR *h)
{
    HR::Intersections its(std::move(h->intersections()));
    IntersecResult *result = new IntersecResult;

    result->intersectsNum = its.size();
    result->intersectSize = (result->intersectsNum > 0) ? its.begin()->size() : 0;
    result->data = new ObjectID[result->intersectsNum * result->intersectSize];

    unsigned i = 0;
    for (const HR::Intersec &intersec : its)
    {
        for (ObjectID v : intersec)
        {
            result->data[i++] = v;
        }
    }
    assert(i == result->intersectsNum * result->intersectSize);

    return result;
}

void destroyAllData(HR *h, IntersecResult *ir)
{
    delete h;

    delete [] ir->data;
    delete ir;
}
