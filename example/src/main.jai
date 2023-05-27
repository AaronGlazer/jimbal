#import "Basic";
#import "jimbal";

main :: () {
    array_view := s32.[1, 4, 9, 25];
    array_list, result0 := JblArrayList_clone(array_view);
    assert(result0 == .SUCCESS);

    print_it :: () #expand {
        print("array list: %\n\n", JblArrayList_to_array_view(array_list));
    }

    print("=============================\n");
    print_it();
    added_array_view := JblArrayList_insert(*array_list, 1, s32.[14925, 364964]);
    print("insert result: %\n", added_array_view);
    print_it();
    value, result1 := JblArrayList_popBack(*array_list);
    print("popBack value, GBL_RESULT: % %\n", value, result1);
    print_it();
    print("=============================");
}
