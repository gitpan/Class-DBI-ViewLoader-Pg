use strict;
use warnings;

use Module::Build;

=head1 NAME

Build.PL - Build script for Class::DBI::ViewLoader

=head1 SYNOPSIS

    perl Build.PL --db_name=mydb
		  --user=username
		  --pass=password
		  --db_host=host
		  --init_db=db

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
	    'Class::DBI::ViewLoader' => '0.02',
	},
	build_requires => {
	    'Test::More' => 0,
	},

	create_makefile_pl => 'passthrough',
	create_readme => 1,

	get_options => {
	    db_host => { type => '=s' },
	    db_name => { type => '=s' },
	    user => { type => '=s' },
	    pass => { type => '=s' },
	    init_db => { type => '=s' }
	}
    );

unless (defined $build->args('db_host')) {
    $build->args(
	'db_host',
	$build->prompt("Hostname to use when connecting to test database", 'localhost')
    );
}

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

unless (defined $build->args('init_db')) {
    my $user = $build->args('user');
    $build->args(
	'init_db',
	$build->prompt(
	    "We'll need the name of an existing database to establish a\n".
	    "connection before the test database can be built.\n\n".
	    "The database specified here will not be modified in any way\n\n".
	    "Please specify an existing database name",
	    $user
	)
    );
}


$build->create_build_script;
