JblArrayList :: struct(Element_Type: Type) {
    using #as _: GblArrayList;
}

JblArrayList_clone :: inline (array_view: []$T) -> JblArrayList(T), GBL_RESULT #must {
    array_list: JblArrayList(T) = ---;
    result := GblArrayList_construct_7(
        *array_list, size_of(T), cast(u64)array_view.count,
        array_view.data, size_of(GblArrayList), 0,
        null
    );
    return array_list, result;
}

JblArrayList_to_array_view :: inline (array_list: JblArrayList($T)) -> []T #must {
    using array_list.private_;

    assert(size_of(T) == elementSize);

    array_view: []T = ---;
    array_view.data = cast(*T)pData;
    array_view.count = cast(s64)size;
    return array_view;
}

JblArrayList_assign :: inline (array_list: *JblArrayList($T), elements: []T) -> GBL_RESULT #must {
    return GblArrayList_assign(array_list, elements.data, elements.count);
}

JblArrayList_at :: inline (array_list: *JblArrayList($T), index: size_t) -> *T {
    return cast(*T)GblArrayList_at(array_list, index);
}
JblArrayList_front :: inline (array_list: *JblArrayList($T)) -> *T {
    return cast(*T)GblArrayList_front(array_list);
}
JblArrayList_back :: inline (array_list: *JblArrayList($T)) -> *T {
    return cast(*T)GblArrayList_back(array_list);
}

JblArrayList_insert :: inline (array_list: *JblArrayList($T), index: size_t, elements: []T) -> []T {
    added_view: []T = ---;
    added_view.data = GblArrayList_insert(array_list, index, cast(size_t)elements.count, elements.data);
    added_view.count = elements.count;
    return added_view;
}
JblArrayList_emplace :: inline (array_list: *JblArrayList($T), index: size_t) -> *T {
    return cast(*T)GblArrayList_emplace(array_list, index);
}

JblArrayList_pushFront :: inline (array_list: *JblArrayList($T), item: T) -> GBL_RESULT {
    return GblArrayList_pushFront(array_list, *item);
}
JblArrayList_emplaceFront :: inline (array_list: *JblArrayList($T)) -> *T {
    return GblArrayList_emplaceFront(array_list, *item);
}

JblArrayList_pushBack :: inline (array_list: *JblArrayList($T), item: T) -> GBL_RESULT {
    return GblArrayList_pushBack(array_list, *item);
}
JblArrayList_emplaceBack :: inline (array_list: *JblArrayList($T)) -> *T {
    return GblArrayList_emplaceBack(array_list);
}

JblArrayList_popFront :: inline (array_list: *JblArrayList($T)) -> T, GBL_RESULT {
    item: T = ---;
    result := GblArrayList_popFront(array_list, *result);
    return item, result;
}
JblArrayList_popBack :: inline (array_list: *JblArrayList($T)) -> T, GBL_RESULT {
    item: T = ---;
    result := GblArrayList_popBack(array_list, *item);
    return item, result;
}
