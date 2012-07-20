use strict;
use Test::More;
eval q{ use Test::Perl::Critic(-exclude => ['strict']) };
plan skip_all => "Test::Perl::Critic is not installed." if $@;
all_critic_ok("lib");

# http://community.livejournal.com/ru_perl/383519.html
