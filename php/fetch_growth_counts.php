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
        ->where('status = 2')
        ->group('YEAR(created_at), MONTH(created_at)')
        ->order('YEAR(created_at) DESC, MONTH(created_at) DESC')
    , 0, 6)
->loadObjectList();

// Downloads
$downloads = $communityDb->setQuery(
    $communityDb->getQuery(true)
        ->select('count(*) as count, CONCAT_WS("/", MONTH(date_download), YEAR(date_download)) as date')
        ->from('#__asset_downloads')
        ->innerJoin('#__assets a ON a.id = asset_id')
        ->where('a.category_id = 2')
        ->group('YEAR(date_download), MONTH(date_download)')
        ->order('YEAR(date_download) DESC, MONTH(date_download) DESC')
    , 0, 6)
    ->loadObjectList();

header('Content-Type: application/json');
echo json_encode(
    [
        'downloads'       => $downloads,
        'signups'         => $signups,
        'signup_image'    => makeImage("SaaS Signups", $signups),
        'downloads_image' => makeImage("Downloads", $downloads)
    ]
);

function makeImage($graphTitle, $results)
{
    //Setting the chart variables
    $xLabel 	= "Count";
    $yLabel 	= "Month";

    //getting the maximum and minimum values for Y
    $data = [];
    foreach ($results as $result) {
        $data[$result->date] = $result->count;
    }

    //minimum
    $places = strlen(current($data));
    $mod    = pow(10, $places-1);
    $min    = $mod - current($data);

    //maximum
    $places = strlen(end($data));
    $mod    = pow(10, $places-1);
    $max 	= $mod + end($data);

    //storing those min and max values into an array
    $yAxis 	= array("min"=>$min, "max"=>$max);

    //------------------------------------------------
    // Preparing the Canvas
    //------------------------------------------------
    //setting the image dimensions
    $canvasWidth  = 500;
    $canvasHeight = 300;
    $perimeter    = 50;

    //creating the canvas
    $canvas = imagecreatetruecolor($canvasWidth, $canvasHeight);

    //allocating the colors
    $white     = imagecolorallocate($canvas, 255, 255, 255);
    $black     = imagecolorallocate($canvas, 0,0,0);
    $yellow    = imagecolorallocate($canvas, 248, 255, 190);
    $blue      = imagecolorallocate($canvas, 3,12,94);
    $grey      = imagecolorallocate($canvas, 102, 102, 102);
    $lightGrey = imagecolorallocate($canvas, 216, 216, 216);

    //getting the size of the fonts
    $fontwidth  = imagefontwidth(2);
    $fontheight = imagefontheight(2);

    //filling the canvas with light grey
    imagefill($canvas, 0,0, $lightGrey);


    //------------------------------------------------
    // Preparing the grid
    //------------------------------------------------
    //getting the size of the grid
    $gridWidth  = $canvasWidth  - ($perimeter*2);
    $gridHeight = $canvasHeight - ($perimeter*2);

    //getting the grid plane coordinates
    $c1 = array("x"=>$perimeter, "y"=>$perimeter);
    $c2 = array("x"=>$gridWidth+$perimeter, "y"=>$perimeter);
    $c3 = array("x"=>$gridWidth+$perimeter, "y"=>$gridHeight+$perimeter);
    $c4 = array("x"=>$perimeter, "y"=>$gridHeight+$perimeter);

    //------------------------------------------------
    //creating the grid plane
    //------------------------------------------------
    imagefilledrectangle($canvas, $c1['x'], $c1['y'], $c3['x'], $c3['y'], $white);

    //finding the size of the grid squares
    $sqW = $gridWidth/count($data);
    $sqH = $gridHeight/$yAxis['max'];

    //------------------------------------------------
    //drawing the vertical lines and axis values
    //------------------------------------------------
    $verticalPadding = $sqW/2;
    $increment = 0;
    foreach($data as $assoc => $value)
    {
        //drawing the line
        imageline($canvas, $verticalPadding+$c4['x']+$increment, $c4['y'], $verticalPadding+$c1['x']+$increment, $c1['y'], $black);

        //axis values
        $wordWidth = strlen($assoc)*$fontwidth;
        $xPos = $c4['x']+$increment+$verticalPadding-($wordWidth/2);
        ImageString($canvas, 2, $xPos, $c4['y'], $assoc, $black);

        $increment += $sqW;
    }

    //------------------------------------------------
    //drawing the horizontel lines and axis labels
    //------------------------------------------------
    //resetting the increment back to 0
    $increment = 0;

    for($i=$yAxis['min']; $i<$yAxis['max']; $i++)
    {

        //main lines

        //often the y-values can be in the thousands, if this is the case then we don't want to draw every single
        //line so we need to make sure that a line is only drawn every 50 or 100 units.

        if($i%$mod==0){
            //drawing the line
            imageline($canvas, $c4['x'], $c4['y']+$increment, $c3['x'], $c3['y']+$increment, $black);

            //axis values
            $xPos = $c1['x']-($fontwidth*strlen($i))-5;
            ImageString($canvas, 2, $xPos, $c4['y']+$increment-($fontheight/2), $i, $black);

        }
        //tics
        //these are the smaller lines between the longer, main lines.
        elseif(($mod/5)>1 && $i%($mod/5)==0)
        {
            imageline($canvas, $c4['x'], $c4['y']+$increment, $c4['x']+10, $c4['y']+$increment, $grey);
        }
        //because these lines begin at the bottom we want to subtract
        $increment-=$sqH;
    }

    //getting the size of the grid
    $gridWidth  = $canvasWidth  - ($perimeter*2);
    $gridHeight = $canvasHeight - ($perimeter*2);

    //getting the grid plane coordinates
    $c1 = array("x"=>$perimeter, "y"=>$perimeter);
    $c2 = array("x"=>$gridWidth+$perimeter, "y"=>$perimeter);
    $c3 = array("x"=>$gridWidth+$perimeter, "y"=>$gridHeight+$perimeter);
    $c4 = array("x"=>$perimeter, "y"=>$gridHeight+$perimeter);

    //imagefilledrectangle($canvas, $c1['x'], $c1['y'], $c3['x'], $c3['y'], $white);

    //finding the size of the grid squares
    $sqW = $gridWidth/count($data);
    $sqH = $gridHeight/$yAxis['max'];


    //------------------------------------------------
    // Making the vertical bars
    //------------------------------------------------
    $increment = 0; 		//resetting the increment value
    $barWidth = $sqW*.2; 	//setting a width size for the bars, play with this number
    foreach($data as $assoc=>$value)
    {
        $yPos = $c4['y']-($value*$sqH);
        $xPos = $c4['x']+$increment+$verticalPadding-($barWidth/2);
        imagefilledrectangle($canvas, $xPos, $c4['y'], $xPos+$barWidth, $yPos, $blue);
        $increment += $sqW;
    }

    //Graph Title
    ImageString($canvas, 2, ($canvasWidth/2)-(strlen($graphTitle)*$fontwidth)/2, $c1['y']-($perimeter/2), $graphTitle, $yellow);

    //X-Axis
    ImageString($canvas, 2, ($canvasWidth/2)-(strlen($xLabel)*$fontwidth)/2, $c4['y']+($perimeter/2), $xLabel, $yellow);

    //Y-Axis
    ImageStringUp($canvas, 2, $c1['x']-$fontheight*3, $canvasHeight/2+(strlen($yLabel)*$fontwidth)/2, $yLabel, $yellow);
    $name = uniqid(time()).'.jpeg';

    imagejpeg($canvas, '/usr/share/nginx/html/'.$name);
    imagedestroy($canvas);

    return $name;
}
