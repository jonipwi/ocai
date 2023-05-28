<?php
function import_class(string $dir) {
    foreach(glob("{$dir}/*.php") as $file) {
	include_once $file;
    }
}
import_class("ui");
?>