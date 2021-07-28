#!/usr/bin/env perl6

sub find(IO::Path $root, Junction :$extension) {
    my IO::Path @stack = $root;
    gather {
        while @stack {
            for @stack.pop.dir -> $file {
                next unless $file.d or $file.extension eq $extension;
                if $file.d {
                    @stack.append($file);
                } else {
                    take $file;
                }
            }
        }
    }
}

sub MAIN(Str $called-function, Str :$root = '.', Str :$arguments = '') {
    die "$root: not a directory" unless $root.IO.d;

    # Filter for function call
    my token whitespace { [\h|\t|\n]* };
    my token bracketed-expr { \( [<~~>|<-[\(\)]>]* \) };

    # Look for function call in all sources
    for find($root.IO, extension => 'c' | 'h') -> $file {
        my @matches = $file.slurp.match(/"$called-function" <whitespace> <bracketed-expr>/, :exhaustive);
        for @matches -> $match {
            put $file.Str ~ ": " ~ $match if $arguments eq '' or $match<bracketed-expr> eq "($arguments)";
        }
    }
}
