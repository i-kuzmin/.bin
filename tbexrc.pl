#/bin/perl
use strict;
# Generate .exrc for current TB Project

our $SECTION = "' tbexrc";
our $EXRC_FILE = '.tbexrc';

sub write_exrc
{
    our $SECTION;;
    our $EXRC_FILE;
    open( my $fh, ">", $EXRC_FILE)
        || die ("# can't open $EXRC_FILE");

#    print $fh "$SECTION -- start\n";
    print $fh join ("", @_);

    print $fh 'if filereadable(".exrc")' . "\n".
              '    source .exrc'         . "\n".
              'endif'                    . "\n";
#    print $fh "$SECTION -- end\n";

    close ($fh);
}

sub vim_path
{
    my @res;
    foreach (@_) {
        s|^\./||;
        push @res,"set path+=$_\n" if -d;
    }
    return @res;
}

sub main
{
    my @INC;
    my @DEF;
    my @SRC;

    my %TBMAKE;

    foreach (@_) {
       push @INC, $1 if /^-I(.+)/;
       push @DEF     if /^-D(.+)/;
       push @SRC     if /^[^-]/;
       $TBMAKE{$1} = $2 if /^--(\w+):(.+)$/;
   }

   write_exrc(
       vim_path @INC
   );
   return 0;
}

exit main @ARGV;
