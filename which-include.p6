#!/usr/bin/env perl6
# --- GCC wrapper to extract the absolute path of an included file ---

# Get default include directories
constant INCLUDES_BEGIN = '#include <...> search starts here:';
constant INCLUDES_END = 'End of search list.';

my $include_dir_proc = shell 'echo | gcc -xc -E -v -', :out, :err;
my @default_include_dirs = $include_dir_proc.err.lines.grep({ $_ eq INCLUDES_BEGIN ^ff^ $_ eq INCLUDES_END })
                                                      .map({ .trim-leading });

# Get include directories from command line
my @custom_include_dirs = @*ARGS.grep({ .starts-with('-I') }).map({ .substr(2) });

# Find specified include file
if %*ENV{'HEADER'}:exists {
    my @include_dirs = flat @default_include_dirs, @custom_include_dirs;
    my @include_files = @include_dirs.map({ $_ ~ '/' ~ %*ENV{'HEADER'} })
                                     .grep({ .IO.e });

    for @include_files { .put }
    put 'header not found' if @include_files.elems == 0;
}

# Actually execute gcc
run 'gcc', @*ARGS;
