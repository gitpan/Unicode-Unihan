#
# $Id: 0-useme.t,v 0.1 2002/04/26 07:43:26 dankogai Exp dankogai $
#

use strict;
use Test::More tests => 2;

use_ok('Unicode::Unihan', 'use');
is(ref(Unicode::Unihan->new) => 'Unicode::Unihan', 'class');

__END__
