#ifndef WRAPPER_H
#define WRAPPER_H

#include "object_id.h"

/*
 * The wrapper for FFI
 */

extern "C"
{

struct IntersecResult
{
    unsigned intersectsNum;
    unsigned intersectSize;
    ObjectID *data;
};

HR *createHanserRecursive();

void addEdgeTo(HR *h, ObjectID f, ObjectID s, bool isExt);
IntersecResult *collectIntersections(HR *h);

void destroyAllData(HR *h, IntersecResult *ir);

}

#endif // WRAPPER_H
