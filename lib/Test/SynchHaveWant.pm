package Test::SynchHaveWant;

use warnings;
use strict;

use Data::Dumper;
use Carp 'confess';
use base 'Exporter';
our @EXPORT_OK = qw(
  have
  want
);

=head1 NAME

Test::SynchHaveWant - Synchronize volatile have/want values for tests

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Test::Most;
    use Test::SynchHaveWant qw/
        have_want
        want
    /;

    my $have = some_complex_data();
    my $want = want();

    eq_or_diff have_want($have,$want), 'have and want should be the same';

    __DATA__
    [
        {
            'bar' => [ 3, 4 ],
            'foo' => 1
        },
        0,
        bless( [ 'this', 'that', 'glarble', 'fetch' ], 'Foobar' ),
    ]

=cut

my %DATA_SECTION_FOR;
my %NEW_DATA_FOR;

sub _read_data_section {
    my $caller = shift;
    my $key    = _get_key();

    my $__DATA__ = do { no strict 'refs'; \*{"${caller}::DATA"} };
    unless ( defined fileno $__DATA__ ) {
        confess "__DATA__ section not found for package ($caller)";
    }

    seek $__DATA__, 0, 0;
    my $data_section = join '', <$__DATA__>;
    $data_section =~ s/^.*\n__DATA__\n/\n/s;    # for win32
    $data_section =~ s/\n__END__\n.*$/\n/s;

    $data_section = eval $data_section;
    if ( my $error = $@ ) {
        confess "Error reading __DATA__ for ($caller): $error";
    }
    unless ( 'ARRAY' eq ( ref $data_section || '' ) ) {
        confess "__DATA__ did not contain an array reference";
    }
    $DATA_SECTION_FOR{$key} = $data_section;
}

=head1 DO NOT USE THIS CODE WITHOUT SOURCE CONTROL

This is C<ALPHA CODE>. It's very alpha code. It's dangerous code. It attempts to
B<REWRITE YOUR TESTS> and if it screws up, you had better be using B<SOURCE
CONTROL> so you can revert.

That being said, if you need this code and you really, really understand
what's going on, go ahead and use it at your own risk.

=head1 DESCRIPTION

Sometimes you have extremely volatile data/code and you I<know> your tests are
correct even though they've failed due to subtle differences in how data is
created.  The first pass I had at solving this problem was to effectively
compute the edit distance for data structures, but even that failed as
differences emerged over time (see
L<http://blogs.perl.org/users/ovid/2011/02/is-almost.html>).

For this module, we're giving devs a chance to rewrite their test results on
the fly, assuming that the new results of their code is correct.

This is generally an I<INCREDIBLY STUPID IDEA>.  It's very stupid.  Not only
do we attempt to rewrite your __DATA__ sections, we make it very easy for
you to have bogus tests because you may incorrectly assume that the new data
you're returning is correct.  That's why this is a B<BIG, FAT, DANGEROUS
EXPERIMENT>.

Sadly, I've been asked a couple of times why I feel the need to experiment
with writing tests in this area, but I can't tell you that due to my NDA.

=head1 EXPORT

=head2 C<have>

 is have($have), want(), 'have should equal want';

Ordinarily this function is a no-op. It merely returns the value it is passed.
However, if C<< $ENV{SYNCH_HAVE_WANT} >> contains a true value, this function
will push the have() value on a stack and at the end of the test run, will
attempt to write the data to the __DATA__ section.

=cut

sub have {
    my $have = shift;
    return $have;
}

=head2 C<want>

 is have($have), want(), 'have should equal want';

Returns the current expected test result. Attempting to read past the end of
the test results will result in a fatal error.

=cut

sub want {
    my $key = _get_key();
    unless ( exists $DATA_SECTION_FOR{$key} ) {
        _read_data_section( scalar caller );
    }
    my $data_section = $DATA_SECTION_FOR{$key};
    unless (@$data_section) {
        confess("Attempt to read past end of __DATA__ for $0");
    }
    return shift @$data_section;
}

# XXX eventually I may have to add to this if people start using this
sub _get_key {
    return $0;
}

=head1 AUTHOR

Curtis 'Ovid' Poe, C<< <ovid at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-synchhavewant at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-SynchHaveWant>.  I will
be notified, and then you'll automatically be notified of progress on your bug
as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::SynchHaveWant

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-SynchHaveWant>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-SynchHaveWant>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-SynchHaveWant>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-SynchHaveWant/>

=back

=head1 ACKNOWLEDGEMENTS

You don't really think I'm going to blame anyone else for this idiocy, do you?

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Curtis 'Ovid' Poe.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
