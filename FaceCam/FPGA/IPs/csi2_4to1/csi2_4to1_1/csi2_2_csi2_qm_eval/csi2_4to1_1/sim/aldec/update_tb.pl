use Aldec::ActiveHDL;

print $ARGV[0];

open(FILE, "<csi2_2_csi2_tb.v") || die "File not found";
my @lines = <FILE>;
close(FILE);

my @newlines;
foreach(@lines) {
   $_ =~ s/csi2_2_csi2_ip_wrapper/$ARGV[0]/g;
   push(@newlines,$_);
}

open(FILE, ">csi2_2_csi2_tb.v") || die "File not found";
print FILE @newlines;
close(FILE);
