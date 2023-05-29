<?php
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";
include "openai.php";

function chatGPT($conn, $q) {

    global $deviceid;

    $r = "no result.";
    //process the $q with GPT, AI, AGI and given result in $r
    if (trim($q) != "") {
        $sql = "SELECT id FROM auths WHERE (alatid LIKE '$deviceid') ";
        $res = mysqli_query($conn, $sql);
        $row = mysqli_fetch_array($res);
        $ada = trim($row['id']) + 0;
        if ($ada > 0) {
               $r = xopenai(trim($q));
        } else {
           $r = openai($q);
        }
    }
    
    return trim($r);
}
if (trim($deviceid) == "") exit('not available!');

$IP   = $_SERVER['REMOTE_ADDR'];
$sql1 = "INSERT INTO iplog (dt,ip,stat) VALUES (NOW(),'$IP',0) ";
$res1 = mysqli_query($conn, $sql1);

$res    = chatGPT($conn, trim($targetid));
$res64  = base64_encode($res);
$status = 1;

print $status . "|" . $res64;
?>