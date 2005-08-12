#!/usr/bin/env perl 
use strict;
use warnings;

use Test::More tests => 16;

use Module::Build;
my $builder = Module::Build->current;
my($db_name, $db_host, $user, $pass) = map {$builder->args($_)} qw( db_name db_host user pass );

BEGIN {
    # Class::DBI::ViewLoader::Pg should get loaded by Module::Pluggable
    use_ok('Class::DBI::ViewLoader');
}

my $loader = new Class::DBI::ViewLoader (
	dsn => "dbi:Pg:dbname=$db_name;host=$db_host",
	username => $user,
	password => $pass,
	options => { RaiseError => 1, AutoCommit => 0 },
	namespace => 'Test::View',
	exclude => qr(^actor)i,
    );

isa_ok($loader, 'Class::DBI::ViewLoader::Pg', 'Correct driver loaded');
my @classes = $loader->load_views;
is(@classes, 1, 'loaded 1 view');
is($classes[0], 'Test::View::FilmRoles', 'view name is as expected');

ok(Test::View::FilmRoles->isa('Class::DBI::Pg'), 'generated class isa Class::DBI::Pg');

my(@matches, @expected);
@matches = $classes[0]->search(player => 'Sean Connery');
is(@matches, 1, '1 match for Sean Connery');
@expected = ("Sean Connery played James Bond in Dr. No");
is($matches[0]->description, $expected[0], $expected[0]);

@matches = $classes[0]->search(movie => 'Casino Royale');
is(@matches, 2, '2 matches for Casino Royale');
my %lookup = map {$_->description => 1} @matches;
@expected = (
	'Peter Sellers played James Bond in Casino Royale',
	'Peter Sellers played Evelyn Tremble in Casino Royale'
    );
for my $expected (@expected) {
    ok($lookup{$expected}, $expected);
}

# Make the include rule the exclude rule and remove the exclude rule.
$loader->set_exclude;

my %classes = map {$_ => 1} @classes = $loader->load_views();
@expected = qw( Test::View::ActorRoles Test::View::FilmRoles );
is(@classes, 2,	'Loaded 1 more rule');
for my $class (@expected) {
    ok($classes{$class}, "loaded $class");
}
@matches = Test::View::ActorRoles->search(actor => 'Pierce Brosnan');
is(@matches, 2, '2 matches for Pierce Brosnan');
is($matches[0]->actor, $matches[1]->actor, 'identical actor field');
is($matches[0]->role, $matches[1]->role, 'identical role field');

__END__

vim: ft=perl
