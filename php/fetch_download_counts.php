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

// Get counts based on context
$results = $db->setQuery(
    $db->getQuery(true)
        ->select('tell_us_about_yourself as context, count(*) as number')
        ->from('#__form_results_5_downloadma')
        ->where('length(tell_us_about_yourself) > 0')
        ->group('tell_us_about_yourself')
        ->order('number DESC')
)->loadObjectList();
$context = [];
foreach ($results as $result) {
    $result->context = str_replace('&#39;', "'", $result->context);
    $context[$result->context] = $result->number;
}

header('Content-Type: application/json');
echo json_encode(
    [
        'total'   => $total,
        'latest'  => $latest,
        'context' => $context
    ]
);
