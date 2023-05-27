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
