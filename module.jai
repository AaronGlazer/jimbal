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

#scope_export

#load "c.jai";

#if OS == .WINDOWS {
    #load "windows.jai";
}

// Wrappers

JblArrayList :: struct(Element_Type: Type) {
    using #as _: GblArrayList;
}

JblArrayList_clone :: (array_view: []$T) -> JblArrayList(T), GBL_RESULT #must {
    array_list: JblArrayList(T) = ---;
    result := GblArrayList_construct_7(
        *array_list, size_of(T), cast(u64)array_view.count,
        array_view.data, size_of(GblArrayList), 0,
        null
    );
    return array_list, result;
}

JblArrayList_to_array_view :: (array_list: JblArrayList($T)) -> []T #must {
    using array_list.private_;

    assert(size_of(T) == elementSize);

    array_view: []T = ---;
    array_view.data = cast(*T)pData;
    array_view.count = cast(s64)size;
    return array_view;
}

JblArrayList_assign :: (array_list: *JblArrayList($T), elements: []T) -> GBL_RESULT #must {
    return GblArrayList_assign(array_list, elements.data, elements.count);
}

JblArrayList_insert :: (array_list: *JblArrayList($T), index: u64, elements: []T) -> []T {
    added_view: []T = ---;
    added_view.data = GblArrayList_insert(array_list, index, cast(size_t)elements.count, elements.data);
    added_view.count = elements.count;
    return added_view;
}

JblArrayList_popFront :: (array_list: *JblArrayList($T)) -> T, GBL_RESULT {
    item: T = ---;
    result := GblArrayList_popFront(array_list, *result);
    return item, result;
}

JblArrayList_popBack :: (array_list: *JblArrayList($T)) -> T, GBL_RESULT {
    item: T = ---;
    result := GblArrayList_popBack(array_list, *item);
    return item, result;
}
