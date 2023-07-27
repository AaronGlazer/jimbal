#import "Basic";
#import "jimbal";

to_jai_array_view :: (array: GblArrayList, $T: Type) -> []T {
    using array.private_;

    assert(size_of(T) == elementSize);
    result: []T;
    result.data = cast(*T)pData;
    result.count = cast(s64)size;
    return result;
}

main :: () {
    print_it :: () #expand {
        print("============");
        print("\n%\n", to_jai_array_view(array, s32));
    }

    T :: s32;

    ctx: *GblContext = null;

    array: GblArrayList;
    GblArrayList_construct_7(*array, size_of(T), 0, null, size_of(GblArrayList), 0, ctx);
    defer GblArrayList_destruct(*array);

    GblArrayList_insert(*array, 0, 3, T.[1, 4, 9].data);
    print_it();

    a: T = 16;
    GblArrayList_pushBack(*array, *a);
    print_it();

    z: T = 0;
    GblArrayList_pushFront(*array, *z);
    print_it();
}
