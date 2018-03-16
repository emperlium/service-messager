use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Nick::Messager',
    VERSION_FROM    => 'lib/Nick/Messager.pm',
    PREREQ_PM       => {
        'IO::Socket::INET' => 0,
        'IO::Select' => 0
    }
);
