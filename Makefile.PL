#/usr/local/bin/perl
use ExtUtils::MakeMaker;
use strict;

#Makefile.PL for Net::Hesiod Module

#Some platform specific variables

#Root of where hesiod stuff is kept. HESIOD_ROOT_DIR is just a convenience.
#HESIOD_LIBDIR should be where libhesiod.a is located
#HESIOD_INCDIR should be where hesiod.h is located
#-----------CHANGE THIS TO REFLECT YOUR SYSTEM CONFIG
my $HESIOD_ROOT_DIR="/usr/local/athena";
my $HESIOD_LIBDIR="$HESIOD_ROOT_DIR/lib";
my $HESIOD_INCDIR="$HESIOD_ROOT_DIR/include";

#MISC_LIBS list any other libraries that may be needed.
#Some systems (e.g. alpha-dec-osf ) require libresolv.a to be linked in,
#others lack libresolv.a (whatever needed included in libc.a)
#We will automatically add libresolv.a to list if find it, you can override
#if needed
my $MISC_LIBS="";

if ( -f '/lib/libresolv.a' || -f '/usr/lib/libresolv.a'
	|| -f '/usr/lib/libresolv.so' || -f '/usr/lib/libresolv.so' )
{	$MISC_LIBS.= " -lresolv";
}

#Hacks
my $HACKS;
#HESIOD_PORT_ENDIAN_HACK
#Current versions of libhesiod.a (3.0.2 and probably below) seem to have
#a problem in hesiod_getservbyname C function.
#After getting the text response from the DNS server, they do a 
#htons(atoi(port)) where port is the textual port number.  This causes
#returned port number to be in wrong byte order as far as local system is
#concerned if host byte order != network byte order.
#If this affects you, include -DHESIOD_PORT_ENDIAN_HACK in $HACKS below
#Affects alpha and ix86 systems
#Does not affect Sun systems
#
#DONT_HAVE_PW_QUOTA
#DONT_HAVE_PW_COMMENT
#Indicate the OS lacks a pw_quota or pw_comment filed in their passwd struct
#Solaris lacks pw_quota, Linux lacks both, Digital/Tru64 Unix has both
#If missing, include -DDONT_HAVE_PW_QUOTA and or -DDONT_HAVE_PW_COMMENT
#in $HACKS and quota field will always return undef. 
#The following code will set variable $PW_QUOTA_HACK and/or $PW_COMMENT_HACK
#correctly in many cases
my $PW_QUOTA_HACK='';
my $PW_COMMENT_HACK='';
if ( -f "/usr/include/pwd.h" )
{	open(TEMP,"</usr/include/pwd.h") 
		or warn "Cant open /usr/include/pwd.h, assuming PW_QUOTA_HACK";
	#Slurp the file in
	my @junk = <TEMP>;
	#See if pw_quota exists
	if ( ! grep /pw_quota/, @junk) 
	{ 	$PW_QUOTA_HACK="-DDONT_HAVE_PW_QUOTA";
	}
	if ( ! grep /pw_comment/, @junk) 
	{ 	$PW_COMMENT_HACK="-DDONT_HAVE_PW_COMMENT";
	}
}
#Uncomment this and set correctly if above fails
#$PW_QUOTA_HACK='';
#$PW_QUOTA_HACK='-DDONT_HAVE_PW_QUOTA -DDONT_HAVE_PW_COMMENT';
	
$HACKS="$PW_QUOTA_HACK $PW_COMMENT_HACK";

#The following should not need manual changes
my $LIBS="-L$HESIOD_LIBDIR -lhesiod $MISC_LIBS";
my $INCS="-I$HESIOD_INCDIR";
my $DEFS="$HACKS";

print "Making Makefile with :\n";
print "LIBS=$LIBS\n";
print "INCS=$INCS\n";
print "DEFS=$DEFS\n";

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::Hesiod',
    'VERSION_FROM'	=> 'Hesiod.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    'LIBS'		=> ["$LIBS"], # e.g., '-lm'
    'DEFINE'		=> "$DEFS", # e.g., '-DHAVE_SOMETHING'
    'INC'		=> "$INCS", # e.g., '-I/usr/include/other'
);

require 't/make_testdata.pl';
