use strict;
use warnings;

use Module::Build;

=head1 NAME

Build.PL - Build script for Class::DBI::ViewLoader

=head1 SYNOPSIS

    perl Build.PL --db_name=mydb --user=username --pass=password
    ./Build
    ./Build test
    ./Build install

=cut

my $build = new Module::Build (
	module_name => 'Class::DBI::ViewLoader::Pg',
	dist_author => 'Matt Lawrence <mattlaw@cpan.org',
	license => 'perl',

	requires => {
	    'Class::DBI::Pg' => 0,
	    'DBD::Pg' => '1.31',
	    'Class::DBI::ViewLoader' => '0.01',
	},
	build_requires => {
	    'Test::More' => 0,
	},

	create_makefile_pl => 'passthrough',
	create_readme => 1,

	get_options => {
	    db_name => { type => '=s' },
	    user => { type => '=s' },
	    pass => { type => '=s' }
	}
    );

unless ($build->args('db_name')) {
    $build->args(
	'db_name', 
	$build->prompt(
	    "Name of (non-existant) test database to use",
	    'cdbi_viewloader_test'
	)
    );
}

unless (defined $build->args('user')) {
    $build->args(
	'user',
	$build->prompt("Username to use when connecting to test database", getlogin)
    );
}

unless (defined $build->args('pass')) {
    $build->args(
	'pass',
	$build->prompt("Password to use when connecting to test database", '')
    );
}

$build->create_build_script;
