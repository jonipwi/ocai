<?php
// Parameters
$mean = 5;
$standardDeviation = 2.138;
$minValue = 2;
$maxValue = 9;
$numberOfRecords = 8;
$dataSet = [2, 4, 4, 4, 5, 5, 7, 9];

// Calculate the x and y values
$stepSize = ($maxValue - $minValue) / ($numberOfRecords - 1);
$xValues = [];
$yValues = [];

for ($i = 0; $i < $numberOfRecords; $i++) {
    $x = $minValue + $i * $stepSize;
    $xValues[] = $x;
    $z = ($x - $mean) / $standardDeviation;
    $y = (1 / ($standardDeviation * sqrt(2 * M_PI))) * exp(-0.5 * pow($z, 2));
    $yValues[] = $y;
}

// Plot the graph
$width = 400;  // Adjust the width of the graph
$height = 300; // Adjust the height of the graph

$image = imagecreatetruecolor($width, $height);
$bgColor = imagecolorallocate($image, 255, 255, 255);
$lineColor = imagecolorallocate($image, 0, 0, 0);
$pointColor = imagecolorallocate($image, 255, 0, 0);

imagefill($image, 0, 0, $bgColor);
imageline($image, 0, $height / 2, $width, $height / 2, $lineColor);

for ($i = 0; $i < $numberOfRecords; $i++) {
    $x = $i * ($width / ($numberOfRecords - 1));
    $y = $height - $yValues[$i] * $height;
    imagefilledellipse($image, $x, $y, 5, 5, $pointColor);
}

header('Content-Type: image/png');
imagepng($image);
imagedestroy($image);
?>
