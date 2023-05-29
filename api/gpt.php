<?php
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";
include "openai.php";   //get your own API from openai

function chatGPT($q) {
    $r = "no result.";
    //process the $q with GPT, AI, AGI and given result in $r
    if (trim($q) != "") {
        $r = openai($q);
    }
    
    return $r;
}
if (trim($deviceid) == "") exit('not available!');

$res    = chatGPT($targetid);
$res64  = base64_encode($res);
$status = 1;

print $status . "|" . $res64;
?>