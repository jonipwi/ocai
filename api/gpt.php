<?php
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";

function chatGPT($q) {
    //process the $q
    $r = "testing";
    return $r;
}
if (trim($deviceid) == "") exit('not available!');

$res    = chatGPT($targetid);
$res64  = base64_encode($res);
$status = 1;

print $status . "|" . $res64;
?>