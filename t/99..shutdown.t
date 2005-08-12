#!/usr/bin/env perl 
use strict;
use warnings;

use DBI;

use Module::Build;
use Test::More tests => 1;

my $builder = Module::Build->current;
my($db_name, $db_host, $user, $pass, $init_db) = map {$builder->args($_)} qw( db_name db_host user pass init_db);

my $dbh = DBI->connect(
	"dbi:Pg:dbname=$init_db;host=$db_host",
	$user,
	$pass,
	{ AutoCommit => 1, RaiseError => 1 }
    );

$dbh->do("drop database $db_name");

$dbh->disconnect;

pass;

__END__

vim: ft=perl
