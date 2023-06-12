<?php
include "db.php";
error_reporting(0);
//include "secured.php";
//include "getAPI.php";

    $deviceid = trim($_REQUEST['deviceid']);
    $image = $_REQUEST['image'];
    $name  = trim($_REQUEST['name']);
 
    $realImage = base64_decode($image);

$saveImage = base64_encode($realImage);
$showImage = '<img src = "data:image/png;base64,' . base64_encode($realImage) . '" width = "50px" height = "50px"/>';
       
file_put_contents("imgori/$name", $realImage);
 
$errmsg = 'Data failed input'; 

if ($deviceid != "") {
   $sql1 = "SELECT * FROM auths WHERE (uuid='$deviceid') ";
   $res1 = mysqli_query($conn, $sql1); 
   $row1 = mysqli_fetch_array($res1);
   $uid  = trim($row1['id']) + 0;
   $photo= trim($row1['avatar']) ; $newphoto = $photo;
   if ($uid > 0) {
      $newphoto = "https://dogemazon.net/ocai/imgori/$name";
      $sql2 = "UPDATE auths SET avatar='$newphoto', img='$saveImage' WHERE (uuid = '$deviceid') ";
      $res2 = mysqli_query($conn, $sql2); 
      $errmsg = 'Data input successfully';
   } 
}

$hasil = array(
	'avatar'  => $newphoto,
 	'message' => $errmsg
   );

$encoded = $hasil;
$myJSON = json_encode($encoded);
header('Content-type: application/json; charset=utf-8');
exit($myJSON);
?>