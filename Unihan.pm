package Unicode::Unihan;

use 5.006;
use strict;
use warnings;

our ( $VERSION ) = (q$Revision: 0.01 $ =~ /([\d\.]+)/o);
our $DEBUG = 0;

use Carp;
BEGIN{  @AnyDBM_File::ISA = qw(DB_File GDBM_File SDBM_File) ; }
use AnyDBM_File;
use Fcntl;

sub new($;){
    my $class = shift;
    my $dir = __FILE__; $dir =~ s/\.pm//o;
    -d $dir or die "DB Directory $dir nonexistent!";
    return bless { '_dir_' => $dir, @_ } => $class;
}

sub load($$){
    my ($self, $name) = @_;
    if ($self->{'-savemem'}){
	for my $k (keys %$self){
	    $k eq $name and next;
            $k =~ /^[A-Z]/o and delete $self->{$k};
        }
    }
    unless ( $self->{$name} ){
	my $file = $self->{_dir_} . "/$name.db";
	-f $file or croak "There is no DB for $name";
	tie %{$self->{$name}}, 'AnyDBM_File', $file, O_RDONLY, 0444
            or die "$file: $!";
    }
    $self;
}

sub unload($;){
    my $self = shift;
    if (@_){
	while(my $k = shift) {
	    $k =~ /^[A-Z]/o and delete $self->{$k};
	}
    }else{
	for my $k (keys %$self){
	    $k =~ /^[A-Z]/o and delete $self->{$k};
	}
    }
    $self;
}

sub DESTROY {
    $DEBUG and warn "$_[0] destroyed!";
}

sub AUTOLOAD {
    my $self = shift;
    my $name = our $AUTOLOAD;
    $name =~ s/.*:://o;
    $self->load($name);
    no strict 'refs';
    *$AUTOLOAD = sub { 
	my $self = shift; @_ or return;
	my $str = shift;  length($str) or return;
	if (wantarray){
	    my @result = ();
	    for my $ord (unpack("U*", $str)){
		push @result, $self->{$name}{$ord};
	    }
	    return @result;
	}else{
	    return $self->{$name}{ord($str)};
	}
    };
    return $self->$name(@_);
}

1;
__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Unicode::Unihan - The Unihan Data Base 3.2.0

=head1 SYNOPSIS

  use Unicode::Unihan;
  my $db = new Unicode::Unihan;
  print join("," => $db->Mandarin("\x{5c0f}\x{98fc}\x{5f3e}"), "\n";

=head1 ABSTRACT

This module provides a user-friendly interface to the Unicode Unihan
Database 3.2.  With this module, the Unihan database is as easy as
shown in the SYNOPSIS above.

=head1 DESCRIPTION

The first thing you do is make the database available.  Just say

  use Unicode::Unihan;
  my $db = new Unicode::Unihan;

That's all you have to say.  After that, you can access the database
via $db-E<gt>I<tag>($string) where I<tag> is the tag in the Unihan
Database, without 'k' prefix.

=over 4

=item $data = $db-E<gt>I<tag>($string)
=item @data = $db-E<gt>I<tag>($string)

The first form (scalar context) returns the Unihan Database entry of
the first character in $string.  The second form (array context)
checks the entry for each character in $string.

  @data = $db->Mandarin("\x{5c0f}\x{98fc}\x{5f3e}");
  # @data is now ('SHAO4 XIAO3','SI4','DAN4')

  @data = $db->JapaneseKun("\x{5c0f}\x{98fc}\x{5f3e}");
  # @data is now ('CHIISAI KO O','KAU YASHINAU','TAMA HAZUMU HIKU')

=back

=head1 SEE ALSO

=over 2

=item L<perlunintro>

=item L<perlunicode>

=item The Unihand Database, in Text

L<http://www.unicode.org/Public/3.2-Update/Unihan-3.2.0.txt.gz>

=back

=head1 AUTHOR

For the Module:

Dan Kogai E<lt>dankogai@home.dan.intraE<gt>

For the Source Data:

Unicode, Inc.

=head1 COPYRIGHT AND LICENSE

For the Module
Copyright 2002 by Dan Kogai, All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

For the Source Data;

Copyright (c) 1996-2002 Unicode, Inc. All Rights reserved.

 Name: Unihan database
 Unicode version: 3.2.0
 Table version: 1.1
 Date: 15 March 2002

=cut

Format information:

Each line of this file consists of three tab-separated fields.
The first is the Unicode scalar value as U+[x]xxxx (that is, there are
either four or five hex digits)

The second is a tag indicating the type of information in the third field
The third is the line's value (in UTF-8)

The tags and their formats are as follows (in alphabetical order):
	
=head1 TAGS

The following is auto-generated out of Unihan-3.2.0.txt.  The 'k'
prefix in the original source is omitted.

=over 2

=item AccountingNumeric

The value of the character when used in the writing of accounting
numerals.

=item AlternateKangXi

An alternate possible position for the character in the KangXi
dictionary

=item AlternateMorohashi

An alternate possible position for the character in the Morohashi
dictionary

=item BigFive

The Big Five mapping for this character in hex; note that this does
*not* cover any of the Big Five extensions in common use, including
the ETEN extensions.

=item CCCII

The CCCII mapping for this character in hex

=item CNS1986

The CNS 11643-1986 mapping for this character in hex

=item CNS1992

The CNS 11643-1992 mapping for this character in hex

=item Cangjie*

The cangjie input code for the character.  This incorporates data from
the file cangjie-table.b5 by Christian Wittern

=item Cantonese

The Cantonese pronunciation(s) for this character

The romanization used is a modified version of the Yale romanization, 
modified as follows:

(1) No effort is made to distinguish between Yale's "high level" and
"high falling" tones, which are not universally reflected in all
Cantonese romanizations and which appear to be no longer
distinctive in Hong Kong Cantonese. As a general rule, syllables 
which end with a stop (p, t, or k) have the "high level" tone; 
but there are numerous exceptions.

(2) Digits 1-6 are used to indicate the tones --

  1 == High level/high falling
  2 == High rising
  3 == Middle level
  4 == Low falling
  5 == Low rising
  6 == Low level

(3) Accordingly, the letter "H" is *not* used as a tone indicator

Cantonese pronunciations are sorted alphabetically, not in order of
frequency

=item CihaiT*

The position of this character in the Cihai (\x{8fad}\x{6d77})
dictionary, single volume edition, published in Hong Kong by the
Zhonghua Bookstore, 1983 (reprint of the 1947 edition), ISBN
962-231-005-2.

The position is indicated by a decimal number.  The digits to the left
of the decimal are the page number.  The first digit after the decimal
is the row on the page, and the remaining two digits after the decimal
are the position on the row.

=item CompatibilityVariant*

The compatibility decomposition for this ideograph, derived from the
UnicodeData.txt file.

=item Cowles*

The index of this character in Roy T. Cowles, _A Pocket Dictionary of
Cantonese_, Hong Kong: University Press, 1999.

=item DaeJaweon

The position of this character in the Dae Jaweon (Korean) dictionary
used in the four-dictionary sorting algorithm. The position is in the
form "page.position" with the final digit in the position being "0"
for characters actually in the dictionary and "1" for characters not
found in the dictionary and assigned a "virtual" position in the
dictionary.

Thus, "1187.060" indicates the sixth character on page 1187. A
character not in this dictionary but assigned a position between the
6th and 7th characters on page 1187 for sorting purposes would have
the code "1187.061"

The edition used is the first edition, published in Seoul by Samseong
Publishing Co., Ltd., 1988.

=item Definition

An English definition for this character

=item EACC

The EACC mapping for this character in hex

=item Fenn*

Data on the character from _Fenn's Chinese-English Pocket Dictionary_
by Courtenay H. Fenn, Cambridge, Mass.: Harvard University Press,
1942.  The data here consists of a decimal number followed by a letter
A through K.  The decimal number gives the Soothill number for the
character's phonetic, and the letter is a rough frequency indication,
with A indicating the 500 most common ideographs, B the next five
hundred, and so on.

=item Frequency

A rough fequency measurement for the character based on analysis of
Chinese USENET postings

=item GB0

The GB 2312-80 mapping for this character in ku/ten form

=item GB1

The GB 12345-90 mapping for this character in ku/ten form

=item GB3

The GB 7589-87 mapping for this character in ku/ten form

=item GB5

The GB 7590-87 mapping for this character in ku/ten form

=item GB7

The "General Use Characters for Modern Chinese" mapping for this
character

=item GB8

The GB 8565-89 mapping for this character in ku/ten form

=item GradeLevel*

The grade in the Hong Kong school system by which a student is
expected to know the character.

=item HanYu

The position of this character in the Hanyu Da Zidian (HDZ) Chinese
character dictionary (bibliographic information below).

The character references are given in the form "ABCDE.XYZ", in which:
"A" is the volume number [1..8]; "BCDE" is the zero-padded page number
[0001..4809]; "XY" is the zero-padded number of the character on the
page [01..32]; "Z" is "0" for a character actually in the dictionary,
and greater than 0 for a character assigned a "virtual" position in
the dictionary. For example, 53044.060 indicates an actual HDZ
character, the 6th character on Page 3,044 of Volume 5
(i.e. [U+269a4]). Note that the Volume 8 "BCDE" references are in the
range [0008..0044] inclusive, referring to the pagination of the
"Appendix of Addendum" at the end of that volume (beginning after
p. 5746).

Release information:

This data set contains a total of 56097 records, 54728 of which 
are actual HDZ character references (positions are given for all
HDZ head entries, including source-internal unifications), and 
1369 of which are virtual character positions (see note below). 
All HDZ references in this data set are unique. Because of IRG 
source-internal unifications, a given UCS-4 Scalar Value (USV) 
may have more than one HDZ reference. Source-internal 
unifications are of two types: (1) unifications of graphical 
variants; (2) unifications of duplicate head entries.

The proofing of all references was done primarily on the basis 
of cross-checks of three versions of the reference data: (1) the
original print source; (2) the "kIRGHanyuDaZidian" field of 
Unihan.txt (release 3.1.1d1); (3) "HDZ.txt", originally produced
and proofed for Academia Sinica's Institute of Information 
Technology (Document Processing Laboratory). In addition, the 
data was checked against the "kHanYu" and "kAlternateHanYu" 
fields of Unihan.txt (release 3.1.1d1), which the present data 
set supersedes.

String value, string length, compound key, field count, and page
total validations were all performed. Altogether, 578 omissions/
errors in source (2) were identified/corrected. Any remaining 
errors will likely relate to virtual positions, or to the 
ordering of actual characters within a given page. It is 
unlikely that errors across page breaks remain. Possible future 
deunifications of source-internal unifications will necessitate 
update of USV for some references. Under no circumstances should
the source-internal unification (duplicate USV) mappings be 
removed from this data set.

Note: Source (3) contributed only actual HDZ character 
references to the proofing process, while source (2) contributed
all virtual positions. It seems that the compilers of source (2) 
usually assigned virtual positions based on stroke count, though
occasionally the virtual position brings the virtual character 
together with the actual HDZ character of which it is a variant,
without regard to actual stroke count.

Bibliographic information for the print source:
		
<<Hanyu Da Zidian>> ['Great Chinese Character Dictionary' (in 8 
Volumes)]. XU Zhongshu (Editor in Chief). Wuhan, Hubei Province 
(PRC): Hubei and Sichuan Dictionary Publishing Collectives, 1986
-1990. ISBN: 7-5403-0030-2/H.16.
\x{300a}\x{6f22}\x{8a9e}\x{5927}\x{5b57}\x{5178}\x{300b}\x{3002}
\x{8a31}\x{529b}\x{4ee5}\x{4e3b}\x{4efb}\x{ff0c}\x{5f90}\x{4e2d}
\x{8212}\x{4e3b}\x{7de8}\x{ff0c}
\x{ff08}\x{6f22}\x{8a9e}\x{5927}\x{5b57}\x{5178}\x{5de5}\x{4f5c}
\x{59d4}\x{54e1}\x{6703}\x{ff09}\x{3002}\x{6b66}\x{6f22}\x{ff1a}
\x{56db}\x{5ddd}\x{8fad}\x{66f8}
\x{51fa}\x{7248}\x{793e}\x{ff0c}\x{6e56}\x{5317}\x{8fad}\x{66f8}
\x{51fa}\x{7248}\x{793e},1986-1990. ISBN: 7-5403-0030 2/H.16.

=item HKGlyph*

The index of the character in 
\x{5e38}\x{7528}\x{5b57}\x{5b57}\x{5f62}\x{8868} 
(\x{4e8c}\x{96f6}\x{96f6}\x{96f6}\x{5e74}\x{4fee}\x{8a02}\x{672c}), 
\x{9999}\x{6e2f}: \x{9999}\x{6e2f}\x{6559}\x{80b2}\x{5b78}\x{9662}, 
2000, ISBN 962-949-040-4.

This publication gives the "proper" shapes for characters as used in
the Hong Kong school system.

=item HKSCS

Mappings to the Big Five extended code points used for the Hong Kong
Supplementary Character Set

=item IBMJapan

The IBM Japanese mapping for this character in hex

=item IRG_GSource

The IRG "G" source mapping for this character in hex. The IRG "G"
source consists of data from the following national standards,
publications, and lists from the People's Republic of China and
Singapore. The versions of the standards used are those provided by
the PRC to the IRG and may not always reflect published versions of
the standards generally available.

  4K	Siku Quanshu
  BK	Chinese Encyclopedia
  CH	The Ci Hai (PRC edition)
  CY	The Ci Yuan
  FZ and FZ_BK	Founder Press System
  G0	GB2312-80
  G1	GB12345-90 with 58 Hong Kong and 92 Korean "Idu" characters
  G3	GB7589-87 unsimplified forms
  G5	GB7590-87 unsimplified forms
  G7	General Purpose Hanzi List for Modern Chinese Language, and
	General List of Simplified Hanzi
  GS	Singapore characters
  G8	GB8685-88
  GE	GB16500-95
  HC	The Hanyu Da Cidian
  HZ	The Hanyu Da Zidian
  KX	The KangXi dictionary

=item IRG_HSource

The IRG "H" source mapping for this character in hex. The IRG "H"
source consists of data from the Hong Kong Supplementary Characer Set.

=item IRG_JSource

The IRG "J" source mapping for this character in hex. The IRG "J"
source consists of data from the following national standards and
lists from Japan.

  J0	JIS X 0208-1990
  J1	JIS X 0212-1990
  J3	JIS X 0213-2000
  J4	JIS X 0213-2000
  JA	Unified Japanese IT Vendors Contemporary Ideographs, 1993

=item IRG_KSource

The IRG "K" source mapping for this character in hex. The IRG "K"
source consists of data from the following national standards and
lists from the Republic of Korea (South Korea).

  K0	KS C 5601-1987
  K1	KS C 5657-1991
  K2	PKS C 5700-1 1994
  K3	PKS C 5700-2 1994
  K4	PKS 5700-3:1998

=item IRG_KPSource

The IRG "KP" source mapping for this character in hex. The IRG "KP"
source consists of data from the following national standards and
lists from the Democratic People's Republic of Korea (North Korea).

  KP0	KPS 9566-97
  KP1	KPS 10721-2000

=item IRG_TSource

The IRG "T" source mapping for this character in hex. The IRG "T"
source consists of data from the following national standards and
lists from the Republic of China (Taiwan).

  T1	CNS 11643-1992, plane 1
  T2	CNS 11643-1992, plane 2
  T3	CNS 11643-1992, plane 3 (with some additional characters)
  T4	CNS 11643-1992, plane 4
  T5	CNS 11643-1992, plane 5
  T6	CNS 11643-1992, plane 6
  T7	CNS 11643-1992, plane 7
  TF	CNS 11643-1992, plane 15

=item IRG_VSource

The IRG "V" source mapping for this character in hex. The IRG "V"
source consists of data from the following national standards and
lists from Vietnam.

  V0	TCVN 5773:1993
  V1	VHN 01:1998
  V2	VHN 02:1998
  V3	TCVN 6056:1995

=item IRGDaeJaweon

The position of this character in the Dae Jaweon (Korean) dictionary
used in the four-dictionary sorting algorithm. The position is in the
form "page.position" with the final digit in the position being "0"
for characters actually in the dictionary and "1" for characters not
found in the dictionary and assigned a "virtual" position in the
dictionary.

Thus, "1187.060" indicates the sixth character on page 1187. A
character not in this dictionary but assigned a position between the
6th and 7th characters on page 1187 for sorting purposes would have
the code "1187.061"

This field represents the official position of the character within
the Dae Jaweon dictionary as used by the IRG in the four-dictionary
sorting algorithm.

The edition used is the first edition, published in Seoul by Samseong
Publishing Co., Ltd., 1988.

=item IRGDaiKanwaZiten

The index of this character in the Dae Kanwa Ziten, aka Morohashi
dictionary (Japanese) used in the four-dictionary sorting algorithm.

This field represents the official position of the character within
the DaiKanwa dictionary as used by the IRG in the four-dictionary
sorting algorithm.

The edition used is the revised edition, published in Tokyo by
Taishuukan Shoten, 1986.

=item IRGHanyuDaZidian

The position of this character in the Hanyu Da Zidian (PRC) dictionary
used in the four-dictionary sorting algorithm. The position is in the
form "volume page.position" with the final digit in the position being
"0" for characters actually in the dictionary and "1" for characters
not found in the dictionary and assigned a "virtual" position in the
dictionary.

Thus, "32264.080" indicates the eighth character on page 2264 in
volume 3.  A character not in this dictionary but assigned a position
between the 8th and 9th characters on this page for sorting purposes
would have the code "32264.081"

This field represents the official position of the character within
the Hanyu Da Zidian dictionary as used by the IRG in the
four-dictionary sorting algorithm.

The edition of the Hanyu Da Zidian used is the first edition,
published in Chengdu by Sichuan Cishu Publishing, 1986.

=item IRGKangXi

The position of this character in the KangXi dictionary used in the
four-dictionary sorting algorithm. The position is in the form
"page.position" with the final digit in the position being "0" for
characters actually in the dictionary and "1" for characters not found
in the dictionary and assigned a "virtual" position in the dictionary.

Thus, "1187.060" indicates the sixth character on page 1187. A
character not in this dictionary but assigned a position between the
6th and 7th characters on page 1187 for sorting purposes would have
the code "1187.061"

This field represents the official position of the character within
the KangXi dictionary as used by the IRG in the four-dictionary
sorting algorithm.

The edition of the KangXi dictionary used is the 7th edition published
by Zhonghua Bookstore in Beijing, 1989.

=item JapaneseKun

The Japanese pronunciation(s) of this character

=item JapaneseOn

The Sino-Japanese pronunciation(s) of this character

=item JIS0213

The JIS X 0213-2000 mapping for this character in min,ku,ten form

=item Jis0

The JIS X 0208-1990 mapping for this character in ku/ten form

=item Jis1

The JIS X 0212-1990 mapping for this character in ku/ten form

=item KPS0

The KP 9566-97 mapping for this character in hexadecimal form.

=item KPS1

The KPS 10721-2000 mapping for this character in hexadecimal form.

=item KSC0

The KS X 1001:1992 (KS C 5601-1989) mapping for this character in
ku/ten form

=item KSC1

The KS X 1002:1991 (KS C 5657-1991) mapping for this character in
ku/ten form

=item KangXi

The position of this character in the KangXi dictionary used in the
four-dictionary sorting algorithm. The position is in the form
"page.position" with the final digit in the position being "0" for
characters actually in the dictionary and "1" for characters not found
in the dictionary and assigned a "virtual" position in the dictionary.

Thus, "1187.060" indicates the sixth character on page 1187. A
character not in this dictionary but assigned a position between the
6th and 7th characters on page 1187 for sorting purposes would have
the code "1187.061"

The edition of the KangXi dictionary used is the 7th edition published
by Zhonghua Bookstore in Beijing, 1989.

=item Karlgren*

The index of this character in _Analytic Dictionary of Chinese and
Sino-Japanese_ by Bernhard Karlgren, New York: Dover Publications,
Inc., 1974.

If the index is followed by an asterisk (*), then the index is an
interpolated one, indicating where the character would be found if it
were to have been included in the dictionary.

=item Korean

The Korean pronunciation(s) of this character

=item Lau*

The index of this character in _A Practical Cantonese-English
Dictionary_ by Sidney Lau, Hong Kong: The Government Printer, 1977.

=item MainlandTelegraph

The PRC telegraph code for this character, derived from "Kanzi denpou
koudo henkan-hyou" ("Chinese character telegraph code conversion
table"), Lin Jinyi, KDD Engineering and Consulting, Tokyo, 1984

=item Mandarin

The Mandarin pronunciation(s) for this character in pinyin; Mandarin
pronunciations are sorted alphabetically, not in order of frequency

=item Matthews

The index of this character in _Mathews' Chinese-English Dictionary_
by Robert H. Mathews, Cambrige: Harvard University Press, 1975. Note
that the field name is kMatthews instead of kMathews to maintain
compatibility with earlier versions of this file, where it was
inadvertently misspelled.

=item MeyerWempe*

The index of this character in the Student's Cantonese-English
Dictionary by Bernard F. Meyer and Theodore F. Wempe (3rd edition,
1947)

=item Morohashi

The index of this character in the Dae Kanwa Ziten, aka Morohashi
dictionary (Japanese) used in the four-dictionary sorting algorithm.

The edition used is the revised edition, published in Tokyo by
Taishuukan Shoten, 1986.

=item Nelson

The index of this character in _The Modern Reader's Japanese-English
Character Dictionary_ by Andrew Nathaniel Nelson, Rutland, Vermont:
Charles E. Tuttle Company, 1974.

=item OtherNumeric

The numeric value for the character in certain unusual, specialized
contexts.

=item Phonetic*

The phonetic index for the character from _Ten Thousand Characters: An
Analytic Dictionary_ by G. Hugh Casey, S.J. Hong Kong: Kelley and
Walsh, 1980.

=item PrimaryNumeric

The value of the character when used in the writing of numbers in the
standard fashion.

=item PseudoGB1

A "GB 12345-90" code point assigned this character for the purposes of
including it within Unihan. Pseudo-GB1 codes were used to provide
official code points for characters not already in national standards,
such as characters used to write Cantonese, and so on.

=item RSJapanese

A Japanese radical/stroke count for this character in the form
"radical.additional strokes". A ' after the radical indicates the
simplified version of the given radical

=item RSKanWa

A Morohashi radical/stroke count for this character in the form
"radical.additional strokes". A ' after the radical indicates the
simplified version of the given radical

=item RSKangXi

A KangXi radical/stroke count for this character in the form
"radical.additional strokes". A ' after the radical indicates the
simplified version of the given radical

=item RSKorean

A Korean radical/stroke count for this character in the form
"radical.additional strokes". A ' after the radical indicates the
simplified version of the given radical

=item RSUnicode

A standard radical/stroke count for this character in the form
"radical.additional strokes". A ' after the radical indicates the
simplified version of the given radical

=item SemanticVariant

The Unicode value for a semantic variant for this character. A
semantic variant is an x- or y-variant with similar or identical
meaning which can generally be used in place of the indicated
character.

=item SBGY

The position of this character in the Song Ben Guang Yun (SBGY)
Medieval Chinese character dictionary (bibliographic and general
information below).

The 25330 character references are given in the form "ABC.XY", in
which: "ABC" is the zero-padded page number [004..546]; "XY" is the
zero-padded number of the character on the page [01..73]. For example,
364.38 indicates the 38th character on Page 364 (i.e. \x{6f8d}). Where
a given Unicode Scalar Value (USV) has more than one reference, these
are space-delimited.

Release information (20020310):

This data set contains a total of 25330 references, for 19511
different hanzi. The original data was input under the direction of
Prof. LUO Fengzhu at Taiwan Taoyuanxian Yuan Zhi University (see
below) using an early version of the Big5-based CDP encoding scheme
developed at Academia Sinica. During 2000-2002 this raw data was
processed and revised by Richard Cook as follows: the data was
converted to Unicode encoding using his revised kHanYu mapping tables
(first provided to the Unicode Consortium for the Unihan.txt release
3.1.1d1) and also using several other mapping tables developed
specifically for this project; the kSBGY indices were generated based
on hand-counts of all page totals; numerous indexing errors were
corrected; and the data underwent final proofing.

About the print sources: The SBGY text, which dates to the beginning
of the Song Dynasty (c. 1008, edited by \x{9673}\x{5f6d}\x{5e74} CHEN
Pengnian et al.) is an enlargement of an earlier text known as Qie Yun
(dated to c. 601, edited by \x{9678}\x{6cd5}\x{8a00} LU Fayan). With
25,330 head entries, this large early lexicon is important in part for
the information which it provides for historical Chinese
phonology. The GY dictionary employs a Chinese transcription method
(known as \x{53cd}\x{5207}) to give pronunciations for each of its
head entries. In addition, each syllable is also given a brief gloss.
It must be emphasized that the mapping of a particular SBGY glyph to a
single USV may in some cases be merely an approximation or may have
required the choice of a "best possible glyph" (out of those available
in the Unicode repertoire). This indexing data in conjunction with the
print sources will be useful for evaluating the degree of distinctive
variation in the character forms appearing in this text, and future
proofing of this data may reveal additional Chinese glyphs for IRG
encoding.

Bibliographic information on the print sources:
\x{300a}\x{5b8b}\x{672c}\x{5ee3}\x{97fb}\x{300b} <<Song Ben Guang
Yun>> ['Song Dynasty edition of the Guang Yun Rhyming Dictionary'],
edited by \x{9673}\x{5f6d}\x{5e74} CHEN Pengnian et al. (c. 1008).

Two modern editions of this work were consulted in building the kSBGY
indices:

\x{300a}\x{65b0}\x{6821}\x{6b63}\x{5207}\x{5b8b}\x{672c}\x{5ee3}
\x{97fb}\x{300b}\x{3002}\x{53f0}\x{7063}\x{9ece}\x{660e}\x{6587}
\x{5316}\x{4e8b}\x{696d}\x{516c}\x{53f8}\x{51fa}\x{7248}\x{ff0c}
\x{6797}\x{5c39}\x{6821}\x{8a02}1976

\x{5e74}\x{51fa}\x{7248}\x{3002}[This was the edition used in by
Prof. LUO
\x{53f0}\x{7063}\x{6843}\x{5712}\x{7e23}\x{5143}\x{667a}\x{5927}
\x{5b78}\x{4e2d}\x{8a9e}\x{7cfb}\x{7f85}\x{9cf3}\x{73e0},
and in the subsequent revision, conversion, indexing and proofing.]

\x{300a}\x{65b0}\x{6821}\x{4e92}\x{8a3b}\x{2027}\x{5b8b}\x{672c}
\x{5ee3}\x{97fb}\x{300b}\x{3002}\x{9999}\x{6e2f}\x{4e2d}\x{6587}
\x{5927}\x{5b78},\x{4f59}\x{8ffa}\x{6c38}1993,2000\x{5e74}\x{51fa}
\x{7248}\x{3002}
ISBN: 962-201-413-5; 7-5326-0685-6. [Textual problems were resolved 
on the basis of this extensively annotated modern edition of the text.]

Further Information: For further information on this index data and
the databases from which it is excerpted, or to report errata, please
contact Richard S. Cook <rscook@socrates.berkeley.edu>.

=item SimplifiedVariant

The Unicode value for the simplified Chinese variant for this
character (if any).

Note that a character can be *both* a traditional Chinese character in
its own right *and* the simplified variant for other characters (e.g.,
U+53F0).

In such case, the character is listed as its own simplified variant
and one of its own traditional variants.  This distinguishes this from
the case where the character is not the simplified form for any
character (e.g., U+4E95).

Much of the of the data on simplified and traditional variants was
supplied by Wenlin <http://www.wenlin.com>

=item SpecializedSemanticVariant

The Unicode value for a specialized semantic variant for this
character.

A specialized semantic variant is an x- or y-variant with similar or
identical meaning only in certain contexts (such as accountants'
numerals).

=item TaiwanTelegraph

The Taiwanese telegraph code for this character, derived from "Kanzi
denpou koudo henkan-hyou" ("Chinese character telegraph code
conversion table"), Lin Jinyi, KDD Engineering and Consulting, Tokyo,
1984

=item Tang*

The Tang dynasty pronunciation(s) of this character, derived from
_T'ang Poetic Vocabulary_ by Hugh M. Stimson, Far Eastern
Publications, Yale Univ. 1976.  Stimson's romanization has been
modified as follows:

The tones are indicated using numerals 1 through 4.  Stimson leaves
the level (tone 1) and entering (tone 4) tones unmarked (the latter
being found in syllables ending in a stop, -p, -t, or -k), uses a
hacek accent for the rising tone (tone 2), and a grave accent the
departing tone (tone 3)

Stimson's script a (\x{0251}, U+0251) is replaced with a-umlaut
(\x{00e4}, U+00E4)

Stimson's open e (\x{025b}, U+025B) is replaced with e-umlaut
(\x{00eb}, U+00EB)

Stimson's schwa (\x{0259}, U+0259) is replaced with e-circumflex
(\x{00ea}, U+00EA)

=item TotalStrokes

The total number of strokes in the character (including the radical)

=item TraditionalVariant

The Unicode value(s) for the traditional Chinese variant(s) for this
character.

Note that a character can be *both* a traditional Chinese character in
its own right *and* the simplified variant for other characters (e.g.,
U+53F0).

In such case, the character is listed as its own simplified variant
and one of its own traditional variants.  This distinguishes this from
the case where the character is not the simplified form for any
character (e.g., U+4E95).

Much of the of the data on simplified and traditional variants was
supplied by Wenlin Institute, Inc. <http://www.wenlin.com>

=item Vietnamese

The character's pronunciation(s) in Qu\x{1ed1}c ng\x{1eef}

=item Xerox

The Xerox code for this character

=item ZVariant

The Unicode value(s) for known z-variants of this character

=back

=head2 ACCURACY OF THE DATA:

Not all of these fields have been checked and proofed as carefully as
some others have been. Please report errata, corrections, and
additions at <http://www.unicode.org/unicode/reporting.html>.

The following fields may be taken as completely accurate and their
values are *normative* parts of Unicode and ISO/IEC 10646-1 and -2:

kIRG_GSource, kIRG_TSource, kIRG_JSource, kIRG_KSource, kIRG_KPSource,
kIRG_VSource

The IRG dictionary fields have also been extensively proofed by IRG
experts and may be taken as accurate.

The following fields have been extensively proofed by experts
world-wide and may be taken as accurate:

kBigFive, kCNS1986, kGB0, kGB1, kGB3, kGB5, kGB7, kGB8, kJis0, kJis1,
kJIS0213, kKSC0, kKSC1, kPseudoGB1, kCCCII, kCNS1992, kDaeJaweon,
kHanYu, kIBMJapan, kKangXi, kMatthews, kMorohashi, kNelson, kXerox

The remaining fields have not been as extensively proofed and their
values should be taken as provisional.  Some of these fields are still
in the process of being populated; more data will be available in
future releases of this file.  Such fields are marked in this header
with an asterisk (*).

=head2 KNOWN ERRORS:

U+6B06 should map to the kIRG_KSource 2-3D7B, not 7-3D7B.  This error
is in a normative part of the standard; the relevant standards bodies
are aware of it, but we cannot fix it in this file until the fix is
officially adopted

U+2F958 should map to the kIRG_TSource 6-4267, not 6-4627.  This error
is in a normative part of the standard; the relevant standards bodies
are aware of it, but we cannot fix it in this file until the fix is
officially adopted

The Japanese and Korean readings need to be normalized.  The Mandarin
vowel \x{00dc} is not consistently represented as pinyin requires

=cut

