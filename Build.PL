use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Test::SynchHaveWant',
    license             => 'perl',
    dist_author         => q{Curtis 'Ovid' Poe <ovid@cpan.org>},
    dist_version_from   => 'lib/Test/SynchHaveWant.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Test-SynchHaveWant-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();