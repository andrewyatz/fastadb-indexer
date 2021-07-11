use strict;
use warnings;
use Test::More;

use Fastadb::Util qw/reference_retrieval_digest/;
use Fastadb::Fmt::Fasta;
use File::Basename qw/dirname/;
use File::Spec;

is(reference_retrieval_digest('ACGT'), '68a178f7c740c5c240aa67ba41843b119d3bf9f8b0f0ac36', 'Check basic round tripping of reference retrieval digest');

my $test_data_dir = File::Spec->catdir(File::Spec->rel2abs(dirname(__FILE__)), 'data');

my $fasta_iter = Fastadb::Fmt::Fasta->new(file => File::Spec->catfile($test_data_dir, 'test.fa'), type => 'dna');
is(
  reference_retrieval_digest($fasta_iter->iterate()->{sequence}),
  'b28e54e972297b88324983e18b20420470acac31baff8520',
  'Checking basic encoding of known sequence test1'
);
is(
  reference_retrieval_digest($fasta_iter->iterate()->{sequence}),
  '999687f722592a0959abb475879ccb3b20064d0ad7bbbd85',
  'Checking basic encoding of known sequence test2'
);
is(
  reference_retrieval_digest($fasta_iter->iterate()->{sequence}),
  '21b4f4bd9e64ed355c3eb676a28ebedaf6d8f17bdc365995',
  'Checking basic encoding of known sequence test3'
);

done_testing();
