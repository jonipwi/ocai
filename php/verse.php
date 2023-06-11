<?php
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";
include "openai.php";      //get your own openai.com API

function chatGPT($conn, $q) {
    global $medi;
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
	   $ymd = datE("Y-m-d");
	   $sql1 = "SELECT * FROM bigai WHERE (tipe LIKE 'VERSE') AND (uuid LIKE '$deviceid') AND (gpt LIKE '$targetid') AND (dt LIKE '$ymd %') ";
	   $res1 = mysqli_query($conn, $sql1);
	   $row1 = mysqli_fetch_array($res1);
	   $medi = trim($row1['id']) + 0;
	   if ($medi > 0) {
	      $r = base64_decode($row1['data']);
	   } else {
              $r = vopenai(trim($q));     //do some analysis with openai.com API for prompt analysis (for recognized device).
	   }
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

$medi = 0;
$IP   = $_SERVER['REMOTE_ADDR'];
$sql1 = "INSERT INTO iplog (dt,ip,stat) VALUES (NOW(),'$IP',0) ";
$res1 = mysqli_query($conn, $sql1);

//$targetid = "Please give me 1 quote and 1 verse for today that support to be trained become a highest ethical nobleman should meditating on";
$r = mopenai($targetid);
if ($r == 4) {
   $targetid = vopenai('Please suggest better one instead of this "'.$targetid.'" which build highest ethical noble characteristics not more than 8 words');
   $sql1 = "UPDATE auths SET gpt='$targetid' WHERE (uuid LIKE '$deviceid') ";
   $res1 = mysqli_query($conn, $sql1);
}
$promptid = 'Please give me 1 quote and 1 verse for today strictly only about this "'.$targetid.'" and do not tell me others not related.';
$res = chatGPT($conn, trim($promptid));

$res64  = base64_encode($res);
$status = 1;

if ($medi <= 0) {
   $sql1 = "INSERT INTO bigai (dt,tipe,data,uuid,tags,gpt,stat) VALUES (NOW(),'VERSE','$res64','$deviceid','#wisdom #knowledge #spiritual','$targetid',0) ";
   $res1 = mysqli_query($conn, $sql1);
}

print $status . "|" . $res64;
?>