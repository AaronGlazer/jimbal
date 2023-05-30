// MIT License
//
// Copyright (c) 2023 Aaron Glazer
//
// Permission is hereby granted, free of charge,  to any person obtaining a copy of
// this software  and associated documentation  files (the "Software"), to  deal in
// the Software  without restriction,  including without  limitation the  rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to  whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright  notice and this permission notice shall  be included in all
// copies or substantial portions of the Software.
//
// THE  SOFTWARE IS  PROVIDED "AS  IS", WITHOUT  WARRANTY OF  ANY KIND,  EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR  PURPOSE AND NONINFRINGEMENT. IN NO EVENT  SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE  LIABLE FOR ANY CLAIM, DAMAGES OR  OTHER LIABILITY, WHETHER
// IN  AN ACTION  OF  CONTRACT, TORT  OR  OTHERWISE,  ARISING FROM,  OUT  OF OR  IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#scope_module

#if PTR_SIZE == 8 {
    size_t    :: u64;
    ptrdiff_t :: s64;
} else #if PTR_SIZE == 4 {
    size_t    :: u32;
    ptrdiff_t :: s32;
} else #if PTR_SIZE == 2 {
    size_t    :: u16;
    ptrdiff_t :: s16;
} else #if PTR_SIZE == 1 {
    size_t    :: u8;
    ptrdiff_t :: s8;
} else {
    #run Basic.assert(false, "Your platform's pointer size of % is not supported.", PTR_SIZE);
}

// TODO(aaron): No idea if these 2 are always correct.
time_t :: s64;
sig_atomic_t :: s32;

timespec :: struct {
    tv_sec:  time_t;
    tv_nsec: s64;
}

tm :: struct {
    tm_sec:   s32; // seconds after the minute: [0-60]
    tm_min:   s32; // minutes after the hour:   [0-59]
    tm_hour:  s32; // hours after midnight:     [0-23]
    tm_mday:  s32; // day of the month:         [1-31]
    tm_mon:   s32; // months since January:     [0-11]
    tm_year:  s32; // years since 1900
    tm_wday:  s32; // days since Sunday:    [0-6]
    tm_yday:  s32; // days since January 1: [0-365]
    tm_isdst: s32; // daylight saving time flag: < 0, 0, or > 0

    tm_gmtoff: s64;
    tm_zone:  *u8;
}

#scope_file

PTR_SIZE :: size_of(*void);

Basic :: #import "Basic"; // ... Am I really taking a dependency on Basic just for assert???
