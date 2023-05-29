<?php
include "db.php";
error_reporting(0);
include "autoload.php";
include "secured.php";
include "getAPI.php";

$token = "";

if ($deviceid != "") {
   $token= $targetid;
   $sql1 = "SELECT * FROM auths WHERE (deviceid='$deviceid') ";
   $res1 = mysqli_query($conn, $sql1); 
   $row1 = mysqli_fetch_array($res1);
   $uid  = trim($row1['id']) + 0;
   if ($uid <= 0) {
	exit;
   }
}

$IP  = $_SERVER['REMOTE_ADDR'];
$sqlx = "INSERT INTO iplog (dt, ip, stat, uid) VALUES (NOW(), '$IP', 0, $UID_LOG) ";
$resx = mysqli_query($conn, $sqlx);

?>