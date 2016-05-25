<?php
require_once __DIR__.'/vendor/autoload.php';

$db = \Joomla\Database\DatabaseDriver::getInstance(array(
    "driver"   => "mysql",
    "host"     => "127.0.0.1",
    "port"     => "3308",
    "user"     => "root",
    "password" => "m@ut1b0t",
    "database" => "mautic",
    "prefix"   => ""
));

// Get a sum for all downloads
$total = $db->setQuery(
    $db->getQuery(true)
        ->select('sum(unique_download_count)')
        ->from('#__assets')
        ->where('category_id = 2')
)->loadResult();

// Get the latest version's count
$latest = $db->setQuery(
    $db->getQuery(true)
        ->select('unique_download_count as download_count, title')
        ->from('#__assets')
        ->where('category_id = 2')
        ->order('id DESC'),
    0, 1
)->loadAssoc();


// Today's downloads
$todays = $db->setQuery(
    $db->getQuery(true)
        ->select('count(distinct(tracking_id)) as count')
        ->from('#__asset_downloads')
        ->where('DATE(date_download) = CURDATE()')
)->loadResult();

header('Content-Type: application/json');
echo json_encode(
    [
        'total'   => $total,
        'latest'  => $latest,
        'today'   => $todays
    ]
);
