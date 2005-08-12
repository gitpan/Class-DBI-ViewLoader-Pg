#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use File::Spec::Functions qw( catfile );

use Test::More tests => 6;

use Module::Build;
my $builder = Module::Build->current;
my($db_name, $db_host, $user, $pass, $init_db) = map {$builder->args($_)} qw( db_name db_host user pass init_db);

my $dbh = DBI->connect(
	"dbi:Pg:host=$db_host;dbname=$init_db",
	$user,
	$pass,
	{ AutoCommit => 1, RaiseError => 0, PrintError => 0 }
    ) or die $DBI::errstr;

my $create = "create database $db_name";
my $drop = "drop database $db_name";

unless ($dbh->do($create)) {
    diag "re-creating database $db_name";

    $dbh->{RaiseError} = 1;
    $dbh->do($drop);
    $dbh->do($create);
}

pass("set up $db_name");

$dbh->disconnect;

ok($dbh = DBI->connect(
	"dbi:Pg:dbname=$db_name;host=$db_host;",
	$user,
	$pass,
	{ AutoCommit => 0, RaiseError => 1 }
    ), "connected to $db_name");

my $sql;
my $sql_file = catfile(qw( t data create_tables.pgsql));

open SQL, '<', $sql_file or die "Can't read $sql_file: $!";
{ local $/; $sql = <SQL> }
close SQL;

local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /^NOTICE/ };

my $sth = $dbh->prepare($sql);
ok($sth, 'preparing to inject data');
ok($sth->execute, 'data injected');
ok($dbh->commit, 'data committed');

$sth->finish;
$dbh->disconnect;

pass('All done');

__END__

vim: ft=perl
