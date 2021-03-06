# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
package Refget::App::Controller::Seq;

use Mojo::Base 'Mojolicious::Controller';
use Refget::Util qw/allowed_algorithm/;
use Refget::SeqStore::File;

sub id {
  my ($self) = @_;
  my $id = $self->param('id');
  my $start = $self->param('start');
  my $end = $self->param('end');

  my $seq_obj = $self->db()->resultset('Seq')->get_seq($id);
  if(!$seq_obj) {
    return $self->render(text => 'Not Found', status => 404);
  }
  my $seq_size = $seq_obj->size();

  my $range = $self->req->headers->range;
  if($range) {
    if($start || $end) {
      return $self->render(text => 'Invalid Input', status => 400);
    }
    #Parse header. Increase end by one as byte ranges are always from 0
    if(($start,$end) = $range =~ /^bytes=(\d+)-(\d+)$/) {
      $end++;
    }
    else {
      return $self->render(text => 'Invalid Input', status => 400);
    }
    if($seq_obj->circular() && $start > $end) { # cannot request circs across the ori using range
      return $self->render(text => 'Range Not Satisfiable', status => 416);
    }
    if($start >= $seq_size) {
      return $self->render(text => 'Range Not Satisfiable', status => 416) if defined $end;
      return $self->render(text => 'Bad Request', status => 400);
    }

    $end = $seq_size if $end > $seq_size;
  }

  return $self->render(text => 'Bad Request', status => 400) if defined $start && $start !~ /^\d+$/;
  return $self->render(text => 'Bad Request', status => 400) if defined $end && $end !~ /^\d+$/;

  if(!$seq_obj->circular()) {
    if($start && $end && $start > $end) {
      return $self->render(text => 'Range Not Satisfiable', status => 416);
    }
  }
  if($start && $start >= $seq_size) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }
  if($end && $end > $seq_size) {
    return $self->render(text => 'Range Not Satisfiable', status => 416);
  }

  if(defined $start || defined $end) {
    $self->res->headers->accept_ranges('none');
  }

  # Now check for status and set to 206 for Range and leave as 200 for other situations
  my $status = 200;
  $status = 206 if $range;

  $self->respond_to(
    txt => sub { $self->render(data => $self->get_seq($seq_obj, $start, $end), status => $status); },
    fasta => sub { $self->render(data => $self->to_fasta($seq_obj, $start, $end)); },
    any => { data => 'Not Acceptable', status => 406 }
  );
}

sub get_seq {
  my ($self, $seq_obj, $start, $end) = @_;
  return $self->seq_fetcher()->get_seq($seq_obj, $start, $end);
}

sub to_fasta {
	my ($self, $seq_obj, $start, $end, $residues_per_line) = @_;
	$residues_per_line //= 60;
	my $seq = $self->get_seq($seq_obj, $start, $end);
	$seq =~ s/(\w{$residues_per_line})/$1\n/g;
	my $id = $seq_obj->default_checksum();
	return ">${id}\n${seq}";
}

1;