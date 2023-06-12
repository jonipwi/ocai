<?php 
session_start();
date_default_timezone_set('Asia/Bangkok');
error_reporting(0);

function getRegex($regx, $n) {
   $h = explode("|", $regx);
   for ($i=0; $i < $n; $i++) {
       $h2[] = $h[$i];
   }
   $r = implode("|", $h2);
   return $r;
}

function cleanPrepEx($net101, $tot) {

  $r2  = str_replace(" ", "|", trim(preg_replace("/[^a-zA-Z ]+/", "", trim($net101))));
  $r3  = getRegex($r2, $tot);

  $prepositions = array(
    "about", "above", "across", "after", "against", "along", "among", "around", "at", "before",
    "behind", "below", "beneath", "beside", "between", "beyond", "but", "by", "concerning", "considering",
    "despite", "down", "during", "except", "for", "from", "in", "inside", "into", "like", "near",
    "of", "off", "on", "onto", "out", "outside", "over", "past", "regarding", "round", "since",
    "through", "throughout", "to", "toward", "under", "underneath", "until", "up", "upon", "with", "within",
    "without"
  );

  //for ($i=0; $i < count($prepositions); $i++) {
  //    $r3 = str_replace($prepositions[$i], "", $r3);
  //}

  $r3 = str_replace(" ", "", str_replace("||", "|", $r3));
  return $r3;
}

$totKeywords = 66;

$MyWebsite = "http://127.0.0.1/";
$host = "localhost";
$user = "root";
$pass = "";
$db   = "ocaidb";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn -> connect_errno) {
   echo "Failed to connect to MySQL: " . $conn -> connect_error;
   exit();
}

if (!$conn->set_charset("utf8")) {
   printf("Error utf8: %s\n", $conn->error);
} else {
   //printf("Charset: %s\n", $conn->character_set_name());
}

$sqla = "SELECT * FROM `api` ";
$resa = mysqli_query($conn, $sqla);
while($rowa = mysqli_fetch_array($resa)) {
   switch (trim($rowa['uuid'])) {
       case "develop": $develop = $rowa['key']; break;
       case "release": $release = $rowa['key']; break;
   }
}

?>