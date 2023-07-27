# Jimbal

Jimbal is a binding of libGimbal to the Jai programming language. It is provided as a bindings generator.

# WIP Disclaimer

These bindings are not extensively tested.

# Setup and Generation

## Download the repo

Download this repo in your discoverable modules folder of choice, and download the submodules recursively.

```
git clone https://github.com/AaronGlazer/jimbal
cd jimbal
git submodule update --init --recursive
```

## Building libGimbal

To generate and use these bindings, you must first build libGimbal. This requires CMake as well as a C compiler. I will suggest clang since the generator also uses clang to preprocess and parse the header files, though I don't know if using another compiler will or won't cause any issues.

You may want to check [libGimbal's own README](https://github.com/gyrovorbis/libgimbal/tree/master#building) in case this is out of date or missing details, but you should be able to build it via something like this, from within libGimal's root directory:

```
mkdir build
cd build
cmake -T ClangCL ..
cmake --build .
```

## Patching Bindings_Generator

Now, in order to use the generator, `modules/Bindings_Generator` must be patched to handle a scenario for C-style functions with no prototype. This is not replicatable in Jai, so we introduce a workaround. For now, we don't want to submit this as an official patch to Bindings Generator because it's not technically the correct behavior.

The `misc/module.patch` file in this repo can be used to patch Bindings Generator from Jai beta 0.1.063. You can also manually apply it, since it's not a large change.

## Generating the bindings

Once the previous steps are complete, run `jai generate.jai` to build the generator.

If you used a different name for your libGimbal build folder, you can supply it via a command line flag:

```
jai generate.jai -build_dir my_build_dir_name
```
