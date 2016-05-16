<?php
require_once __DIR__.'/vendor/autoload.php';

$db = \Joomla\Database\DatabaseDriver::getInstance(array(
    "driver"   => "mysql",
    "host"     => "127.0.0.1",
    "port"     => "3307",
    "user"     => "root",
    "password" => "Q3+92*J4e[G7s8",
    "database" => "internal_prod_dashboard",
    "prefix"   => "app_"
));

$results = $db->setQuery(
    $db->getQuery(true)
        ->select('count(*) as number, plan')
        ->from('#__instances')
        ->where('status = 1')
        ->group('plan')
)->loadObjectList();

$planCounts = ['total' => 0, 'active within last 30 days' => 0];
foreach ($results as $result) {
    $plan = $result->plan;
    if (empty($plan)) {
        $plan = 'free';
    }

    if (!isset($planCounts[$plan])) {
        $planCounts[$plan] = 0;
    }

    $planCounts[$plan]   += (int) $result->number;
    $planCounts['total'] += (int) $result->number;
}

// Get a count of active accounts
$active = $db->setQuery(
    $db->getQuery(true)
        ->select('count(*) as active')
        ->from('#__instances')
        ->where('status = 1')
        ->where('last_active < DATE_SUB(NOW(), INTERVAL 30 DAY)')
)->loadResult();
$planCounts['active within last 30 days'] = $active;

header('Content-Type: application/json');
echo json_encode($planCounts);
