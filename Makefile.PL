use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Business::Tax::VAT::Validation::DE',
    'VERSION_FROM'	=> 'DE.pm', # finds $VERSION
    'PREREQ_PM'		=> {XML::Simple => 2.18,Business::Tax::VAT::Validation => 0.20,LWP::Simple => 0.01},
    ($] >= 5.005 ? (
      ABSTRACT_FROM => 'DE.pm', 
      AUTHOR     => 'Stefan Gipper <stefanos@cpan.org>',
    ) : ()),
);
