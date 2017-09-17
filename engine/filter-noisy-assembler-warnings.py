#!/usr/bin/python
import sys

for line in sys.stdin:
    # If line is a 'noisy' warning, don't print it or the following two lines.
    if (('warning: section' in line and ('is deprecated' in line or 'note: change section name to' in line)) or
            ('template<typename> class auto_ptr;' in line) or
            ('std::auto_ptr' in line) or
            ('^~~~~~~~' in line) or
            ('                 from' in line) or
            ('In file included' in line) or
            ('/usr/local/Cellar/gcc/6.3.0_1/include/c++/6.3.0/' in line)):
        # next(sys.stdin)
        pass
    else:
        sys.stderr.write(line)
        sys.stderr.flush()
