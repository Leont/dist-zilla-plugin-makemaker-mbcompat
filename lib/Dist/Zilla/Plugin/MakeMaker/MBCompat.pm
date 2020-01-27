package Dist::Zilla::Plugin::MakeMaker::MBCompat;

use 5.014;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker';

has '+eumm_version' => (
	default => '7.12',
);

sub write_makefile_args {
	my $self = shift;
	my $args = $self->SUPER::write_makefile_args;

	my (@xs_files, @pm_files);
	for my $file (@{ $self->zilla->files }) {
		my $name = $file->name;
		next unless $name =~ / ^ lib \/ /xms;
		if ($name =~ / \.xs $ /xms) {
			push @xs_files, $name;
		}
		elsif ($name =~ / \. p(?:m|od) $ /xms) {
			push @pm_files, $name;
		}
	}

	if (@xs_files) {
		for my $xs_file (@xs_files) {
			$args->{XS}{$xs_file} = $xs_file =~ s/ \.xs $ /.c/xmsr;
		}
		for my $pm_file (@pm_files) {
			$args->{PM}{$pm_file} = $pm_file =~ s/ ^ lib /\$(INST_ARCHLIB)/xmsr;
		}
		$args->{XSMULTI} = 1;
	}
	else {
		for my $pm_file (@pm_files) {
			$args->{PM}{$pm_file} = $pm_file =~ s/ ^ lib /\$(INST_LIB)/xmsr;
		}
	}

	return $args;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Write a Makefile.PL that can compile a dist with a Module::Build file layout
