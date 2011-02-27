#!/usr/bin/env perl

package NotMain;

use strict;
use warnings;

use Test::More tests => 5;
use Test::SynchHaveWant qw(have want);

is_deeply have({
    foo => 1,
    bar => [ 3, 4 ],
  }),
  want(), 'The first value of want should be correct';

is 0, want(), '... and we should be able to handle false values';
my $blessed = want();
isa_ok have($blessed), 'Foobar', '... and it should be able to handle blessed values';
is_deeply have(bless(
    [
        this    => 'that',
        glarble => 'fetch',
    ] => 'Foobar'
  )),
  $blessed,
  '... and return its data correctly';

eval { want() };
my $error = $@;
like $error, qr/^Attempt to read past end of __DATA__/,
    '... but we get a fatal error when we attempt to read past the end of the data';

__DATA__
[
    {
        'bar' => [ 3, 4 ],
        'foo' => 1
    },
    0,
    bless( [ 'this', 'that', 'glarble', 'fetch' ], 'Foobar' ),
]
