package Business::Tax::VAT::Validation::DE;
use strict;
use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/bffcheck/;
our $VERSION = '0.2';
use Business::Tax::VAT::Validation;
#use Algorithm::CheckDigits;
use LWP::Simple qw ($ua head get);
$ua->timeout(10);
use XML::Simple;

sub bffcheck {
	# http://evatr.bff-online.de/eVatR/
	my $deVAT = shift || '';
	my $myVAT = shift || '';
	my $Firmenname = shift || '';
	my $Ort = shift || '';
	my $PLZ = shift || '';
	my $Strasse = shift || '';
	my $Druck = shift || '';
	$Druck = "nein" if($Druck ne "nein" && $Druck ne "ja");
	my $hvatn = Business::Tax::VAT::Validation->new();
	my $hvatn2 = Business::Tax::VAT::Validation->new();
	my %newdata;
	if($hvatn->check($deVAT) && $hvatn2->check($myVAT)){
		#my $bb = CheckDigits('ustid_de');#ustid_at, ustid_be, ustid_de, ustid_dk, ustid_fi, ustid_gr, ustid_ie, ustid_lu, ustid_nl, ustid_pl, ustid_pt
		#if($bb->is_valid($deVAT)){
		#	return "OK";
		#}

		my $data = get("http://evatr.bff-online.de/evatrRPC?UstId_1=$deVAT&UstId_2=$myVAT&Firmenname=$Firmenname&Ort=$Ort&PLZ=$PLZ&Strasse=$Strasse&Druck=$Druck");
		#
		#Errorcodes http://evatr.bff-online.de/eVatR/xmlrpc/codes
		#Antwort http://evatr.bff-online.de/eVatR/xmlrpc/aufbau
		#
		if($data){
			my $ref = XMLin($data);
			for(my $i = 0; $i < @{$ref->{'param'}}; $i++){
				if(ref(${${${${$ref->{'param'}}[$i]}{'value'}{'array'}{'data'}{'value'}}[1]}{'string'}) ne 'HASH'){
					$newdata{${${${${$ref->{'param'}}[$i]}{'value'}{'array'}{'data'}{'value'}}[0]}{'string'}} = ${${${${$ref->{'param'}}[$i]}{'value'}{'array'}{'data'}{'value'}}[1]}{'string'};
				}else{
					$newdata{${${${${$ref->{'param'}}[$i]}{'value'}{'array'}{'data'}{'value'}}[0]}{'string'}} = "";
				}
			}

			if($newdata{'Druck'} eq $Druck && $newdata{'ErrorCode'} eq "200" && !$newdata{'Erg_PLZ'} && !$newdata{'Erg_Ort'} && !$newdata{'Erg_Str'} && !$newdata{'Erg_Name'} or $newdata{'Druck'} eq $Druck && $newdata{'ErrorCode'} eq "200" && $newdata{'Erg_PLZ'} eq "A" && $newdata{'Erg_Ort'} eq "A" && $newdata{'Erg_Str'} eq "A" && $newdata{'Erg_Name'} eq "A"){
				return 1,%newdata;
			}else{
				return 0,%newdata;
			}
		}else{
			$newdata{'ErrorCode'} = "Timeout";
			return 0,%newdata;
		}
	}else{
		# Errorcodes:
		# 0 Unknown MS code : Internal checkup failed (Specified Member State does not exists)
		# 1 Invalid VAT number format : Internal checkup failed (bad syntax)
		# 2 This VAT number doesn't exists in EU database : distant checkup
		# 3 This VAT number contains errors : distant checkup
		# 17 Time out connecting to the database : Temporary error when the connection to the database times out
		# 18 Member Sevice Unavailable: The EU database is unable to reach the requested member's database.
		# 257 Invalid response, please contact the author of this module. : This normally only happens if this software doesn't recognize any valid pattern into the response document: this generally means that the database interface has been modified, and you'll make the author happy by submitting the returned response !!!
		$newdata{'ErrorCode'} = "$deVAT: " . $hvatn->get_last_error_code . " " . $hvatn->get_last_error . " - $myVAT: " . $hvatn->get_last_error_code . " " . $hvatn->get_last_error;
		return 0,%newdata;
	}
}


=pod

=head1 NAME

Business::Tax::VAT::Validation::DE - de vat check

=head1 SYNOPSIS

	use Business::Tax::VAT::Validation::DE;
	my $deVAT = "DE123456789";# UstId_1
	my $myVAT = "ATU12345678";# UstId_2

	# short
	my($back,%data) = bffcheck($deVAT,$myVAT);

	# or long
	my($back,%data) = bffcheck($deVAT,$myVAT,$Firmenname,$Ort,$PLZ,$Strasse,$Druck);# $Druck "ja" for yes or "nein" for no

	if($back){
		print "OK\n";
	}else{
		print "Not OK\n";
	}
	for (keys %data){
		print "$_: $data{$_}\n";
	}

	See Errorcodes %data{'ErrorCode'} http://evatr.bff-online.de/eVatR/xmlrpc/codes
	and datafields in %data http://evatr.bff-online.de/eVatR/xmlrpc/aufbau


=head1 DESCRIPTION

Business::Tax::VAT::Validation::DE de vat check

=head1 AUTHOR

    -

=head1 COPYRIGHT

	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
