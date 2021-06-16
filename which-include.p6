#!/usr/bin/env perl6
# GCC wrapper to extract the absolute path of an included file.

{
    run 'gcc', '-v', :out, :err;
    CATCH {
        put 'Cannot execute gcc';
        exit 1;
    }
}

# Get default include directories
constant INCLUDES_BEGIN = '#include <...> search starts here:';
constant INCLUDES_END = 'End of search list.';

my $include_dir_proc = shell 'echo | gcc -xc -E -v -', :out, :err;
my @default_include_dirs = grep { $_ eq INCLUDES_BEGIN ^ff^ $_ eq INCLUDES_END }, $include_dir_proc.err.lines;
for (@default_include_dirs) { $_ = .trim-leading }

# Get include directories from command line
my @custom_include_dirs = grep { .starts-with('-I') }, @*ARGS;
for (@custom_include_dirs) { $_ = .substr(2) }

# Find specified include file
if %*ENV{'HEADER'}:exists {
    my @include_dirs = flat @default_include_dirs, @custom_include_dirs;
    my $found = False;

    for (@include_dirs) {
        my $header = $_ ~ '/' ~ %*ENV{'HEADER'};
        if $header.IO.e {
            put $header;
            $found = True;
            last;
        }
    }

    put 'header not found' if not $found;
}

# Actually execute gcc
run 'gcc', @*ARGS;
