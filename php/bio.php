<?php 
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";
include "openai.php";      //get your own openai.com API

if (trim($deviceid) == "") exit('not available!');

$IP   = $_SERVER['REMOTE_ADDR'];
$now  = date("Y-m-d H:i:s");

$promptid = base64_decode($targetid);
$net101 = kopenai($promptid);
$sql1   = "UPDATE auths set gpt='$promptid', netkey='$net101' WHERE (uuid LIKE '$deviceid') ";
$res1   = mysqli_query($conn, $sql1);

$f = fopen('sql.txt', 'w+');
fputs($f, $sql1);
fclose($f);

$res64 = base64_encode($net101);
$status = 1;
print $status . "|" . $res64;

?>