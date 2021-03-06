# Mojo before all
requires 'Mojolicious', '<=8.17';

# Normal deps
requires 'Moose';
requires 'DBIx::Class::Schema';
requires 'DBD::SQLite';
requires 'SQL::Translator';
requires 'Digest::SHA';
requires 'Digest::MD5';
requires 'Class::Method::Modifiers';
requires 'DBIx::Class::InflateColumn::Boolean';
requires 'DBD::Pg';
requires 'DBD::mysql';
requires 'IO::Compress::Gzip';
requires 'IO::Uncompress::Gunzip';
requires 'Class::Load';
requires 'Redis';

# Mojo support
requires "EV";
requires 'IO::Socket::Socks';
requires 'IO::Socket::SSL';
#requires "Mojolicious::Plugin::JSON::XS";
requires "Mojolicious::Plugin::AccessLog";
requires "Mojo::IOLoop::ReadWriteFork";

on 'test' => sub {
  requires 'Test::DBIx::Class';
  requires 'IO::Scalar';
  requires 'Test::Differences';
  requires 'Test::File';
  requires 'Test::Mock::Redis';
};
