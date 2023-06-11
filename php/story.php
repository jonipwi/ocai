<?php
include "db.php";
error_reporting(0);
include "secured.php";
include "getAPI.php";

$sql2 = "SELECT bigai.*, auths.avatar, auths.nick FROM bigai, auths WHERE (((bigai.stat = 4) AND (bigai.uuid LIKE '$deviceid')) OR (bigai.stat < 4)) AND (auths.uuid=bigai.uuid) AND (bigai.tipe LIKE 'STORY') ORDER BY 1 DESC ";
$res2 = mysqli_query($conn, $sql2);
$i = 0;
while($row2 = mysqli_fetch_array($res2)) {
    $i++;
    $pid       = trim($row2['id']) + 0;
    $uuid      = trim($row2['uuid']);
    $avatar    = trim($row2['avatar']);
    $nick      = trim($row2['nick']);
    $data      = trim($row2['data']);
    $tags      = trim($row2['tags']);
    $photo     = trim($row2['photo']);
    $tipe      = trim($row2['tipe']);
    $timestamp = trim($row2['dt']);
    $btnstat   = $row2['stat1'] . "," . $row2['stat2'] . "," . $row2['stat3'] . "," . $row2['stat4'] ;

       $items[] = array(
	'id'        => $pid,
	'uuid'      => $uuid,
	'avatar'    => $avatar,
	'nick'      => $nick,
	'data'      => $data,
	'tags'      => $tags,
	'photo'     => $photo,
	'tipe'      => $tipe,
	'btnstat'   => $btnstat,
	'timestamp' => $timestamp,
       );

}
$jsonStory = base64_encode('{"json":'.trim(json_encode($items)).'}') ;

$hasil = array(
	'uuid'    => $deviceid,
	'photo'   => $newphoto,
	'dt'      => $ymd,
	'message' => $errmsg,
	'story'	  => $jsonStory,
   );

$encoded = $hasil;
$myJSON = json_encode($encoded);
header('Content-type: application/json; charset=utf-8');
exit($myJSON);
?>