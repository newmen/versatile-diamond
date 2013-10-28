#include <tools/vector3d.h>

using namespace vd;

int main(int argc, char const *argv[])
{
    vector3d<int> v3(dim3(3, 3, 3), 2);

    v3.each([](int n) {
        assert(n == 2);
    });

    // v3.map([](int n) { return n + 4; });
    // v3.each([](int n) {
    //     assert(n == 5);
    // });

    int sum = v3.reduce_plus(0, [](int n) {
        return n;
    });
    // assert(sum == 135);
    assert(sum == 54);

    assert(v3.size() == 27);
    assert(v3.data());
    for (int i = 0; i < 27; ++i)
    {
        assert(v3.data()[i] == 2);
    }

    assert(v3[int3(1, 1, 1)] == 2);
    v3[int3(1, 1, 1)] = 4;
    assert(v3[int3(1, 1, 1)] == 4);

    return 0;
}