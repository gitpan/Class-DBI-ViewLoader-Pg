
# Test that the api defined by Class::DBI::ViewLoader is implemented by this
# class

use strict;
use warnings;

use Test::More;

use lib qw( t/lib );

our($class, @api_methods);

BEGIN {
    my $plugin_name = 'Pg';
    our $class = "Class::DBI::ViewLoader::$plugin_name";
    our @api_methods = qw(
	    base_class
	    get_views
	    get_view_cols
	);

    plan tests => @api_methods + 2;

    use_ok($class);
}

ok($class->isa('Class::DBI::ViewLoader'));
for my $method (@api_methods) {
    can_ok($class, $method);
}

__END__

vim: ft=perl
