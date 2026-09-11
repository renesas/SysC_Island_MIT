#!/usr/bin/env perl

use File::Slurp qw(read_file write_file);
use List::MoreUtils qw(uniq);
use File::Copy;
use Cwd qw(cwd);


( -e "$ARGV[0]/README-local.md" ) or die "$ARGV[0]/README-local.md not found";

$mark = qr/^\[\/\/\]: # /ms;
$tags = qr/^\((SECTION)? *([0-9]+)? *(AUTOADDED)?\)\s*$/ms;
$processedby = qr/^\[\/\/\]: # \(PROCESSED BY doc_merge.pl\)$/ms;

sub splitfile($$$) {
    my $sections=$_[0];
    my $text=$_[1];
    my $minsection=$_[2];
    my $section=0;
    $text=~s/$processedby\s*//;
    foreach (split /$mark/, $text) {
        /$tags/ and $section=int($2);
        (!$section || $section < $minsection) and $section=$minsection;
        if (!$3) {
            s/$tags\s*//;
            chomp();chomp();chomp();chomp();
            if ($_ ne "") {
                push @{ $sections->{$section} }, $_;
            }
        }
    }
}

$processed{$ARGV[0]}=1;
print ("Reading README-local.md from $ARGV[0]\n");
%base_sections=();
splitfile(\%base_sections, read_file("$ARGV[0]/README-local.md"),0);

open(CMAKECACHE, "CMakeCache.txt") or die("Could not open CMakeCache.txt file.");
%added_sections=();
foreach (<CMAKECACHE>) {
    chomp();
    ($name,$dir)=split("=");
    undef $project;
    $name =~ /([a-z_-]+)_SOURCE_DIR/ and $project=$1;
    if ($project && $dir && -e $dir) {
        if (!$processed{$dir}) {
            $text=read_file("$dir/README.md");
            if ($text =~ /$processedby/) {
                print ("Reading additional README.md from $dir\n");
                splitfile(\%added_sections, $text, 1);
            }
            if (-e "$dir/docs/${project}_README.md" &&  -e "$dir/docs/${project}.pdf") {                
                copy ("$dir/docs/${project}_README.md","$ARGV[0]/docs/${project}_README.md") or die "Copy failed: $!";
                copy ("$dir/docs/${project}.pdf","$ARGV[0]/docs/${project}.pdf") or die "Copy failed: $!";        
                print "API Docs from $dir/docs/${project} copied to $ARGV[0]/docs/${project}\n";
            }
            $processed{$dir}=1;
        }
    }
}

@out=();
push @out,  "\n\n[//]: # DONT EDIT THIS FILE\n";
foreach $section (uniq(sort { $a <=> $b } keys %base_sections , keys %added_sections)) {
    push @out,  "\n\n[//]: # (SECTION $section)\n";
    foreach $i ( 0 .. $#{ $base_sections{$section} } ) {
        push @out, $base_sections{$section}[$i];
    }
    if ($section < 100) {
        push @out,  "\n\n[//]: # (SECTION $section AUTOADDED)\n";
        foreach $i ( 0 .. $#{ $added_sections{$section} } ) {
            push @out, "\n".$added_sections{$section}[$i];
        }
    }
}
push @out, "\n\n[//]: # (PROCESSED BY doc_merge.pl)\n";

my $pwd=cwd;
copy ("$ARGV[0]/README.md","$pwd/README.md.bak") or die "Copy failed: $!";
write_file("$ARGV[0]/README.md" , @out);
#print join ("\n",@out);
print "README.md written to $ARGV[0] (backup in $pwd/README.md.bak)\n";
