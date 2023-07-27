#import "Basic";
#import "jimbal";

main :: () {
    array_view := s32.[1, 4, 9, 25];
    array_list, result := JblArrayList_clone(array_view);
    assert(result == .SUCCESS);

    print_it :: () #expand {
        print("array list: %\n", JblArrayList_to_array_view(array_list));
    }

    print("=============================\n");
    print_it();
    JblArrayList_pushFront(*array_list, 0);
    print_it();
    emplaced := JblArrayList_emplaceBack(*array_list);
    print_it();
    emplaced.* = 36;
    print_it();
    emplaced = JblArrayList_emplace(*array_list, 4);
    print_it();
    emplaced.* = 16;
    print_it();
    print("=============================\n");
}
