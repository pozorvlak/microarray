use ExtUtils::MakeMaker;

WriteMakefile(
	NAME	=> 'microarray',
	VERSION_FROM => 'microarray.pl',
	PREREQ_PM => {
		'Test::More'		=> 0.88,
		'Statistics::Lite'	=> 0,
		'List::MoreUtils'	=> 0,
		'List::Util'		=> 0,
		'Scalar::Util'		=> 0,
	}
);
