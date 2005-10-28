
BEGIN {
    our @modules = qw(
        Class::DBI::ViewLoader::Pg
    );
}

use File::Spec::Functions qw( catfile );

use Test::More tests => our @modules * 2;

SKIP: {
    eval 'use Test::Pod';

    skip "Test::Pod not installed", scalar @modules if $@;

    for my $module (@modules) {
        my @path = ('lib', split('::', $module));
        my $file = pop(@path) . '.pm';
        
        pod_file_ok(catfile(@path, $file), "$module pod ok");
    }
}

SKIP: {
    eval 'use Test::Pod::Coverage';

    skip "Test::Pod::Coverage not installed", scalar @modules if $@;

    for my $module (@modules) {
        pod_coverage_ok(
            $module,
            "$module pod coverage ok"
        );
    }
}

__END__

vim: ft=perl
