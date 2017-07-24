<?php
require_once __DIR__.'/vendor/autoload.php';

$db = \Joomla\Database\DatabaseDriver::getInstance(
    [
        "driver"   => "mysql",
        "host"     => "127.0.0.1",
        "port"     => "3310",
        "user"     => "root",
        "password" => "w3bsp@rk",
        "database" => "hubstats_development",
        "prefix"   => "",
    ]
);
date_default_timezone_set('America/New_York');

$topCount = (isset($argv[1])) ? $argv[1] : 10;

if (isset($argv[2])) {
    $fromDate  = new \DateTime($argv[2].' 00:00:00');
    $localFrom = $fromDate->format('Y-m-d H:i:s');

    // Convert to UTC
    $fromDate->setTimezone(new \DateTimeZone('UTC'));

    $toDate  = (isset($argv[3])) ? new \DateTime($argv[2].' 23:59:59') : (new \DateTime('now'))->modify('+1 day midnight - 1 second');
    $localTo = $toDate->format('Y-m-d H:i:s');

    // Convert to UTC
    $toDate->setTimezone(new \DateTimeZone('UTC'));
} else {
    $month = date('m');
    $year  = date('Y');
    if ($month >= 1 && $month <= 3) {
        $fromDate = "$year-01-01 00:00:00";
        $toDate   = "$year-03-31 23:59:59";
    } else if ($month >= 4 && $month <= 6) {
        $fromDate = "$year-04-01 00:00:00";
        $toDate   = "$year-06-30 23:59:59";
    } else if ($month >= 7 && $month <= 9) {
        $fromDate = "$year-07-01 00:00:00";
        $toDate   = "$year-09-30 23:59:59";
    } else if ($month >= 10 && $month <= 12) {
        $fromDate = "$year-10-01 00:00:00";
        $toDate   = "$year-12-31 23:59:59";
    }

    $localFrom = $fromDate;
    $localTo   = $toDate;

    $fromDate = (new \DateTime($fromDate))->setTimezone(new \DateTimeZone('UTC'));
    $toDate   = (new \DateTime($toDate))->setTimezone(new \DateTimeZone('UTC'));
}

$fromDate = $fromDate->format('Y-m-d H:i:s');
$toDate   = $toDate->format('Y-m-d H:i:s');

// pull requests
$pulls = $db->setQuery(
    $db->getQuery(true)
        ->select(
            'COUNT(*) AS "Total PRs", sum(additions) as "Added Lines", sum(deletions) as "Deleted Lines", sum(additions) - sum(deletions) as "Net Lines"'
        )
        ->from('hubstats_pull_requests')
        ->where("merged = 1 and created_at between '$fromDate' and '$toDate'")
)->loadAssoc();

$results      = $db->setQuery(
    $db->getQuery(true)
        ->select(
            'COUNT(*) AS "Total PRs",  sum(additions) as "Added Lines", sum(deletions) as "Deleted Lines", sum(additions) - sum(deletions) as "Net Additions", u.login as "Contributor"'
        )
        ->from('hubstats_pull_requests pr')
        ->innerJoin('hubstats_users u on pr.user_id = u.id')
        ->where("pr.merged = 1 and pr.created_at between '$fromDate' and '$toDate'")
        ->group('u.login')
        ->order('sum(additions) - sum(deletions) desc')
    ,
    0,
    $topCount
)->loadAssocList();
$contributors = [];
foreach ($results as $r) {
    $contributor = $r['Contributor'];
    unset($r['Contributor']);
    $contributors[$contributor] = $r;
}

$comments = $db->setQuery(
    $db->getQuery(true)
        ->select('COUNT(*) AS "Total Comments" ')
        ->from('hubstats_comments c')
        ->where("c.created_at between '$fromDate' and '$toDate'")
)->loadAssoc();

$results    = $db->setQuery(
    $db->getQuery(true)
        ->select('COUNT(*) AS total, u.login')
        ->from('hubstats_comments c')
        ->where("c.created_at between '$fromDate' and '$toDate'")
        ->innerJoin('hubstats_users u on c.user_id = u.id')
        ->group('u.login')
        ->order('COUNT(*) desc')
    ,
    0,
    $topCount
)->loadAssocList();
$commenters = [];
foreach ($results as $r) {
    $commenters[$r['login']] = $r['total'];
}

header('Content-Type: application/json');
echo json_encode(
    [
        'prs'                => $pulls,
        'contributors'       => $contributors,
        'contributor_string' => implode(', ', array_keys($contributors)),
        'comments'           => $comments,
        'commenters'         => $commenters,
        'commenter_string'   => implode(', ', array_keys($commenters)),
        'fromDate'           => $localFrom,
        'toDate'             => $localTo,
    ]
);
