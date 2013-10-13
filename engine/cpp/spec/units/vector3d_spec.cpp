#include <vector3d.h>

using namespace vd;

int main(int argc, char const *argv[])
{
    vector3d<int> v3(dim3(3, 3, 3), 1);

    v3.each([](int n) {
        assert(n == 1);
    });

    // v3.map([](int n) { return n + 4; });
    // v3.each([](int n) {
    //     assert(n == 5);
    // });

    int sum = v3.reduce_plus(0, [](int n) {
        return n;
    });
    // assert(sum == 135);
    assert(sum == 27);

    return 0;
}