<?php 
include "db.php";
error_reporting(0);
include "secured.php";
$SKIP = true;
include "getAPI.php";
include "openai.php";      //get your own openai.com API

//if (trim($deviceid) == "") exit('not available!');

function saveProfile($profile)
{
    $encoded = base64_encode(utf8_encode($profile));
    // Save $encoded to shared preferences or any other storage mechanism
}

function getProfile()
{
    // Retrieve $encoded from shared preferences or any other storage mechanism
    $encodedProfile = ""; // Placeholder for the encoded profile string
    
    if ($encodedProfile !== null) {
        $decoded = utf8_decode(Base64::decode($encodedProfile));
        return $decoded;
    }
    
    return null;
}

function generateRandomString() {
    $charSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $sections = array();
    
    for ($i = 0; $i < 4; $i++) {
        $section = generateSection($charSet);
        $sections[] = $section;
    }
    
    $tmp = implode('-', $sections);
    echo 'GEN: ' . $tmp . PHP_EOL;
    return $tmp;
}

function generateSection($charSet) {
    $sectionLength = 5;
    $charCodes = array();
    
    for ($i = 0; $i < $sectionLength; $i++) {
        $charCodes[] = ord($charSet[random_int(0, strlen($charSet) - 1)]);
    }
    
    return implode('', array_map('chr', $charCodes));
}

$IP   = $_SERVER['REMOTE_ADDR'];
$now  = date("Y-m-d H:i:s");
$uuid = trim($_REQUEST['data']);

$f = fopen('log.txt', 'w+');
fputs($f, $uuid);
fclose($f);

$sql  = "SELECT * FROM auths WHERE (uuid LIKE '$uuid') ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$uid  = trim($row['id']) + 0;
$gpt  = trim($row['gpt']) ;
if ((mopenai($gpt) == 4) || ($gpt == "")) $gpt = "Highest Ethical Nobleman should does and meditate on";
if ($uid > 0) {
//---- pt.pgjbatam ------
$key = base64_encode($release);

   $avatar = $row['avatar'];
   $uuid   = trim($row['uuid']);
   $sql1   = "UPDATE auths set iplog='$IP', dt='$now', stat=1 WHERE (id=$uid) ";
   $res1   = mysqli_query($conn, $sql1);
   $msg    = "[OK] password matched";
} else {
//---- joni.pwi ------
$key = base64_encode($develop);

   $avatar = "https://dogemazon.net/ocai/user3.svg";
   //$uuid = "UID:" . generateRandomString();
   $sql1   = "INSERT INTO auths (iplog,dt,uuid,avatar,gpt,stat) VALUES ('$IP', '$now', '$uuid', 'https://dogemazon.net/ocai/user3.svg', '$gpt', 0) ";
   $res1   = mysqli_query($conn, $sql1);
   $msg    = "[OK] new uuid created";
}

$sql  = "SELECT COUNT(*) as tot FROM story WHERE (uid=$uid) ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$posting = trim($row['tot']) + 0;

$sql  = "SELECT COUNT(*) as tot FROM follow WHERE (fid=$uid) ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$follower = trim($row['tot']) + 0;

$sql  = "SELECT COUNT(*) as tot FROM follow WHERE (uid=$uid) ";
$res  = mysqli_query($conn, $sql);
$row  = mysqli_fetch_array($res);
$following = trim($row['tot']) + 0;

   $hasil = array(
	'uuid'    => $uuid,
	'avatar'  => $avatar,
  	'gpt'	  => $gpt,
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