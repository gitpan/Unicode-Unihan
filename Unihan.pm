package Unicode::Unihan;

use 5.008001;
use strict;
use warnings;

our $VERSION = do { my @r = (q$Revision: 0.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
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

=encoding utf8

=head1 NAME

Unicode::Unihan - The Unihan Data Base 5.0.0

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

=over 2

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

=over 2

=item of the Module

Dan Kogai E<lt>dankogai@dan.co.jpE<gt>

=item of the Source Data

Unicode, Inc.

=back

=head1 COPYRIGHT AND LICENSE

=over 2

=item of the Module

Copyright 2002-2007 by Dan Kogai, All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=item of the Source Data

Copyright (c) 1996-2006 Unicode, Inc. All Rights reserved.

       Name: Unihan database
       Unicode version: 5.0.0
       Table version: 1.1
       Date: 7 July 2006

=back

=head1 NOTES

The followning is POD-ized notes from the Unihan database.

 Name: Unihan database
 Unicode version: 5.0.0
 Table version: 1.1
 Date: 7 July 2006

Copyright (c) 1996-2006 Unicode, Inc. All Rights reserved.

For terms of use, see L<http://www.unicode.org/terms_of_use.html>

=head2 Format information:

Each line of this file consists of three tab-separated fields.
The first is the Unicode scalar value as U+[x]xxxx (that is, there are
either four or five hex digits)
The second is a tag indicating the type of information in the third field
The third is the line's value (in UTF-8)

We give below a list of the tags in alphabetical order.  For each tag,
we give additional information, such as its formal status in the standard, 
a general category to which its data belongs, the separator (if any) 
between individual subvalues, a regular expression indicating the 
format of each subvalue, the version of Unicode in which the data were 
originally introduced, and a description of the data associated with the 
tag.

Regular expressions are based on standard Perl 5.8.6 syntax and may
require modification for use with other regular expression engines.  

Unless otherwise noted, the order of subvalues within a single
value field is not significant.

Note that only the description is present for every tag value.  

See also L<http://www.unicode.org/Public/UNIDATA/Unihan.html>

=over 2

=item AccountingNumeric

 Tag:	kAccountingNumeric
 Status:	Informative
 Category:	Numeric Values
 Separator:	space
 Syntax:	[0-9]+
 Introduced:	3.2

The value of the character when used in the writing of accounting 
numerals. 

Accounting numerals are used in East Asia to prevent fraud. Because 
a number like ten (十) is easily turned into one thousand (千) with 
a stroke of a brush, monetary documents will often use an 
accounting form of the numeral ten (such as 拾) in their place. 

The three numeric-value fields should have no overlap; that is, characters 
with a kAccountingNumeric value should not have a kPrimaryNumeric 
or kOtherNumeric value as well. 

=item BigFive

 Tag:	kBigFive
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}

The Big Five mapping for this character in hex; note that this does 
not cover any of the Big Five extensions in common use, including 
the ETEN extensions. 

=item CCCII

 Tag:	kCCCII
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{6}

The CCCII mapping for this character in hex. 

=item CNS1986

 Tag:	kCNS1986
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[12E]-[0-9A-F]{4}

The CNS 11643-1986 mapping for this character in hex. 

=item CNS1992

 Tag:	kCNS1992
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[123]-[0-9A-F]{4}

The CNS 11643-1992 mapping for this character in hex. 

=item Cangjie

 Tag:	kCangjie
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[A-Z]+
 Introduced:	3.1.1

The cangjie input code for the character. This incorporates 
data from the file cangjie-table.b5 by Christian Wittern. 

=item Cantonese

 Tag:	kCantonese
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[a-z]+[1-6]

The Cantonese pronunciation(s) for this character using the 
jyutping romanization. 

A full description of jyutping can be found at L<http://cpct92.cityu.edu.hk/lshk/Jyutping/Jyutping.htm>. 
The main differences between jyutping and the Yale romanization 
previously used are: 

1) Jyutping always uses tone numbers and does not distinguish 
the high falling and high level tones. 

2) Jyutping always writes a long a as "aa". 

3) Jyutping uses "oe" and "eo" for the Yale "eu" vowel. 

4) Jyutping uses "c" instead of "ch", "z" instead of "j", 
and "j" instead of "y" as initials. 

5) A non-null initial is always explicitly written (thus 
"jyut" in jyutping instead of Yale's "yut"). 

Cantonese pronunciations are sorted alphabetically, not in 
order of frequency. 

N.B., the Hong Kong dialect of Cantonese is in the process of dropping 
initial NG- before non-null finals. Any word with an initial NG- 
may actually be pronounced without it, depending on the speaker and 
circumstances. Many words with a null initial may similarly be pronounced 
with an initial NG-. Similarly, many speakers use an initial 
L- for words previously pronounced with an initial N-. 

Cantonese data are derived from the following sources: 

Casey, G. Hugh, S.J. Ten Thousand Characters: An Analytic 
Dictionary. Hong Kong: Kelley and Walsh,1980 (kPhonetic). 

Cheung Kwan-hin and Robert S. Bauer, The Representation of Cantonese 
with Chinese Characters, Journal of Chinese Linguistics Monograph 
Series Number 18, 2002. 

Roy T. Cowles, A Pocket Dictionary of Cantonese, Hong Kong: 
University Press, 1999 (kCowles). 

Sidney Lau, A Practical Cantonese-English Dictionary, Hong 
Kong: Government Printer, 1977 (kLau). 

Bernard F. Meyer and Theodore F. Wempe, Student's Cantonese-English 
Dictionary, Maryknoll, New York: Catholic Foreign Mission 
Society of America, 1947 (kMeyerWempe). 

饒秉才, ed. 廣州音字典, Hong Kong: Joint Publishing (H.K.) Co., Ltd., 
1989. 

中華新字典, Hong Kong:中華書局, 1987. 

黃港生, ed. 商務新詞典, Hong Kong: The Commercial Press, 1991. 

朗文初級中文詞典, Hong Kong: Longman, 2001. 

The jyutping phrase box from the Linguistic Society of Hong Kong, 
L<http://cpct92.cityu.edu.hk/lshk/Jyutping/>. The copyright of the 
Jyutping phrase box belongs to the Linguistic Society of Hong Kong.  
We would like to thank the Jyutping Group of the Linguistic Society 
of Hong Kong for permission to use the electronic file in our research 
and/or product development. Note that the inclusion of the phrase 
box in the Unihan database requires that any products developed 
using the kCantonese field needs to include this acknowledgment. 

=item CheungBauer

 Tag:	kCheungBauer
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	NA
 Introduced:	5.0

Data regarding the character in Cheung Kwan-hin and Robert S. Bauer, 
_The Representation of Cantonese with Chinese Characters_, Journal 
of Chinese Linguistics, Monograph Series Number 18, 2002. The data 
consist of three pieces, separated by semicolons: (1) the character's 
radical-stroke index as a three-digit radical, slash, two-digit stroke 
count; (2) the character's cangjie input code (if any); and (3) a 
comma-separated list of Cantonese readings using the jyutping 
romanization in alphabetical order. 

=item CheungBauerIndex

 Tag:	kCheungBauerIndex
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{3}\.[0-9][0-9]{2}
 Introduced:	5.0

The position of the character in Cheung Kwan-hin and Robert S. Bauer, 
_The Representation of Cantonese with Chinese Characters_, Journal 
of Chinese Linguistics, Monograph Series Number 18, 2002. The format 
is a three-digit page number followed by a two-digit position 
number, separated by a period. 

=item CihaiT

 Tag:	kCihaiT
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[1-9][0-9]{0,3}\.[0-9]{3}
 Introduced:	3.2

The position of this character in the Cihai (辭海) dictionary, single 
volume edition, published in Hong Kong by the Zhonghua Bookstore, 
1983 (reprint of the 1947 edition), ISBN 962-231-005-2. 

The position is indicated by a decimal number. The digits to the 
left of the decimal are the page number. The first digit after the 
decimal is the row on the page, and the remaining two digits 
after the decimal are the position on the row. 

=item CompatibilityVariant

 Tag:	kCompatibilityVariant
 Status:	Normative
 Category:	Variants
 Separator:	space
 Syntax:	U\+2?[0-9A-F]{4}
 Introduced:	3.2

The compatibility decomposition for this ideograph, derived 
from the UnicodeData.txt file. 

=item Cowles

 Tag:	kCowles
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{1,4}(\.[0-9]{1,2})?
 Introduced:	3.1.1

The index or indices of this character in Roy T. Cowles, 
A Pocket Dictionary of Cantonese, Hong Kong: University Press, 
1999. 

The Cowles indices are numerical, usually integers but occasionally 
fractional where a character was added after the original indices 
were determined. Cowles is missing indices 1222 and 4949, and four 
characters in Cowles are part of Unicode's "Hangzhou" numeral 
set: 2964 (U+3025), 3197 (U+3028), 3574 (U+3023), and 4720 
(U+3027). 

Approximately 100 characters from Cowles which are not currently 
encoded are being submitted to the IRG by Unicode for inclusion 
in future versions of the standard. 

=item DaeJaweon

 Tag:	kDaeJaweon
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{4}\.[0-9]{2}[0158]

The position of this character in the Dae Jaweon (Korean) dictionary 
used in the four-dictionary sorting algorithm. The position is in 
the form "page.position" with the final digit in the position being 
"0" for characters actually in the dictionary and "1" for characters 
not found in the dictionary and assigned a "virtual" position 
in the dictionary. 

Thus, "1187.060" indicates the sixth character on page 1187. A character 
not in this dictionary but assigned a position between the 
6th and 7th characters on page 1187 for sorting purposes 
would have the code "1187.061" 

The edition used is the first edition, published in Seoul 
by Samseong Publishing Co., Ltd., 1988. 

=item Definition

 Tag:	kDefinition
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	See Description

An English definition for this character. Definitions are for modern 
written Chinese and are usually (but not always) the same as the 
definition in other Chinese dialects or non-Chinese languages. In 
some cases, synonyms are indicated. Fuller variant information 
can be found using the various variant fields. 

Definitions specific to non-Chinese languages or Chinese 
dialects other than modern Mandarin are marked, e.g., (Cant.) 
or (J). 

Major definitions are separated by semicolons, and minor definitions 
by commas. Any valid Unicode character (except for tab, double-quote, 
and any line break character) may be used within the definition 
field. 

=item EACC

 Tag:	kEACC
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{6}

The EACC mapping for this character in hex. 

=item Fenn

 Tag:	kFenn
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[0-9]+a?[A-KP*]
 Introduced:	3.1.1

Data on the character from The Five Thousand Dictionary (aka Fenn's 
Chinese-English Pocket Dictionary) by Courtenay H. Fenn, 
Cambridge, Mass.: Harvard University Press, 1979. 

The data here consists of a decimal number followed by a letter A 
through K, the letter P, or an asterisk. The decimal number gives 
the Soothill number for the character's phonetic, and the letter 
is a rough frequency indication, with A indicating the 500 
most common ideographs, B the next five hundred, and so on. 

P is used by Fenn to indicate a rare character included in 
the dictionary only because it is the phonetic element in 
other characters. 

An asterisk is used instead of a letter in the final position to 
indicate a character which belongs to one of Soothill's phonetic 
groups but is not found in Fenn's dictionary. 

Characters which have a frequency letter but no Soothill 
phonetic group are assigned group 0. 

=item kFennIndex

 Tag:	kFennIndex
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[1-9]{3}\.[01][0-9]

The position of this character in _Fenn's Chinese-English Pocket 
Dictionary_ by Courtenay H. Fenn, Cambridge, Mass.: Harvard University 
Press, 1942. The position is indicated by a three-digit page 
number followed by a period and a two-digit position on the 
page. 

=item FourCornerCode

 Tag:	kFourCornerCode
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[0-9]{4}(\.[0-9])?
 Introduced:	5.0

The four-corner code(s) for the character. This data is derived from 
data provided in the public domain by Hartmut Bohn, Urs App, 
and Christian Wittern. 

The four-corner system assigns each character a four-digit code from 
0 through 9. The digit is derived from the "shape" of the four corners 
of the character (upper-left, upper-right, lower-left, lower-right). 
An optional fifth digit can be used to further distinguish characters; 
the fifth digit is derived from the shape in the character's 
center or region immediately to the left of the fourth corner. 

The four-corner system is now used only rarely. Full descriptions 
are available online, e.g., at L<http://en.wikipedia.org/wiki/Four_corner_input>. 

Values in this field consist of four decimal digits, optionally 
followed by a period and fifth digit for a five-digit form. 

=item Frequency

 Tag:	kFrequency
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[1-5]
 Introduced:	3.2

A rough frequency measurement for the character based on analysis 
of traditional Chinese USENET postings; characters with a kFrequency 
of 1 are the most common, those with a kFrequency of 2 are 
less common, and so on, through a kFrequency of 5. 

=item GB0

 Tag:	kGB0
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}

The GB 2312-80 mapping for this character in ku/ten form. 

=item GB1

 Tag:	kGB1
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}

The GB 12345-90 mapping for this character in ku/ten form. 

=item GB3

 Tag:	kGB3
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}

The GB 7589-87 mapping for this character in ku/ten form. 

=item GB5

 Tag:	kGB5
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}

The GB 7590-87 mapping for this character in ku/ten form. 

=item GB7

 Tag:	kGB7
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}

The GB 8565-89 mapping for this character in ku/ten form. 

=item GB8

 Tag:	kGB8
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The GB 8565-89 mapping for this character in ku/ten form 

=item G5R

 Tag:	kGSR
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{4}[a-vx-z]\'*
 Introduced:	4.0.1

The position of this character in Bernhard Karlgren's Grammata 
Serica Recensa (1957). 

This dataset contains a total of 7,403 records. References are given 
in the form DDDDa('), where "DDDD" is a set number in the range [0001..1260] 
zero-padded to 4-digits, "a" is a letter in the range [a..z] (excluding 
"w"), optionally followed by (') apostrophe. The data from which 
this mapping table is extracted contains a total of 10,023 
references. References to inscriptional forms have been omitted. 

Release notes 

22-Dec-2003: Initial release. The following 32 references are to 
unencoded forms: 0059k, 0069y, 0079d, 0275b, 0286a, 0289a, 0289f, 
0293a, 0325a, 0389o, 0391h, 0392s, 0468h, 0480a, 0516a, 0526o, 0566g', 
0642y, 0661a, 0739i,0775b, 0837h, 0893r, 0969a, 0969e, 1019e, 1062b, 
1112d, 1124l, 1129c', 1144a, 1144b. In some cases a variant mapping 
has been substituted in the mapping table, in other cases 
the reference is omitted. 

Bibliographic information 

Karlgren, Klas Bernhard Johannes 高本漢 (1889–1978): 2000. Grammata 
Serica Recensa Electronica. Electronic version of GSR, including 
indices, syllable canon, & images of the original Karlgren (1957) 
text. Prepared for the STEDT Project by Richard Cook; based in part 
on work by Tor Ulving & Ferenc Tafferner (see below), used 
by permission. Berkeley: University of California., L<http://stedt.berkeley.edu/> 

Karlgren 1957. Grammata Serica Recensa. First published in the Bulletin 
of the Museum of Far Eastern Antiquities (BMFEA) No. 29, Stockholm, 
Sweden. Reprinted by Elanders Boktrycker Aktiebolag, Kungsbacka, 
[1972]. Reprinted also by SMC Publishing Inc., Taipei, Taiwan, 
ROC, [1996]. ISBN: 957-638-269-6. 

Karlgren 1940. Grammata Serica: Script and Phonetics in Chinese and 
Sino-Japanese 《中日漢字形聲論》Zhong-Ri Hanzi Xingsheng Lun [A study of Sino-Japanese 
semantic-phonetic compound characters:] BMFEA No. 12. Reprinted, 
Taipei: Ch'eng-Wen Publishing Company, [1966]. 

Ulving, Tor: 1997. Dictionary of Old and Middle Chinese: Bernhard 
Karlgren's Grammata Serica Recensa Alphabetically Arranged. With 
Ferenc Tafferner. Göteborg, Sweden: Acta Universitatis Gothoburgensis. 
Orientalia Gothoburgensia, 11. ISBN: 91-7346-294-2. 

=item GradeLevel

 Tag:	kGradeLevel
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[1-6]
 Introduced:	3.2

The primary grade in the Hong Kong school system by which a student 
is expected to know the character; this data is derived from 
朗文初級中文詞典, Hong Kong: Longman, 2001. 

=item HDZRadBreak

 Tag:	kHDZRadBreak
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	NA
 Syntax:	[x{2F00}-x{2FD5}][U+2?[0-9A-F]{4}]:[1-8][0-9]{4}\.[0-9]{2}[012]
 Introduced:	4.1

Indicates that 《漢語大字典》 Hanyu Da Zidian has a radical break beginning 
at this character's position. The field consists of the radical (with 
its Unicode code point), a colon, and then the Hanyu Da Zidian 
position as in the kHanyu field. 

=item HKGlyph

 Tag:	kHKGlyph
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[0-9]{4}
 Introduced:	3.1.1

The index of the character in 常用字字形表 (二零零零年修訂本),香港: 香港教育學院, 2000, 
ISBN 962-949-040-4. This publication gives the "proper" shapes for 
4759 characters as used in the Hong Kong school system. The 
index is an integer, zero-padded to four digits. 

=item HKSCS

 Tag:	kHKSCS
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}
 Introduced:	3.1.1

Mappings to the Big Five extended code points used for the 
Hong Kong Supplementary Character Set. 

=item HanYu

 Tag:	kHanYu
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[1-8][0-9]{4}\.[0-9]{2}[0-3]

The position of this character in the Hanyu Da Zidian (HDZ) 
Chinese character dictionary (bibliographic information below). 

The character references are given in the form "ABCDE.XYZ", in which: 
"A" is the volume number [1..8]; "BCDE" is the zero-padded page number 
[0001..4809]; "XY" is the zero-padded number of the character on 
the page [01..32]; "Z" is "0" for a character actually in the dictionary, 
and greater than 0 for a character assigned a "virtual" position 
in the dictionary. For example, 53024.060 indicates an actual HDZ 
character, the 6th character on Page 3,044 of Volume 5 (i.e. 籉). 
Note that the Volume 8 "BCDE" references are in the range [0008..0044] 
inclusive, referring to the pagination of the "Appendix of 
Addendum" at the end of that volume (beginning after p. 5746). 

The first character assigned a given virtual position has an index 
ending in 1; the second assigned the same virtual position 
has an index ending in 2; and so on. 

Release information 

This data set contains a total of 56097 records, 54728 of which are 
actual HDZ character references (positions are given for all HDZ 
head entries, including source-internal unifications), and 
1369 of which are virtual character positions (see note below). 

All 55817 HDZ references in this data set are unique. Because of 
IRG source-internal unifications, a given UCS-4 Scalar Value (USV) 
may have more than one HDZ reference. Source-internal unifications 
are of two types: (1) unifications of graphical variants; 
(2) unifications of duplicate head entries. 

The proofing of all references was done primarily on the basis of 
cross-checks of three versions of the reference data: (1) the original 
print source; (2) the "kIRGHanyuDaZidian" field of Unihan.txt (release 
3.1.1d1); (3) "HDZ.txt", originally produced and proofed for Academia 
Sinica's Institute of Information Technology (Document Processing 
Laboratory). In addition, the data was checked against the "kHanYu" 
and "kAlternateHanYu" fields of Unihan.txt (release 3.1.1d1), 
which the present data set supersedes. 

String value, string length, compound key, field count, and page 
total validations were all performed. Altogether, 578 omissions/ 
errors in source (2) were identified/corrected. Any remaining errors 
will likely relate to virtual positions, or to the ordering of actual 
characters within a given page. It is unlikely that errors across 
page breaks remain. Possible future deunifications of source-internal 
unifications will necessitate update of USV for some references. 
Under no circumstances should the source-internal unification 
(duplicate USV) mappings be removed from this data set. 

Note: Source (3) contributed only actual HDZ character references 
to the proofing process, while source (2) contributed all virtual 
positions. It seems that the compilers of source (2) usually assigned 
virtual positions based on stroke count, though occasionally the 
virtual position brings the virtual character together with the 
actual HDZ character of which it is a variant, without regard 
to actual stroke count. 

Bibliographic information for the print source: 

<Hanyu Da Zidian> ['Great Chinese Character Dictionary' (in 8 Volumes)]. 
XU Zhongshu (Editor in Chief). Wuhan, Hubei Province (PRC): Hubei 
and Sichuan Dictionary Publishing Collectives, 1986-1990. 
ISBN: 7-5403-0030-2/H.16. 

《漢語大字典》。許力以主任，徐中舒主編，（漢語大字典工作委員會）。武漢：四川辭書出版社，湖北辭書出版社,1986-1990. 
ISBN: 7-5403-0030-2/H.16. 

=item Hangul

 Tag:	kHangul
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Introduced:	5.0

The modern Korean pronunciation(s) for this character in 
Hangul. 

=item HanyuPinlu

 Tag:	kHanyuPinlu
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[a-zü]+[1-5]\([0-9]+\)
 Introduced:	4.0.1

The Pronunciations and Frequencies of this character, based in part 
on those appearing in 《現代漢語頻率詞典》 <Xiandai Hanyu Pinlu Cidian> (XDHYPLCD) 
[Modern Standard Beijing Chinese Frequency Dictionary] (complete 
bibliographic information below). 

Data Format 

This dataset contains a total of 3800 records. Each entry 
is comprised of two pieces of data. 

The Hanyu Pinyin (HYPY) pronunciation(s) of the character, with numeric 
tone marks (1-5, where 5 indicates the "neutral tone") immediately 
following each alphabetic string. 

Immediately following the numeric tone mark, a numeric string appears 
in parentheses: e.g. in "a1(392)" the numeric string "392" indicates 
the sum total of the frequencies of the pronunciations of 
the character as given in HYPLCD. 

Where more than one pronunciation exists, these are sorted 
by descending frequency, and the list elements are "comma 
+ space" delimited. 

Release Information 

The XDHYPLCD data here for Modern Standard Chinese (Putonghua) cuts 
across 4 genres ("News," "Scientific," "Colloquial," and "Literature"), 
and was derived from a 440799 character corpus. See that 
text for additional information. 

The 8548 entries (8586 with variant writings) from p. 491-656 of 
XDHYPLCD were input by hand and proof-read from 1994/08/04 
to 1995/03/22 by Richard Cook. 

Current Release Date above reflects date of last proofing. 

HYPY transcription for the data in this release was semiautomated 
and hand-corrected in 1995, based in part on data provided 
by Ross Paterson (Department of Computing, Imperial College, 
London). 

Tom Bishop <http://www.wenlin.com> is also due thanks for 
early assistance in proof-reading this data. 

The character set used for this digitization of HYPLCD (a 
"simplified" mainland PRC text) was (Mac OS 7-9) GB 2312-80 
(plus 嗐). 

These data were converted to Big5 (plus 腈), and both GB and Big5 
versions were separately converted to Unicode 4.0, and then merged, 
resulting in the 3800 records in the current release. Frequency data 
for simplified polysyllabic words has been employed to generate 
both simplified and traditional character frequencies. 

Bibliographic information for the primary print source 

《現代漢語頻率詞典》，北京語言學院語言教學研究所編著。 

<Xiandai Hanyu Pinlu Cidian> = XDHYPLCD First edition 1986/6, 
2nd printing 1990/4. ISBN 7-5619-0094-5/H.67. 

=item IBMJapan

 Tag:	kIBMJapan
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	F[ABC][0-9A-F]{2}

The IBM Japanese mapping for this character in hexadecimal. 

=item IICore

 Tag:	kIICore
 Status:	Normative
 Category:	IRG Sources
 Separator:	space
 Syntax:	[1-9]\.[1-9]
 Introduced:	4.1

Indicates that a character is in IICore, the IRG-produced 
minimal set of required ideographs for East Asian use. 

Each individual value in this field is either P (for preliminary, 
meaning it has been approved by the IRG but not by WG2), 
or the ISO/IEC 10646 subset identifier for the subset(s) 
containing this character. 

=item IRGDaeJaweon

 Tag:	kIRGDaeJaweon
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{4}\.[0-9]{2}[01]|0000\.555
 Introduced:	3

The position of this character in the Dae Jaweon (Korean) dictionary 
used in the four-dictionary sorting algorithm. The position is in 
the form "page.position" with the final digit in the position being 
"0" for characters actually in the dictionary and "1" for characters 
not found in the dictionary and assigned a "virtual" position 
in the dictionary. 

Thus, "1187.060" indicates the sixth character on page 1187. A character 
not in this dictionary but assigned a position between the 
6th and 7th characters on page 1187 for sorting purposes 
would have the code "1187.061" 

This field represents the official position of the character within 
the Dae Jaweon dictionary as used by the IRG in the four-dictionary 
sorting algorithm. 

The edition used is the first edition, published in Seoul 
by Samseong Publishing Co., Ltd., 1988. 

=item IRGDaiKanwaZiten

 Tag:	kIRGDaiKanwaZiten
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{5}\'?
 Introduced:	3

The index of this character in the Dai Kanwa Ziten, aka Morohashi 
dictionary (Japanese) used in the four-dictionary sorting 
algorithm. 

This field represents the official position of the character within 
the DaiKanwa dictionary as used by the IRG in the four-dictionary 
sorting algorithm. The edition used is the revised edition, 
published in Tokyo by Taishuukan Shoten, 1986. 

=item IRGHanyuDaZidian

 Tag:	kIRGHanyuDaZidian
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[1-8][0-9]{4}\.[0-3][0-9][01]
 Introduced:	3

The position of this character in the Hanyu Da Zidian (PRC) dictionary 
used in the four-dictionary sorting algorithm. The position is in 
the form "volume page.position" with the final digit in the position 
being "0" for characters actually in the dictionary and "1" for characters 
not found in the dictionary and assigned a "virtual" position 
in the dictionary. 

Thus, "32264.080" indicates the eighth character on page 2264 in 
volume 3. A character not in this dictionary but assigned a position 
between the 8th and 9th characters on this page for sorting 
purposes would have the code "32264.081" 

This field represents the official position of the character within 
the Hanyu Da Zidian dictionary as used by the IRG in the 
four-dictionary sorting algorithm. 

The edition of the Hanyu Da Zidian used is the first edition, 
published in Chengdu by Sichuan Cishu Publishing, 1986. 

=item IRGKangXi

 Tag:	kIRGKangXi
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[01][0-9]{3}\.[0-7][0-9][01]
 Introduced:	3

The position of this character in the KangXi dictionary used in the 
four-dictionary sorting algorithm. The position is in the form "page.position" 
with the final digit in the position being "0" for characters actually 
in the dictionary and "1" for characters not found in the 
dictionary and assigned a "virtual" position in the dictionary. 

Thus, "1187.060" indicates the sixth character on page 1187. A character 
not in this dictionary but assigned a position between the 
6th and 7th characters on page 1187 for sorting purposes 
would have the code "1187.061" 

This field represents the official position of the character within 
the KangXi dictionary as used by the IRG in the four-dictionary sorting 
algorithm. The edition of the KangXi dictionary used is the 
7th edition published by Zhonghua Bookstore in Beijing, 1989. 

=item IRG_GSource

 Tag:	kIRG_GSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	space
 Syntax:	(4K|BK|CH|CY|FZ(_BK)?|HC|HZ|KX|[0135789ES]-[0-9A-F]{4})
Introduced:	3

The IRG "G" source mapping for this character in hex. The IRG G source 
consists of data from the following national standards, publications, 
and lists from the People's Republic of China and Singapore. The 
versions of the standards used are those provided by the PRC to the 
IRG and may not always reflect published versions of the 
standards generally available. 

4K Siku Quanshu 

BK Chinese Encyclopedia 

CH The Ci Hai (PRC edition) 

CY The Ci Yuan 

FZ and FZ_BK Founder Press System 

G0 GB2312-80 

G1 GB12345-90 with 58 Hong Kong and 92 Korean "Idu" characters 

G3 GB7589-87 unsimplified forms 

G5 GB7590-87 unsimplified forms 

G7 General Purpose Hanzi List for Modern Chinese Language, 
and General List of Simplified Hanzi 

GS Singapore characters 

G8 GB8685-88 

GE GB16500-95 

HC The Hanyu Da Cidian 

HZ The Hanyu Da Zidian 

KX The KangXi dictionary 

=item IRG_HSource

 Tag:	kIRG_HSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	N/A
 Syntax:	[0-9A-F]{4}
 Introduced:	3.1

The IRG "H" source mapping for this character in hex. The 
IRG "H" source consists of data from the Hong Kong Supplementary 
Characer Set. 

=item IRG_JSource

 Tag:	kIRG_JSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	space
 Syntax:	([0134A]|3A)-[0-9A-F]{4}
 Introduced:	3

The IRG "J" source mapping for this character in hex. The IRG 
J source consists of data from the following national standards 
and lists from Japan. 

J0 JIS X 0208:1990 

J1 JIS X 0212:1990 

J3 JIS X 0213:2000 

J4 JIS X 0213:2000 

JA Unified Japanese IT Vendors Contemporary Ideographs, 1993 

J3A JIS X 0213:2004 level-3 

=item IRG_KPSource

 Tag:	kIRG_KPSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	N/A
 Syntax:	KP[01]-[0-9A-F]{4}
 Introduced:	3.1.1

The IRG "KP" source mapping for this character in hex. The IRG "KP" 
source consists of data from the following national standards 
and lists from the Democratic People's Republic of Korea 
(North Korea). 

KP0 KPS 9566-97 

KP1 KPS 10721-2000 

=item IRG_KSource

 Tag:	kIRG_KSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	N/A
 Syntax:	[01234]-[0-9A-F]{4}
 Introduced:	3

The IRG "K" source mapping for this character in hex. The IRG "K" 
source consists of data from the following national standards 
and lists from the Republic of Korea (South Korea). 

K0 KS C 5601-1987 

K1 KS C 5657-1991 

K2 PKS C 5700-1 1994 

K3 PKS C 5700-2 1994 

K4 PKS 5700-3:1998 

Note that the K4 source is expressed in hexadecimal, but 
unlike the other sources, it is not organized in row/column. 

=item IRG_TSource

 Tag:	kIRG_TSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	N/A
 Syntax:	[1-7F]-[0-9A-F]{4}
 Introduced:	3

The IRG "T" source mapping for this character in hex. The IRG "T" 
source consists of data from the following national standards 
and lists from the Republic of China (Taiwan). 

T1 CNS 11643-1992, plane 1 

T2 CNS 11643-1992, plane 2 

T3 CNS 11643-1992, plane 3 (with some additional characters) 

T4 CNS 11643-1992, plane 4 

T5 CNS 11643-1992, plane 5 

T6 CNS 11643-1992, plane 6 

T7 CNS 11643-1992, plane 7 

TF CNS 11643-1992, plane 15 

=item IRG_USource

 Tag:	kIRG_USource
 Status:	Normative
 Category:	IRG Sources
 Separator:	space
 Syntax:	U\+2?[0-9A-F]{4}
 Introduced:	4.0.1

The IRG "U" source mapping for this character. Currently, the IRG 
U source is limited to a small number of characters in the 
CJK Compatibility Ideographs block, where the value is the 
Unicode code point. 

=item IRG_VSource

 Tag:	kIRG_VSource
 Status:	Normative
 Category:	IRG Sources
 Separator:	space
 Syntax:	[0123]-[0-9A-F]{4}
 Introduced:	3

The IRG "V" source mapping for this character in hex. The IRG 
V source consists of data from the following national standards 
and lists from Vietnam. 

V0 TCVN 5773:1993 

V1 VHN 01:1998 

V2 VHN 02:1998 

V3 TCVN 6056:1995 

=item JIS0213

 Tag:	kJIS0213
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[12],[0-9]{2},[0-9]{1,2}
 Introduced:	3.1.1

The JIS X 0213-2000 mapping for this character in min,ku,ten 
form. 

=item JapaneseKun

 Tag:	kJapaneseKun
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[A-Z]+

The Japanese pronunciation(s) of this character. 

=item JapaneseOn

 Tag:	kJapaneseOn
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[A-Z]+

The Sino-Japanese pronunciation(s) of this character. 

=item Jis0

 Tag:	kJis0
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The JIS X 0208-1990 mapping for this character in ku/ten 
form. 

=item Jis1

 Tag:	kJis1
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The JIS X 0212-1990 mapping for this character in ku/ten 
form. 

=item KPS0

 Tag:	kKPS0
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}
 Introduced:	3.1.1

The KPS 9566-97 mapping for this character in hexadecimal 
form. 

=item KPS1

 Tag:	kKPS1
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9A-F]{4}
 Introduced:	3.1.1

The KPS 10721-2000 mapping for this character in hexadecimal 
form. 

=item KSC0

 Tag:	kKSC0
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The KS X 1001:1992 (KS C 5601-1989) mapping for this character 
in ku/ten form. 

=item KSC1

 Tag:	KSC1
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The KS X 1002:1991 (KS C 5657-1991) mapping for this character 
in ku/ten form. 

=item KangXi

 Tag:	kKangXi
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{4}\.[0-9]{2}[01]

The position of this character in the KangXi dictionary used in the 
four-dictionary sorting algorithm. The position is in the form "page.position" 
with the final digit in the position being "0" for characters actually 
in the dictionary and "1" for characters not found in the 
dictionary and assigned a "virtual" position in the dictionary. 

Thus, "1187.060" indicates the sixth character on page 1187. A character 
not in this dictionary but assigned a position between the 
6th and 7th characters on page 1187 for sorting purposes 
would have the code "1187.061" 

The edition of the KangXi dictionary used is the 7th edition 
published by Zhonghua Bookstore in Beijing, 1989. 

=item Karlgren

 Tag:	kKarlgren
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[1-9][0-9]{0,3}[A*]?
 Introduced:	3.1.1

The index of this character in _Analytic Dictionary of Chinese 
and Sino-Japanese_ by Bernhard Karlgren, New York: Dover 
Publications, Inc., 1974. 

If the index is followed by an asterisk (*), then the index is an 
interpolated one, indicating where the character would be found if 
it were to have been included in the dictionary. Note that while 
the index itself is usually an integer, there are some cases 
where it is an integer followed by an "A". 

=item Korean

 Tag:	kKorean
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[A-Z]+

The Korean pronunciation(s) of this character, using the Yale romanization 
system. (See <http://www.coffeesigns.com/Resources/romanization/korean.asp> 
for a comparison of the various Korean romanization systems.) 

=item Lau

 Tag:	kLau
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[1-9][0-9]{0,3}
 Introduced:	3.1.1

The index of this character in A Practical Cantonese-English 
Dictionary by Sidney Lau, Hong Kong: The Government Printer, 
1977. 

The index consists of an integer. Missing indices indicate unencoded 
characters which are being submitted to the IRG for inclusion 
in future versions of the standard. 

=item MainlandTelegraph

 Tag:	kMainlandTelegraph
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The PRC telegraph code for this character, derived from "Kanzi denpou 
koudo henkan-hyou" ("Chinese character telegraph code conversion 
table"), Lin Jinyi, KDD Engineering and Consulting, Tokyo, 
1984. 

=item Mandarin

 Tag:	kMandarin
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[A-ZÜ]+[1-5]

The Mandarin pronunciation(s) for this character in pinyin; 
Mandarin pronunciations are sorted in order of frequency, 
not alphabetically. 

=item Matthews

 Tag:	kMatthews
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{1,4}(a|\.5)?

The index of this character in Mathews' Chinese-English Dictionary 
by Robert H. Mathews, Cambrige: Harvard University Press, 
1975. 

Note that the field name is kMatthews instead of kMathews to maintain 
compatibility with earlier versions of this file, where it 
was inadvertently misspelled. 

=item MeyerWempe

 Tag:	kMeyerWempe
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[1-9][0-9]{0,3}[a-t*]?
 Introduced:	3.1

The index of this character in the Student's Cantonese-English Dictionary 
by Bernard F. Meyer and Theodore F. Wempe (3rd edition, 1947). The 
index is an integer, optionally followed by a lower-case Latin letter 
if the listing is in a subsidiary entry and not a main one. In some 
cases where the character is found in the radical-stroke index, but 
not in the main body of the dictionary, the integer is followed 
by an asterisk (e.g., U+50E5, which is listed as 736* as 
well as 1185a). 

=item Morohashi

 Tag:	kMorohashi
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{5}'?

The index of this character in the Dae Kanwa Ziten, aka Morohashi 
dictionary (Japanese) used in the four-dictionary sorting 
algorithm. 

The edition used is the revised edition, published in Tokyo 
by Taishuukan Shoten, 1986. 

=item Nelson

 Tag:	kNelson
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{4}

The index of this character in The Modern Reader's Japanese-English 
Character Dictionary by Andrew Nathaniel Nelson, Rutland, 
Vermont: Charles E. Tuttle Company, 1974. 

=item OtherNumeric

 Tag:	kOtherNumeric
 Status:	Informative
 Category:	Numeric Values
 Separator:	space
 Syntax:	[0-9]+
 Introduced:	3.2

The numeric value for the character in certain unusual, specialized 
contexts. 

The three numeric-value fields should have no overlap; that is, characters 
with a kOtherNumeric value should not have a kAccountingNumeric 
or kPrimaryNumeric value as well. 

=item Phonetic

 Tag:	kPhonetic
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[1-9][0-9]{0,3}[A-D]?*?
 Introduced:	3.1

The phonetic index for the character from Ten Thousand Characters: 
An Analytic Dictionary by G. Hugh Casey, S.J. Hong Kong: 
Kelley and Walsh,1980. 

=item PrimaryNumeric

 Tag:	kPrimaryNumeric
 Status:	Informative
 Category:	Numeric Values
 Separator:	space
 Syntax:	[0-9]+
 Introduced:	3.2

The value of the character when used in the writing of numbers 
in the standard fashion. 

The three numeric-value fields should have no overlap; that is, characters 
with a kPrimaryNumeric value should not have a kAccountingNumeric 
or kOtherNumeric value as well. 

=item PseudoGB1

 Tag:	kPseudoGB1
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

A "GB 12345-90" code point assigned this character for the purposes 
of including it within Unihan. Pseudo-GB1 codes were used to provide 
official code points for characters not already in national 
standards, such as characters used to write Cantonese, and 
so on. 

=item RSAdobe_Japan1_6

 Tag:	kRSAdobe_Japan1_6
 Status:	Provisional
 Category:	Radical-Stroke Counts
 Separator:	space
 Syntax:	[CV]\+[0-9]{1,5}\+[1-9][0-9]{0,2}\.[1-9][0-9]?\.[0-9]{1,2}
 Introduced:	4.1

Information on the glyphs in Adobe-Japan1-6 as contributed by Adobe. 
The value consists of a number of space-separated entries. 
Each entry consists of three pieces of information separated 
by a plus sign: 

1) C or V. "C" indicates that the Unicode code point maps directly 
to the Adobe-Japan1-6 CID that appears after it, and "V" 
indicates that it is considered a variant form, and thus 
not directly encoded. 

2) The Adobe-Japan1-6 CID. 

3) Radical-stroke data for the indicated Adobe-Japan1-6 CID. The 
radical-stroke data consists of three pieces separated by periods: 
the KangXi radical (1-214), the number of strokes in the form the 
radical takes in the glyph, and the number of strokes in the residue. 
The standard Unicode radical-stroke form can be obtained by omitting 
the second value, and the total strokes in the glyph from 
adding the second and third values. 

=item RSJapanese

 Tag:	kRSJapanese
 Status:	Provisional
 Category:	Radical-Stroke Counts
 Separator:	space
 Syntax:	[0-9]{1,3}\.[0-9]{1,2}

A Japanese radical/stroke count for this character in the form "radical.additional 
strokes". A ' after the radical indicates the simplified 
version of the given radical. 

=item RSKanWa

 Tag:	kRSKanWa
 Status:	Provisional
 Category:	Radical-Stroke Counts
 Separator:	space
 Syntax:	[0-9]{1,3}\.[0-9]{1,2}

A Morohashi radical/stroke count for this character in the form "radical.additional 
strokes". A ' after the radical indicates the simplified 
version of the given radical. 

=item RSKangXi

 Tag:	kRSKangXi
 Status:	Provisional
 Category:	Radical-Stroke Counts
 Separator:	space
 Syntax:	[0-9]{1,3}\.[0-9]{1,2}

The KangXi radical/stroke count for this character consistent with 
the value of the kKangXi field in the form "radical.additional 
strokes". A ' after the radical indicates the simplified 
version of the given radical. 

=item RSKorean

 Tag:	kRSKorean
 Status:	Provisional
 Category:	Radical-Stroke Counts
 Separator:	space
 Syntax:	[0-9]{1,3}\.[0-9]{1,2}

A Korean radical/stroke count for this character in the form "radical.additional 
strokes". A ' after the radical indicates the simplified 
version of the given radical 

=item RSUnicode

 Tag:	kRSUnicode
 Status:	Informative
 Category:	Radical-Stroke Counts
 Separator:	space
 Syntax:	[0-9]{1,3}\'?\.[0-9]{1,2}

A standard radical/stroke count for this character in the form "radical.additional 
strokes". A ' after the radical indicates the simplified 
version of the given radical 

This field is used for additional radical-stroke indices where either 
a character may be reasonably classified under more than 
one radical, or alternate stroke count algorithms may provide 
different stroke counts. 

The first value is intended to reflect the same radical as the kRSKangXi 
field and the stroke count of the glyph used to print the 
character within the Unicode Standard. 

=item SBGY

 Tag:	kSBGY
 Status:	Provisional
 Category:	Dictionary Indices
 Separator:	space
 Syntax:	[0-9]{3}\.[0-9]{2}
 Introduced:	3.2

The position of this character in the Song Ben Guang Yun (SBGY) 
Medieval Chinese character dictionary (bibliographic and 
general information below). 

The 25334 character references are given in the form "ABC.XY", in 
which: "ABC" is the zero-padded page number [004..546]; "XY" is the 
zero-padded number of the character on the page [01..73]. For example, 
364.38 indicates the 38th character on Page 364 (i.e. 澍). Where a 
given Unicode Scalar Value (USV) has more than one reference, 
these are space-delimited. 

- Release information (20031005): 

This release corrects several mappings. 

-- Release information (20020310) -- 

This data set contains a total of 25334 references, for 19572 
different hanzi (up from 25330 and 19511 in the previous 
release). 

This release of the kSBGY data fixes a number of mappings, based 
on extensive work done since the initial release (compare the initial 
release counts given below). See the end of this header for 
additional information. 

-- Initial release information (20020310) -- 

The original data was input under the direction of Prof. LUO Fengzhu 
at Taiwan Taoyuanxian Yuan Zhi University (see below) using an early 
version of the Big5- based CDP encoding scheme developed at Academia 
Sinica. During 2000-2002 this raw data was processed and revised 
by Richard Cook as follows: the data was converted to Unicode encoding 
using his revised kHanYu mapping tables (first provided to the Unicode 
Consortium for the Unihan.txt release 3.1.1d1) and also using several 
other mapping tables developed specifically for this project; the 
kSBGY indices were generated based on hand-counts of all page 
totals; numerous indexing errors were corrected; and the 
data underwent final proofing. 

-- About the print sources -- 

The SBGY text, which dates to the beginning of the Song Dynasty (c. 
1008, edited by 陳彭年 CHEN Pengnian et al.) is an enlargement of an 
earlier text known as 《切韻》 Qie Yun (dated to c. 601, edited by 陸法言 
LU Fayan). With 25,330 head entries, this large early lexicon is 
important in part for the information which it provides for historical 
Chinese phonology. The GY dictionary employs a Chinese transcription 
method (known as 反切) to give pronunciations for each of its 
head entries. In addition, each syllable is also given a 
brief gloss. 

It must be emphasized that the mapping of a particular SBGY glyph 
to a single USV may in some cases be merely an approximation or may 
have required the choice of a "best possible glyph" (out of those 
available in the Unicode repertoire). This indexing data in conjunction 
with the print sources will be useful for evaluating the degree of 
distinctive variation in the character forms appearing in this text, 
and future proofing of this data may reveal additional Chinese 
glyphs for IRG encoding. 

-- Bibliographic information on the print sources -- 

《宋本廣韻》 <<Song Ben Guang Yun>> ['Song Dynasty edition of the 
Guang Yun Rhyming Dictionary'], edited by 陳彭年 CHEN Pengnian 
et al. (c. 1008). 

Two modern editions of this work were consulted in building 
the kSBGY indices: 

《新校正切宋本廣韻》。台灣黎明文化事業公司 出版，林尹校訂1976 年出版。[This was the edition used 
by Prof. LUO (台灣桃園縣元智大學中語系羅鳳珠), and in the subsequent revision, 
conversion, indexing and proofing.] 

《新校互註‧宋本廣韻》。香港中文大學,余迺永 1993, 2000 年出版。ISBN: 962-201-413-5; 7-5326-0685-6. 
[Textual problems were resolved on the basis of this extensively 
annotated modern edition of the text.] 

-- Additional Information -- 

For further information on this index data and the databases 
from which it is excerpted, see: 

Cook, Richard S. 2003. 《說文解字‧電子版》 Shuo Wen Jie Zi - Dianzi Ban: Digital 
Recension of the Eastern Han Chinese Grammaticon. PhD Dissertation. 
Department of Linguistics. Berkeley: University of California. 

=item SemanticVariant

 Tag:	kSemanticVariant
 Status:	Provisional
 Category:	Variants
 Separator:	space
 Syntax:	U+2?[0-9A-F]{4}(<k[A-Za-z:]+(,k[A-Za-z]+)*)?

The Unicode value for a semantic variant for this character. A semantic 
variant is an x- or y-variant with similar or identical meaning 
which can generally be used in place of the indicated character. 

The basic syntax is a Unicode scalar value. It may optionally be 
followed by additional data. The additional data is separated from 
the Unicode scalar value by a less-than sign (<), and may be subdivided 
itself into substrings by commas, each of which may be divided into 
two pieces by a colon. The additional data consists of a series of 
field tags for another field in the Unihan database indicating the 
source of the information. If subdivided, the final piece is a string 
consisting of the letters T (for tòng, U+540C 同) B (for bù, 
U+4E0D 不), or Z (for zhèng, U+6B63 正). 

T is used if the indicated source explicitly indicates the 
two are the same (e.g., by saying that the one character 
is "the same as" the other). 

B is used if the source explicitly indicates that the two 
are used improperly one for the other. 

Z is used if the source explicitly indicates that the given character 
is the preferred form. Thus, the Hanyu Da Zidian indicates that 
U+5231 刱 and U+5275 創 are semantic variants and that U+5275 
創 is the preferred form. 

=item SimplifiedVariant

 Tag:	kSimplifiedVariant
 Status:	Provisional
 Category:	Variants
 Separator:	space
 Syntax:	U\+2?[0-9A-F]{4}

The Unicode value for the simplified Chinese variant for 
this character (if any). 

Note that a character can be *both* a traditional Chinese character 
in its own right *and* the simplified variant for other characters 
(e.g., U+53F0). 

In such case, the character is listed as its own simplified variant 
and one of its own traditional variants. This distinguishes this 
from the case where the character is not the simplified form 
for any character (e.g., U+4E95). 

Much of the of the data on simplified and traditional variants 
was supplied by Wenlin <http://www.wenlin.com> 

=item SpecializedSemanticVariant

 Tag:	kSpecializedSemanticVariant
 Status:	Provisional
 Category:	Variants
 Separator:	space
 Syntax:	U+2?[0-9A-F]{4}(<k[A-Za-z]+(,k[A-Za-z]+)*)?

The Unicode value for a specialized semantic variant for 
this character. The syntax is the same as for the kSemanticVariant 
field. 

A specialized semantic variant is an x- or y-variant with 
similar or identical meaning only in certain contexts (such 
as accountants' numerals). 

=item TaiwanTelegraph

 Tag:	kTaiwanTelegraph
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{4}

The Taiwanese telegraph code for this character, derived from "Kanzi 
denpou koudo henkan-hyou" ("Chinese character telegraph code 
conversion table"), Lin Jinyi, KDD Engineering and Consulting, 
Tokyo, 1984. 

=item Tang

 Tag:	kTang
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	*?[A-Za-z()x{E6}x{251}x{259}x{25B}x{300}x{30C}]+

The Tang dynasty pronunciation(s) of this character, derived from 
or consistent with _T'ang Poetic Vocabulary_ by Hugh M. Stimson, 
Far Eastern Publications, Yale Univ. 1976. 

=item TotalStrokes

 Tag:	kTotalStrokes
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[1-9][0-9]{0,2}
 Introduced:	3.1

The total number of strokes in the character (including the 
radical). This value is for the character as drawn in the 
Unicode charts. 

=item TraditionalVariant

 Tag:	kTraditionalVariant
 Status:	Provisional
 Category:	Variants
 Separator:	space
 Syntax:	U\+2?[0-9A-F]{4}

The Unicode value(s) for the traditional Chinese variant(s) 
for this character. 

Note that a character can be *both* a traditional Chinese character 
in its own right *and* the simplified variant for other characters 
(e.g., 台 U+53F0). 

In such case, the character is listed as its own simplified variant 
and one of its own traditional variants. This distinguishes this 
from the case where the character is not the simplified form 
for any character (e.g., 井 U+4E95). 

Much of the of the data on simplified and traditional variants 
was supplied by Wenlin Institute, Inc. <http://www.wenlin.com>. 

=item Vietnamese

 Tag:	kVietnamese
 Status:	Provisional
 Category:	Dictionary-like Data
 Separator:	space
 Syntax:	[A-Za-zx{E0}-x{1B0}x{1EA1}-x{1EF9}]+
 Introduced:	3.1.1

The character's pronunciation(s) in Quốc ngữ. 

=item Xerox

 Tag:	kXerox
 Status:	Provisional
 Category:	Other Mappings
 Separator:	space
 Syntax:	[0-9]{3}:[0-9]{3}

The Xerox code for this character. 

=item ZVariant

 Tag:	kZVariant
 Status:	Provisional
 Category:	Variants
 Separator:	space
 Syntax:	U+2?[0-9A-F]{4}(:k[A-Za-z]+)?

The Unicode value(s) for known z-variants of this character. 

=back

=head2 Valid UniHan Ranges

 U+3400..U+4DB5   : CJK Unified Ideographs Extension A
 U+4E00..U+9FA5   : CJK Unified Ideographs
 U+9FA6..U+9FBB   : CJK Unified Ideographs (4.1)
 U+F900..U+FA2D   : CJK Compatibility Ideographs (a)
 U+FA30..U+FA6A   : CJK Compatibility Ideographs (b)
 U+FA70..U+FAD9   : CJK Compatibility Ideographs (4.1)
 U+20000..U+2A6D6 : CJK Unified Ideographs Extension B
 U+2F800..U+2FA1D : CJK Compatibility Supplement

=head2 ACCURACY OF THE DATA:

Not all of these fields have been checked and proofed as carefully as some
others have been. Please report errata, corrections, and additions at 
L<http://www.unicode.org/unicode/reporting.html>.

The following fields may be taken as completely accurate and their values are
*normative* parts of Unicode and ISO/IEC 10646-1 and -2:

kIRG_GSource, kIRG_TSource, kIRG_JSource, kIRG_KSource, kIRG_KPSource, kIRG_VSource,
and kIICore

The IRG dictionary fields have also been extensively proofed by IRG experts and may
be taken as accurate.  

The following fields have been extensively proofed by experts world-wide and may be
taken as accurate:

kBigFive, kCNS1986, kGB0, kGB1, kGB3, kGB5, kGB7, kGB8, kJis0, kJis1, kJIS0213,
kKSC0, kKSC1, kPseudoGB1, kCCCII, kCNS1992, kDaeJaweon, kHanYu, kIBMJapan, 
kKangXi, kMatthews, kMorohashi, kNelson, kXerox

The remaining fields have not been as extensively proofed and their values should be
taken as provisional.    

=head2 RELEASE NOTES

5.0		The kCheungBauer, kCheungBauerIndex, kFourCornerCode, and kHangul fields were added.

4.1		The kPhonetic data was regenerated to include multiple entries for individual
characters.  Duplicate entries were removed from the kMandarin and kCantonese
fields.  All fields are now complete.  The kFenn field had substantial new 
data added.  The kFennIndex field was added. The latest data sets for kSBGY 
and kHanYu were included.  The kAlternateKangXi and kAlternateMorohashi 
fields were dropped.  The syntax of the kSemanticVariant and 
kSpecializedSemanticVariant fields was extended to include source information.
The data in these two fields were substantially extended. The Cantonese field
has been changed to use jyutping instead of Yale romanization.  Preliminary
data for new characters has been added.  The various kIRG* fields have
had their values resynchronized with data in ISO/IEC 10646.  Numerous other 
individual corrections and additions were made.  The header has been
restructured and expanded, in preparation for moving the field
descriptions into a separate document.  The kRSAdobe_Japan1_6 field was
added.  The Cantonese readings have been extended and corrected using
data from the Hong Kong Linguistic Society and Hong Kong Polytechnic
University.	The kIICore field was added.

4.0.1	In addition to numerous small changes and corrections, the kMandarin field
has been regenerated from earlier versions of the data with later corrections
re-inserted.  This was required because of a script error which incorrectly
assigned readings to various characters.  The order of the kMandarin field
has been restored to frequency order.  There have been substantial updates
and corrections to the kCantonese, kCihaiT, kCowles, kDefinition, kGradeLevel, 
kHKGlyph, kLau, kMeyerWempe, and kVietnamese fields.  (The kCihaiT, kCowles, 
kGradeLevel, and kLau fields are now complete.)  The kHanyuPinlu, kIRG_USource,
and kGSR fields have been added.  

=head2 KNOWN ERRORS

The Japanese and Korean readings need to be normalized.  The variant fields need
to be extended.
