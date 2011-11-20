# =begin Pod
# 
# =head1 JSON::Tiny
# 
# C<JSON::Tiny> is a minimalistic module that reads and writes JSON.
# It supports strings, numbers, arrays and hashes (no custom objects).
# 
# =head1 Synopsis
# 
#     use JSON::Tiny;
#     my $json = to-json([1, 2, "a third item"]);
#     my $copy-of-original-data-structure = from-json($json);
# 
# =end Pod

module JSON::Tiny;

use JSON::Tiny::Actions;
use JSON::Tiny::Grammar;

proto to-json($) is export {*}

multi to-json(Real:D $d) { ~$d }
multi to-json(Bool:D $d) { $d ?? 'true' !! 'false'; }
multi to-json(Str:D  $d) {
    '"'
    ~ (~$d).trans(['"',  '\\',   "\b", "\f", "\n", "\r", "\t"]
            => ['\"', '\\\\', '\b', '\f', '\n', '\r', '\t'])\
            # RAKUDO: This would be nicer to write as <-[\c32..\c126]>,
            #         but Rakudo doesn't do \c yet. [perl #73698]
            .subst(/<-[\ ..~]>/, { ord(~$_).fmt('\u%04x') }, :g)
    ~ '"'
}
multi to-json(Array:D $d) {
    return  '[ '
            ~ (map { to-json($_) }, $d.values).join(', ')
            ~ ' ]';
}
multi to-json(Hash:D  $d) {
    return '{ '
            ~ (map { to-json(.key) ~ ' : ' ~ to-json(.value) }, $d.pairs).join(', ')
            ~ ' }';
}

multi to-json(Any:U $) { 'null' }
multi to-json(Any:D $s) {
    die "Can't serialize an object of type " ~ $s.WHAT.perl
}

sub from-json($text) is export {
    my $a = JSON::Tiny::Actions.new();
    my $o = JSON::Tiny::Grammar.parse($text, :actions($a));
    return $o.ast;
}
# vim: ft=perl6
