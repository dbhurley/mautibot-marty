<?php
require_once __DIR__.'/vendor/autoload.php';

$dashboardDb = \Joomla\Database\DatabaseDriver::getInstance(array(
    "driver"   => "mysql",
    "host"     => "127.0.0.1",
    "port"     => "3307",
    "user"     => "root",
    "password" => "Q3+92*J4e[G7s8",
    "database" => "dashboard",
    "prefix"   => "app_"
));

$communityDb = \Joomla\Database\DatabaseDriver::getInstance(array(
    "driver"   => "mysql",
    "host"     => "127.0.0.1",
    "port"     => "3308",
    "user"     => "root",
    "password" => "m@ut1b0t",
    "database" => "mautic",
    "prefix"   => ""
));

//select count(*) as count, MONTH(created_at) as month, YEAR(created_at) as year from app_instances where status = 1  GROUP BY YEAR(created_at), MONTH(created_at) order by year DESC, month DESC LIMIT 0,6

// Monthly signups
$signups = $dashboardDb->setQuery(
    $dashboardDb->getQuery(true)
        ->select('count(*) as count, CONCAT_WS("/", MONTH(created_at), YEAR(created_at)) as date')
        ->from('#__instances')
        ->where('status = 1')
        ->where('created_at >= DATE_SUB(DATE_FORMAT(CURDATE(), \'%Y-%m-01\'), INTERVAL 6 MONTH) AND created_at <  DATE_FORMAT(CURDATE(), \'%Y-%m-01\')')
        ->group('YEAR(created_at), MONTH(created_at)')
        ->order('YEAR(created_at), MONTH(created_at)')
    )->loadAssocList();

// Downloads
$downloads = $communityDb->setQuery(
    $communityDb->getQuery(true)
        ->select('count(*) as count, CONCAT_WS("/", MONTH(date_download), YEAR(date_download)) as date')
        ->from('#__asset_downloads')
        ->innerJoin('#__assets a ON a.id = asset_id')
        ->where('a.category_id = 2')
        ->where('date_download >= DATE_SUB(DATE_FORMAT(CURDATE(), \'%Y-%m-01\'), INTERVAL 6 MONTH) AND date_download <  DATE_FORMAT(CURDATE(), \'%Y-%m-01\')')
        ->group('YEAR(date_download), MONTH(date_download)')
        ->order('YEAR(date_download), MONTH(date_download)')
    )->loadAssocList();

list ($signupImage, $signupData) = makeImage("SaaS Signups", $signups);
list ($downloadImage, $downloadData) = makeImage("Downloads", $downloads);

header('Content-Type: application/json');
echo json_encode(
    [
        'signups'         => $signupData,
        'signup_image'    => $signupImage,
        'downloads'       => $downloadData,
        'download_image'  => $downloadImage
    ]
);

function makeImage($graphTitle, $results)
{
    //getting the maximum and minimum values for Y
    $values = [];
    foreach ($results as $result) {
        $values[$result['date']] = (int) $result['count'];
    }

    $img_width=450;
    $img_height=300;
    $margins=20;


    # ---- Find the size of graph by substracting the size of borders
    $graph_width=$img_width - $margins * 2;
    $graph_height=$img_height - $margins * 2;
    $img=imagecreate($img_width,$img_height);


    $bar_width=20;
    $total_bars=count($values);
    $gap= ($graph_width- $total_bars * $bar_width ) / ($total_bars +1);


    # -------  Define Colors ----------------
    $bar_color=imagecolorallocate($img,0,64,128);
    $background_color=imagecolorallocate($img,240,240,255);
    $border_color=imagecolorallocate($img,200,200,200);
    $line_color=imagecolorallocate($img,220,220,220);

    # ------ Create the border around the graph ------

    imagefilledrectangle($img,1,1,$img_width-2,$img_height-2,$border_color);
    imagefilledrectangle($img,$margins,$margins,$img_width-1-$margins,$img_height-1-$margins,$background_color);


    # ------- Max value is required to adjust the scale	-------
    $max_value=max($values);
    $ratio= $graph_height/$max_value;

    # -------- Create scale and draw horizontal lines  --------
    $horizontal_lines=20;
    $horizontal_gap=$graph_height/$horizontal_lines;

    for($i=1;$i<=$horizontal_lines;$i++){
        $y=$img_height - $margins - $horizontal_gap * $i ;
        imageline($img,$margins,$y,$img_width-$margins,$y,$line_color);
        $v=intval($horizontal_gap * $i /$ratio);
        imagestring($img,0,5,$y-5,$v,$bar_color);

    }

    # ----------- Draw the bars here ------
    for($i=0;$i< $total_bars; $i++){
        # ------ Extract key and value pair from the current pointer position
        list($key,$value)=each($values);
        $x1= $margins + $gap + $i * ($gap+$bar_width) ;
        $x2= $x1 + $bar_width;
        $y1=$margins +$graph_height- intval($value * $ratio) ;
        $y2=$img_height-$margins;
        imagestring($img,0,$x1+3,$y1-10,$value,$bar_color);
        imagestring($img,0,$x1+3,$img_height-15,$key,$bar_color);
        imagefilledrectangle($img,$x1,$y1,$x2,$y2,$bar_color);
    }

    $name = uniqid(time()).'.png';
    imagepng($img, '/usr/share/nginx/html/'.$name);
    imagedestroy($img);

    return [$name, $values];
}
