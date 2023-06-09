<?php 
include "db.php";

$IP   = $_SERVER['REMOTE_ADDR'];
$now  = date("Y-m-d H:i:s");
$data = base64_decode(trim($_REQUEST['data']));
$uuid = explode(":", $data);

//$f = fopen('log.txt', 'w+');
//fputs($f, $uuid);
//fclose($f);

$uidx = $uuid[0];
$fidx = $uuid[1];

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
   $key = base64_encode("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");
   $msg = "[OK] password matched";
} else {
   $key = base64_encode("");
   $msg = "[FAIL] password not matched";
}
   $hasil = array(
	'uuid'    => $fuuid,
	'avatar'  => $avatar,
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