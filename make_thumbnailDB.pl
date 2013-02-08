#!/opt/bin/perl
use Image::ExifTool;
use DBI;
use File::Basename;
use File::Spec;
use Digest::MD5;
use utf8;

my $user = "root";
my $pass = "admin";
my $thumbdir = "/share/Web/picsearch/thumb";
my @tags = ("ImageWidth","ImageHeight","Make","Model","Orientation"
              ,"ShutterSpeed","FNumber","Flash","ExposureProgram","ISO","CreateDate"
              ,"ExposureCompensation","FocalLength","AFAreas","PictureMode"
              ,"ArtFilter","DriveMode","FaceDetect","FocusDistance","WhiteBalance"
              ,"LensModel","LightValue");

my $dbh = DBI->connect('DBI:mysql:test',$user,$pass)
or die "cannot connect to MySQL: $DBI::errstr";
$dbh->do("SET NAMES utf8");

my $regex_suffix = qw/\.[^\.]+$/;

while(@ARGV){
  my($file) = shift @ARGV;
  open(FH,"<$file");
  $md5 = Digest::MD5->new();
  $md5->addfile(FH);
  $md5str = $md5->hexdigest;
  my ($name, $path, $suffix) = fileparse($file,$regex_suffix);
  $path = File::Spec->rel2abs($file);
  my($exifTool) = new Image::ExifTool;
  my($exifInfo) = $exifTool->ImageInfo($file);
  #my @tags = $exifTool->GetTagList($exifInfo, 'Group0'); #ƒ^ƒOî•ñ
  my $thumb = $exifInfo->{ThumbnailImage};
  my $rotation = $exifInfo->{Orientation};

  my $thumbname = $thumbdir."/".$name."_".$md5str.".jpg";

  #$path = $dbh->quote($path);
  #print $name,$path,$rotation;
  my $sth = $dbh->prepare("insert into file (filename,filepath,md5) values (?,?,?);");
  $sth->execute($name,$path,$md5str);

my($key); 
foreach $key (@tags){ 
  my $sth = $dbh->prepare("insert into exif (filename,filepath,exiflabel,exifvalue,exifnum) values (?,?,?,?,?);");
  #print "insert into exif (filename,filepath,exiflabel,exifvalue) values ('$name','$path','$key','$exifInfo->{$key}');\n";

  if($key =~ /Image|FNumber|ExposureCompensation|ISO|FocalLength|FocusDistance/){
    $exifnum = $exifInfo->{$key};
  }elsif($key =~ /ShutterSpeed/){
    $exifnum = eval($exifInfo->{$key});
  }else{
    $exifnum = "";
  }

  $sth->execute($name,$path,$key,$exifInfo->{$key},$exifnum);
}

  open(THUMB,">$thumbname");
  print THUMB $$thumb;

}
#my $sth = $dbh->prepare("select filename,image from image where filename = 'P8100029'");
#$sth->execute();
#while(@rec = $sth->fetchrow_array){
#  $fname = $rec[0];
#  $image = $rec[1];
#}
#$fname = "s_".$fname.".jpg";
#print $fname;
#  open(THUMB,">$fname");
#binmode THUMB;
#  print THUMB $image;

