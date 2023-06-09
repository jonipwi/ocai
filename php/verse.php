<?php
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";
include "openai.php";      //get your own openai.com API

function chatGPT($conn, $q) {

    global $deviceid;

    $r = "no result, your story might be too short.\nMay you tell me more?";
    //process the $q with GPT, AI, AGI and given result in $r
    $qq = explode(" ", $q);
    if ( (trim($q) != "") && (count($qq) > 2)) {
	$sql = "SELECT id FROM auths WHERE (uuid LIKE '$deviceid') ";
	$res = mysqli_query($conn, $sql);
	$row = mysqli_fetch_array($res);
	$ada = trim($row['id']) + 0;
	if ($ada > 0) {
           $r = vopenai(trim($q));     //do some analysis with openai.com API for prompt analysis (for recognized device).
	} else {
	   $r = openai($q);     //do some analysis with openai.com API for prompt analysis (for non recognized device).
	}

	$q1 = str_replace("'", "`", $q);
	$r1 = str_replace("'", "`", $r);

	//$f = fopen('./sql.log', 'w+');
	//fputs($f, $sql2);
	//fclose($f);
    }
    
    return trim($r);
}
if (trim($deviceid) == "") exit('not available!');

$IP   = $_SERVER['REMOTE_ADDR'];
$sql1 = "INSERT INTO iplog (dt,ip,stat) VALUES (NOW(),'$IP',0) ";
$res1 = mysqli_query($conn, $sql1);

$targetid = "Please give me 1 quote and 1 verse for today that support to be trained become a highest ethical nobleman should meditating on";
$res    = chatGPT($conn, trim($targetid));
$res64  = base64_encode($res. "\n\nNote: This context was generated by AI/GPT, please use it wisely.");
$status = 1;

print $status . "|" . $res64;
?>