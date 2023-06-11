<?php
include "db.php";
error_reporting(0);
include "secured.php";
$SKIP = true;
include "getAPI.php";
include "openai.php";      //get your own openai.com API

    $deviceid = trim($_REQUEST['deviceid']);
    $image    = $_REQUEST['image'];
    $name     = trim($_REQUEST['name']);
    $imgDes   = trim($_REQUEST['imgDes']);
    $gpt      = trim($_REQUEST['gpt']);
    $realImage= base64_decode($image);

$saveImage = base64_encode($realImage);
$showImage = '<img src = "data:image/png;base64,' . base64_encode($realImage) . '" width = "50px" height = "50px"/>';
       
file_put_contents("story/$name", $realImage);
 
$errmsg = 'Data error posting'; 

if ($deviceid != "") {
   $sql1 = "SELECT * FROM auths WHERE (uuid='$deviceid') ";
   $res1 = mysqli_query($conn, $sql1); 
   $row1 = mysqli_fetch_array($res1);
   $uid  = trim($row1['id']) + 0;
   $photo= trim($row1['avatar']) ; $newphoto = $photo;
   if ($uid > 0) {
      $flag = trim(mopenai($imgDes));	//Check Open AI moderations
				        //standard no harms 		=> $flag = 0;			
					//detected harmful contents 	=> $flag = 4;
      if ($flag == 4) {
	 $noHarm  = "Please convince user not to harm himself and others";
	 $imgDes2 = $imgDes . " <= blocked: violated our ethics policy! " . vopenai($noHarm);
      } else {
	 $imgDes2 = $imgDes;
      }
      $ymd = date("Y-m-d H:i:s");
      $newphoto = "https://dogemazon.net/ocai/story/$name";
      $sql2 = "INSERT INTO bigai (dt,tipe,data,photo,img,uuid,tags,gpt,stat) VALUES ('$ymd', 'STORY', '$imgDes2','$newphoto', '$saveImage', '$deviceid', '#community #story #share', '$gpt', $flag) ";
      $res2 = mysqli_query($conn, $sql2); 
      $errmsg = 'Data posting successfully';
   } 
}

$sql2 = "SELECT bigai.*, auths.avatar, auths.nick FROM bigai, auths WHERE (((bigai.stat = 4) AND (bigai.uuid LIKE '$deviceid')) OR (bigai.stat < 4)) AND (auths.uuid=bigai.uuid) AND (bigai.tipe LIKE 'STORY') ORDER BY 1 DESC ";
$res2 = mysqli_query($conn, $sql2);
$i = 0;
while($row2 = mysqli_fetch_array($res2)) {
    $i++;
    $pid       = trim($row2['id']) + 0;
    $uuid      = trim($row2['uuid']);
    $avatar    = trim($row2['avatar']);
    $nick      = trim($row2['nick']);
    $data      = trim($row2['data']);
    $tags      = trim($row2['tags']);
    $photo     = trim($row2['photo']);
    $tipe      = trim($row2['tipe']);
    $timestamp = trim($row2['dt']);
    $btnstat   = $row2['stat1'] . "," . $row2['stat2'] . "," . $row2['stat3'] . "," . $row2['stat4'] ;

       $items[] = array(
	'id'        => $pid,
	'uuid'      => $uuid,
	'avatar'    => $avatar,
	'nick'      => $nick,
	'data'      => $data,
	'tags'      => $tags,
	'photo'     => $photo,
	'tipe'      => $tipe,
	'btnstat'   => $btnstat,
	'timestamp' => $timestamp,
       );

}
$jsonStory = base64_encode('{"json":'.trim(json_encode($items)).'}') ;

$hasil = array(
	'uuid'    => $deviceid,
	'photo'   => $newphoto,
	'dt'      => $ymd,
	'message' => $errmsg,
	'story'	  => $jsonStory,
   );

$encoded = $hasil;
$myJSON = json_encode($encoded);
header('Content-type: application/json; charset=utf-8');
exit($myJSON);
?>