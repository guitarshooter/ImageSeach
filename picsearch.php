<html>
<head>
<script type="text/javascript" src="/js/jquery-1.7.2.min.js"></script> 
<script type="text/javascript" src="/js/jquery.lazyload.min.js"></script>
<script>
$(function(){
$('.lazy').lazyload();
});
</script>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
</head>
<body>
<?php
$mysqli = new mysqli('localhost', 'root', 'admin', 'test');
if (mysqli_connect_error()) {
 die('接続失敗です。'.mysqli_connect_error());
}
// 文字化け防止
$mysqli ->set_charset("utf8");

?>

<form method="get" action="<?php echo $_SERVER["PHP_SELF"];?>">
<div id="search">
<select name="k">
<?php
$query = "select exiflabel,displabel,num_flg from displabel where displabel <> ''";
$stmt = $mysqli->prepare($query);
  $stmt->execute();
  $stmt->bind_result($labelvalue,$displabel,$num_flg);
  while ($stmt->fetch()){
    echo "<option value='$labelvalue'>$displabel</option>";
  }

?>
</select>
<input type="text" name="v">
<select name="s">
<option value="=">と等しい</option>
<option value=">">より大きい</option>
<option value="<">より小さい</option>
</select>
<input type="submit">
</div>
</form>

<div id="gallery">
<?php
$thumbpath = "thumb";


if($_REQUEST['k']){
  $exiflabel = $_REQUEST['k'];
  $op = $_REQUEST['s'];
  $exifvalue = $_REQUEST['v'];

  if(preg_match("/Image|FNumber|ExposureCompensation|ISO|FocalLength|FocusDistance|ShutterSpeed/",$exiflabel)){
    $where = "B.exifnum $op $exifvalue";
  }else{
    $where = "B.exifvalue $op '$exifvalue'";
  }


  $query = "SELECT A.filename, A.filepath, A.md5,B.exiflabel,B.exifvalue
    FROM file A, exif B
    WHERE A.filepath = B.filepath
    AND A.filename = B.filename
    AND B.exiflabel = '$exiflabel'
    AND $where";
}else{
  $query = "select filename,filepath,md5,'','' from file order by filepath";
}
  $stmt = $mysqli->prepare($query);
  $stmt->execute();
  $stmt->bind_result($filename,$filepath,$md5,$label,$value);
  while ($stmt->fetch()){
    $fileinfo = pathinfo($filename);
    $imgfile = $thumbpath."/".$fileinfo['filename']."_".$md5.".jpg";
    if($label){
      $title = $label."=".$value;
    }else{
      $title = $filename;
    }
?>
  <span>
  <img class="lazy" src="thumb/grey.gif" data-original="<?php echo $imgfile;?>" title="<?php echo $title;?>"/>
<?php //echo $file;?>
  </span>
<?php
}

?>
</div>
</body>
</html>
