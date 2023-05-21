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

#import "Basic";
#import "Bindings_Generator";
#import "Command_Line";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";

GBL_DEFAULT_BUILD_DIR :: "build";

// TODO(aaron): Don't hardcode these xdlmao.
GBL_LIB_DIR_FMT_STRING :: "libgimbal/%/lib/Debug";
GBL_CMAKE_CACHE_PATH_FMT_STRING :: "libgimbal/%/CMakeCache.txt";
GBL_INCLUDE_DIR :: "libgimbal/lib/api";
GBL_BUILD_INCLUDE_DIR_FMT_STRING :: "libgimbal/%/lib/api";
GBL_THIRD_PARTY_TINYCTHREAD_INCLUDE_DIR :: "libgimbal/lib/lib/tinycthread/source";
GBL_THIRD_PARTY_TINYREGEXC_INCLUDE_DIR :: "libgimbal/lib/lib/tiny-regex-c";

Arguments :: struct {
    build_dir: string = GBL_DEFAULT_BUILD_DIR;
}

main :: () {
    set_working_directory(#filepath);

    args_ok, args, is_set := parse_arguments(Arguments);

    output_filename: string;
    opts: Generate_Bindings_Options;

    // This is here because inlined functions are not exported.
    // Eventually we'd like to have exported copies via some macro business.
    opts.strip_flags |= .INLINED_FUNCTIONS;

    #if OS == .WINDOWS {
        output_filename = "windows.jai";
    } else {
        assert(false, "Your target operating system (%) is not currently supported.", OS);
    }

    // Just adding all *.h files in GBL_INCLUDE_DIR.
    file_visitor :: (info: *File_Visit_Info, source_files: *[..]string) {
        found, filename, ext := split_from_right(info.short_name, ".");
        if !found return;
        if ext != "h" return;

        array_add(source_files, copy_string(info.full_name));
    }
    visit_files(
        GBL_INCLUDE_DIR,
        recursive = true,
        follow_symlinks = true,
        user_data = *opts.source_files,
        proc = file_visitor
    );

    {
        // Pull flags from CMakeCache.txt. This is a super dumb parser
        // since we know every definition is on its own line.

        content := read_entire_file(tprint(GBL_CMAKE_CACHE_PATH_FMT_STRING, args.build_dir));
        defer free(content);
        lines := split(content, cast(u8)(#char "\n"));

        for lines {
            line := it; // Want a copy.
            if !begins_with(line, "GBL_CONFIG_")  continue;
            if ends_with(line, "\r") line.count -= 1;

            found0, name_type, value := split_from_left(line, cast(u8)(#char "="));
            if !found0 {
                log_error("Failed to parse config line: %", line);
                return;
            }

            found1, name, type := split_from_left(name_type, cast(u8)(#char ":"));
            if !found1 {
                log_error("Failed to parse config line: %", line);
                return;
            }

            preprocessor_flag: string;

            if type == {
                case "BOOL";
                    s: string;
                    if value == {
                        case "ON";  s = "1";
                        case "OFF"; s = "0";
                        case;
                            log_error("Invalid value for flag '%' of boolean type (should be ON or OFF): %", name, value);
                            return;
                    }
                    preprocessor_flag = tprint("%=%", name, s);
                case "STRING";
                    preprocessor_flag = tprint("%=%", name, value);
                case;
                    log("Skipping flag of unhandled type %", type);
            }

            if preprocessor_flag {
                clang_flag := sprint("-D%", preprocessor_flag);
                array_add(*opts.extra_clang_arguments, clang_flag);
            }
        }
    }

    array_add(*opts.libpaths, tprint(GBL_LIB_DIR_FMT_STRING, args.build_dir));
    array_add(*opts.libnames, "libGimbal");
    array_add(*opts.include_paths, GBL_INCLUDE_DIR);
    array_add(*opts.system_include_paths, tprint(GBL_BUILD_INCLUDE_DIR_FMT_STRING, args.build_dir));
    array_add(*opts.system_include_paths, GBL_THIRD_PARTY_TINYCTHREAD_INCLUDE_DIR);
    array_add(*opts.system_include_paths, GBL_THIRD_PARTY_TINYREGEXC_INCLUDE_DIR);
    array_add(*opts.system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

    opts.visitor = gimbal_decl_visitor;

    builder, builder_ok := generate_bindings(opts);
    if !builder_ok {
        log_error("we done reested :marcel:");
        return;
    }

    generated_source := builder_to_string(*builder);

    // HACK: libclang doesn't output the correct alignment for anonymous
    // structs/unions. So, Bindings_Generator attempts to calculate its own,
    // but GblContext uses custom alignment. This means the resulting struct
    // size and member offset assertions for GblCallRecord fail. Until this
    // is fixed in libclang, we have to manually fix that here. Sadge.
    // Bindings_Generator also does not seem to give us enough control to
    // handle that through it, so we have to do a super hacky string surgery
    // here........

    GBL_CALL_RECORD_SOURCE :: #string __DONE__
GblCallRecord :: struct {
    message:     [128] u8;
    srcLocation: GblSourceLocation;
    result:      GBL_RESULT;
}
__DONE__;
    GBL_CALL_RECORD_REPLACE :: #string __DONE__
GblCallRecord :: struct {
    message:     [128] u8 #align 64;
    srcLocation: GblSourceLocation;
    result:      GBL_RESULT;
}
__DONE__;

    // TODO(aaron): Verify this replacement actually happens. Otherwise the
    // definition for GblCallRecord probably changed and needs to be updated.
    generated_source = replace(generated_source, GBL_CALL_RECORD_SOURCE, GBL_CALL_RECORD_REPLACE);

    // Add the license.
    license, license_ok := read_entire_file("misc/license_text_comment.txt");
    if !license_ok {
        log_error("Failed to load license text for writing, aborting...");
        return;
    }

    outfile, outfile_ok := file_open(output_filename, for_writing = true);
    if !outfile_ok {
        log_error("Failed to open output file '%' for writing, aborting...", output_filename);
        return;
    }
    defer file_close(*outfile);

    write_license_ok := file_write(*outfile, license);
    if !write_license_ok {
        log_error("We failed to write the license text to '%', aborting...", output_filename);
        return;
    }

    file_write(*outfile, "\n");

    write_source_ok := file_write(*outfile, generated_source);
    if !write_source_ok {
        log_error("We failed to write the generated bindings to '%', aborting...", output_filename);
        return;
    }

    log("Your Gimbal has been Jaified.");
}

gimbal_decl_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    // The rest of this function relies on this assumption heavily.
    if !(begins_with(decl.name, "Gbl") || begins_with(decl.name, "GBL_")) {
        return .RECURSE;
    }

    // For C, Gimbal declares enums (and flags) like this:
    //     typedef uint32_t GblEnum;
    // [...]
    //     typedef GblEnum E;
    //     enum E {};
    // This causes the bindings generator to define E twice.

    // First, we have to ignore the extra declarations.
    if decl.kind == .TYPEDEF {
        if decl.type.type_of_typedef {
            typedef_to := decl.type.type_of_typedef.declaration.name;
            if typedef_to == "GblEnum" || typedef_to == "GblFlags" {
                decl.decl_flags |= .OMIT_FROM_OUTPUT;
                return .RECURSE;
            }
            return .RECURSE;
        }
    }

    // TODO(aaron): This is not implemented yet (see inner comment).
    // Then, just for extra correctness, we update enum declarations to change from this:
    //     GblEnumX :: enum s32 {}
    // to this:
    //     GblEnumX :: enum GblEnum {}
    if decl.kind == .ENUM {
        // Not getting any useful info in decl here... ?
    }

    // Lastly we remove functions that take a va_list. They have equivalent ... versions,
    // and cannot be bound.

    // First step of that is removing function declarations.
    is_function_typedef := decl.type && decl.type.pointer_to && decl.type.pointer_to.type_of_function;
    is_function := decl.kind == .FUNCTION;
    if is_function || is_function_typedef {
        type_of_function: *Function_Type;
        if is_function_typedef {
            type_of_function = decl.type.pointer_to.type_of_function;
        } else if is_function {
            type_of_function = decl.type.type_of_function;
        }

        if type_of_function {
            if function_has_va_list(type_of_function) {
                decl.decl_flags |= .OMIT_FROM_OUTPUT;
                return .RECURSE;
            }
        }
    }

    // Second step is to block out vtable entries that point to functions taking va_list.
    // We can't simply "not bind" these, since they are part of the vtable, so I'm gonna
    // be evil and just make them *void and pls do not use them thx.
    if decl.kind == .TYPEDEF {
        s := decl.type.type_of_struct;
        if s {
            decls := s.declarations;
            for field: decls {
                ptr := field.type.pointer_to;
                if !ptr  continue;

                fn := ptr.type_of_function;
                if !fn  continue;

                if !function_has_va_list(fn)  continue;

                // Evil hackery.
                field.type = context.generator.type_def_ptr_void;
                field.output_name = sprint("%_PLS_DO_NOT_USE_SRSLY", field.name);
                return .RECURSE;
            }
        }
    }

    return .RECURSE;
}

function_has_va_list :: (type_of_function: Function_Type) -> bool #must {
    for arg: type_of_function.arguments {
        typedef := arg.type.type_of_typedef; // va_list
        if arg.type.pointer_to { // *va_list
            typedef = arg.type.pointer_to.type_of_typedef;
        }
        if typedef && typedef.name == "va_list" {
            return true;
        }
    }
    return false;
}
