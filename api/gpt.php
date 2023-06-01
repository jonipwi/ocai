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
	$sql = "SELECT id FROM auths WHERE (alatid LIKE '$deviceid') ";
	$res = mysqli_query($conn, $sql);
	$row = mysqli_fetch_array($res);
	$ada = trim($row['id']) + 0;
	if ($ada > 0) {
           $r = xopenai(trim($q));     //do some analysis with openai.com API for prompt analysis (for recognized device).
	} else {
	   $r = openai($q);     //do some analysis with openai.com API for prompt analysis (for non recognized device).
	}

	$q1 = str_replace("'", "`", $q);
	$r1 = str_replace("'", "`", $r);

    	$sql2 = "INSERT INTO `qa` (dt,ques,answ,stat) VALUES (NOW(),'$q1','$r1',0) ";
    	$res2 = mysqli_query($conn, $sql2);

	//$f = fopen('./sql.log', 'w+');
	//fputs($f, $sql2);
	//fclose($f);
    }
    
    return trim($r);
}
if (trim($deviceid) == "") exit('not available!');

$sql3 = "DELETE FROM ocaidb.`qa` WHERE (answ='') OR (ques LIKE 'text') ";
$res3 = mysqli_query($conn, $sql3);

$sql3 = "UPDATE ocaidb.`qa` SET stat=1 WHERE (answ='Spirit') ";
$res3 = mysqli_query($conn, $sql3);

$sum3 = 0; $total = 0; $data3 = ""; $max = 0; $min = 9;
$sql3 = "SELECT SUBSTRING(dt,1,10) as tgl, stat FROM ocaidb.`qa` ORDER BY id ASC ";
$res3 = mysqli_query($conn, $sql3);
while($row3 = mysqli_fetch_array($res3)) {
   $total++ ;
   $sum3   = $sum3 + $row3[1] + 0;
   $data3 .= "". $row3[1] . ",";
   if ($max < $row3[1]) $max = $row3[1];
   if ($min > $row3[1]) $min = $row3[1];
}
$sdata3 = explode(",", substr($data3,0, strlen($data3)-1));
$snow = round($sdata3[count($sdata3)-1], 3);
sort($sdata3);

$sum3 = round($sum3, 3) + 0;
$mean = round($sum3 / $total, 3) + 0;
$min  = round($min, 3);
$max  = round($max, 3);

$distance_sum = 0;
foreach ($sdata3 as $i) {
  $distance_sum += ($i - $mean) ** 2;
}
$variance = $distance_sum / $total;
$std_deviation = round(sqrt($variance), 3);

//print $variance . " " . $std_deviation;

$udata[] = round($mean, 3);
for($i=1; $i <= 5; $i++) {
   $udata[] = round($mean - ($std_deviation * $i), 3);
   $udata[] = round($mean + ($std_deviation * $i), 3);
}
sort($udata);

$IP   = $_SERVER['REMOTE_ADDR'];
$sql1 = "INSERT INTO iplog (dt,ip,stat) VALUES (NOW(),'$IP',0) ";
$res1 = mysqli_query($conn, $sql1);

$res    = chatGPT($conn, trim($targetid));
$res64  = base64_encode($res. "\nMin:$min, Max:$max, N:$total, Mean: $mean, Std: $std_deviation,\nNote: This context was generated by AI/GPT, please use it wisely. This system does not need any personal identity information. Do not write any personal identity here. thank you.\nSample graph indicator as belows:");
$status = 1;

print $status . "|" . $res64;
?>