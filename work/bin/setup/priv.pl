#
# written by Ray 2001/3/31 06:41¤U¤È
#
my $user = Win32::LoginName();
my %hash=();
use Win32API::Net qw(UserGetInfo);
UserGetInfo("",$user,1,\%hash);
print $hash{"priv"};