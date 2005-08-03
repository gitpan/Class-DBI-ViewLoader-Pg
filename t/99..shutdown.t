
use strict;
use warnings;

use DBI;

use Module::Build;
use Test::More tests => 1;

my $builder = Module::Build->current;
my($db_name, $user, $pass) = map {$builder->args($_)} qw( db_name user pass );

my $dbh = DBI->connect(
	"dbi:Pg:",
	$user,
	$pass,
	{ AutoCommit => 1, RaiseError => 1 }
    );

$dbh->do("drop database $db_name");

$dbh->disconnect;

pass;

__END__

vim: ft=perl
