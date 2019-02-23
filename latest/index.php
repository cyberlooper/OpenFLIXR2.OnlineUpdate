<link href='https://fonts.googleapis.com/css?family=Raleway' rel='stylesheet' type='text/css'>
<link href="../openflixr/assets/css/bootstrap.css" rel="stylesheet">
<link href="../openflixr/assets/css/main.css" rel="stylesheet">
<link href="../openflixr/assets/css/ihover.css" rel="stylesheet">
<body style="background-color: transparent">
<center><h4>Recent releases</h4>
<div style="position: relative">
<table style="font-size: 14px; color:rgba(255, 255, 255, 0.7);" border="0" cellspacing="" cellpadding="10px">
<?php
include_once("inc/config.php");
$command = "get_recently_added"; //command used for parsing json - DO NOT CHANGE OR ELSE THE CODE DIES
$count = "25"; //ammount of recenly added results  - YOU DONT HAVE TO CHANGE THIS
$plexpy_url = "http://localhost:8989/plexpy"; //plexpy url without "/"
$ip = "$plexpy_url/api/v2?apikey=$apikey&cmd=$command&count=$count";
include_once("inc/imdb_class.php");
$grab = file_get_contents($ip);
$jay = json_decode($grab,true);
$i = 0;
foreach($jay["response"]["data"]["recently_added"] as $items)
{
$output_year = $items['year'] ; //grab year
$output_tlt = $items['title']; //grab title(ussually for music)
$output_type = $items['media_type']; //grab media type so we can display only movies
$rating_key = $items['rating_key'];

$enc_key =  base64_encode($rating_key);
if($output_type == "movie")
{
//grab imdb poster
$oIMDB = new IMDB($output_tlt);
if ($oIMDB->isReady) {
$poster = $oIMDB->getPoster("big",true);//grab imdb poster
$rating = $oIMDB->getRating();//grab rating from imdb
$tagline = $oIMDB->getTagline();//grab tagline from imdb
$cast = $oIMDB->getCast($iLimit = 3, $bMore = false);
$yearimdb = $oIMDB->getYear();
$url = $oIMDB->getUrl();
}//end imdb if


//end check
?>
<div><th>
<span style="z-index:3;position:absolute;padding-left:6px;padding-top:8px;"><span class="label label-success"><?php echo $rating;?></span></span>
<span style="z-index:3;position:absolute;padding-left:125px;padding-top:8px;"><span class="label label-info"><?php echo $yearimdb;?></span></span>
<a href="<?php echo $url;?>" target="_blank"/>
<div class="ih-item square effect13 bottom_to_top"><a href="<?php echo $url;?>" target="_blank">
    <div class="img"><img class="img-rounded img-responsive" src="inc/<?php echo $poster;?>" width="170" height="255"/></div>
    <div class="info">
      <h3><?php echo $tagline;?></h3>
      <p><?php echo $cast;?></p>
    </div></a></div>
</a>
</th></div>

<?php

if (++$i == 6) break;
}
}//end foreach
?>
</tr>
<tr>
<?php
$i = 0;
foreach($jay["response"]["data"]["recently_added"] as $items)
{
$output_year = $items['year'] ; //grab year
$output_tlt = $items['title']; //grab title(ussually for music)
$output_tlt = substr($output_tlt, 0, 20);
$output_type = $items['media_type']; //grab media type so we can display only movies
$rating_key = $items['rating_key'];
$enc_key =  base64_encode($rating_key);
$oIMDB = new IMDB($output_tlt);
if ($oIMDB->isReady) {
$rating = $oIMDB->getRating();//grab rating from imdb
$url = $oIMDB->getUrl();
}
if($output_type == "movie")
{
//grab imdb poster

echo "<td style=\"padding-top: 0;padding-left:12;\">". $output_tlt. "</td>";

//end check
if (++$i == 6) break;
}
}
?>
</table>
</div>
</body>
