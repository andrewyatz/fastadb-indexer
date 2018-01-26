#!/usr/bin/env perl
use Mojo::Base -strict;

use File::Basename 'dirname';
use File::Spec;

use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), '..', 'lib';

# Check if Mojolicious is installed;
die <<EOF unless eval { require Mojolicious::Commands; 1 };
It looks like you don't have the Mojolicious framework installed.
Please visit http://mojolicio.us for detailed installation instructions.
EOF

# Start commands
Mojolicious::Commands->start_app('Fastadb::App');
