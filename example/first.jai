#import "Basic";
#import "Compiler";

Build_Mode :: enum {
    DEBUG;
    RELEASE;
}

build_mode: Build_Mode = .DEBUG;

SOURCE_DIR :: "src";
BUILD_DIR  :: ".";
OUTPUT_NAME :: "example";

my_add_build_file :: (filename: string) #expand {
    add_build_file(tprint("%/%", SOURCE_DIR, filename), `w);
}

#run {
    set_working_directory(#filepath);
    set_build_options_dc(.{do_output=false});

    for arg: get_build_options().compile_time_command_line {
        if arg == {
            case "debug";
                build_mode = .DEBUG;
                print("Building debug...\n");

            case "release";
                build_mode = .RELEASE;
                print("Building release...\n");
        }
    }

    w := compiler_create_workspace(OUTPUT_NAME);
    if !w {
        print("Failed to create workspace '%'.", OUTPUT_NAME);
        exit(1);
    }

    // Build options.
    {
        opts := get_build_options(w);

        opts.output_type = .EXECUTABLE;
        opts.output_executable_name = OUTPUT_NAME;
        opts.output_path = BUILD_DIR;
        opts.text_output_flags  = .OUTPUT_TIMING_INFO;

        if build_mode == {
            case .RELEASE;
                opts.stack_trace = false;
                opts.backend = .LLVM;
                set_optimization(*opts, .VERY_OPTIMIZED);

            case .DEBUG;
                opts.backend = .X64;
                set_optimization(*opts, .VERY_DEBUG);
        }

        // TODO(aaron): How can these be provided by the module itself? :reest:
        opts.additional_linker_arguments = string.[
            "W:\\jimbal\\libgimbal\\build\\lib\\lib\\tiny-regex-c\\Debug\\TinyRegexC.lib",
            "W:\\jimbal\\libgimbal\\build\\lib\\lib\\tinycthread\\Debug\\tinycthread.lib"
        ];

        set_build_options(opts, w);
    }

    compiler_begin_intercept(w);

    my_add_build_file("main.jai");

    while true {
        message := compiler_wait_for_message();
        if !message                   continue;
        if message.workspace != w     continue;
        if message.kind == .COMPLETE  break;
    }

    compiler_end_intercept(w);
}
