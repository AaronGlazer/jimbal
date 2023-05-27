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
    ctx: *GblContext = null;

    array: GblArrayList;
    GblArrayList_construct_7(*array, size_of(s32), 0, null, size_of(GblArrayList), 1, ctx);
    defer GblArrayList_destruct(*array);

    GblArrayList_insert(*array, 0, 3, s32.[1, 4, 9].data);

    print("============");
    print("\n%\n", to_jai_array_view(array, s32));
    print("============");
}
