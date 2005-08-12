package Class::DBI::ViewLoader::Pg;

use strict;
use warnings;

our $VERSION = '0.02';

=head1 NAME

Class::DBI::ViewLoader::Pg - Class::DBI::Viewloader implementation for Postgresql.

=head1 SYNOPSIS

See L<Class::DBI::ViewLoader>

=head1 DESCRIPTION

This is the postgresql driver for L<Class::DBI::ViewLoader>, 

=head1 METHODS

=cut

use Class::DBI::Pg;

use base qw( Class::DBI::ViewLoader );

=head2 base_class

Causes generated classes to inherit from Class::DBI::Pg.

=cut

sub base_class { 'Class::DBI::Pg' };

=head2 get_views

See L<Class::DBI::ViewLoader> for a description of this method.

=cut

sub get_views {
    my $self = shift;
    my $dbh = $self->_get_dbi_handle;

    return $dbh->tables(
	    undef,	    # catalog
	    "public",   # schema
	    "",	    # name
	    "view",	    # type
	    { noprefix => 1, pg_noprefix => 1 }
	);
}


=head2 get_view_cols

See L<Class::DBI::ViewLoader> for a description of this method.

=cut

# cribbed from Class::DBI::Pg->set_up_table
sub get_view_cols {
    my($self, $view) = @_;
    my $sth = $self->_get_cols_sth;

    $sth->execute($view);

    my @columns = map {$_->[0]} @{$sth->fetchall_arrayref};

    # warn "Got ". @columns ." column".(@columns==1?'':'s')." from $view\n";

    $sth->finish;

    return grep { !/^\.+pg\.dropped\.\d+\.+$/ } @columns;
}

my $col_sql = <<END_SQL;
SELECT a.attname
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_attribute a on a.attrelid = c.oid
WHERE c.relname = ?
  AND a.attnum > 0
ORDER BY a.attnum
END_SQL

sub _get_cols_sth {
    my $self = shift;

    # keep this in one place
    my $key = '__col_sth';

    if(defined $self->{$key}) {
	return $self->{$key};
    }
    else {
	my $dbh = $self->_get_dbi_handle;

	return $self->{$key} = $dbh->prepare($col_sql);
    }
}

1;

__END__

=head1 SEE ALSO

L<Class::DBI::ViewLoader>, L<Class::DBI::Loader>, L<Class::DBI>, L<http://www.postgresql.org/>

=head1 AUTHOR

Matt Lawrence E<lt>mattlaw@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2005 Matt Lawrence, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
