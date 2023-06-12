<?php 
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";
include "openai.php";      //get your own openai.com API

if (trim($deviceid) == "") exit('not available!');

$IP   = $_SERVER['REMOTE_ADDR'];
$now  = date("Y-m-d H:i:s");
$data = base64_decode(trim($_REQUEST['data']));
$uuid = explode(":", $data);

//$f = fopen('log.txt', 'w+');
//fputs($f, $uuid);
//fclose($f);

$uidx = $uuid[0];
$fidx = $uuid[1];

$gpt  = $targetid ;
if ((mopenai($gpt) == 4) || ($gpt == "")) $gpt = "Highest Ethical Nobleman should does and meditate on";
$sql  = "UPDATE auths set gpt='$gpt' WHERE (uuid LIKE '$uidx') ";
$res  = mysqli_query($conn, $sql);

$sql  = "SELECT * FROM auths WHERE (uuid LIKE '$uidx') ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$uid  = trim($row['id']) + 0;
$avatar = $row['avatar'];

$sql  = "SELECT * FROM auths WHERE (uuid LIKE '$fidx') ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$fid  = trim($row['id']) + 0;

$sql  = "SELECT COUNT(*) as tot FROM story WHERE (uid=$uid) ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$posting = trim($row['tot']) + 0;

$sql  = "SELECT COUNT(*) as tot FROM follow WHERE (fid=$uid) ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$follower = trim($row['tot']) + 0;

$sql  = "SELECT fid FROM follow WHERE (uid=$uid) ORDER BY id ASC ";
$res  = mysqli_query($conn, $sql);
$foll = 0; $following = 0;
while($row  = mysqli_fetch_array($res)) {
   $ffid = trim($row['fid']) + 0;
   if ($ffid == $fid) {
      $foll = 1;
   }
   $following++;
}
if ($foll > 0) {
   $msg    = "[OK] followed already";
} else {
   $sql1   = "INSERT INTO follow (dt,uid,fid,data,stat) VALUES ('$now', '$uid', '$fid', '$data', 0) ";
   if (($uid > 0) && ($fid > 0)) {
      $res1   = mysqli_query($conn, $sql1);
      $msg    = "[OK] just following";
      $following++;
   }
}

if ($uid > 0) {
$fuuid  = $uidx;
//---- pt.pgjbatam ------
   $key = base64_encode($release);
   $msg = "[OK] password matched";
} else {
   $key = base64_encode($develop);
   $msg = "[FAIL] password not matched";
}
   $hasil = array(
	'uuid'    => $fuuid,
	'avatar'  => $avatar,
 	'gpt'     => $gpt,
 	'ip'      => $IP,
 	'dt'      => $now,
	'api'	  => $key,
	'results' => $msg,
	'follower'  => $follower,
	'following' => $following,
	'posting'   => $posting,
   );

$encoded = $hasil;
$myJSON = json_encode($encoded);
header('Content-type: application/json; charset=utf-8');
exit($myJSON);
?>