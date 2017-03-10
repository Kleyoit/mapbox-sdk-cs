$ErrorActionPreference="stop"


$url = "https://raw.githubusercontent.com/scriptcs-contrib/svm/master/api/svm-releases.xml"
$wc = New-Object System.Net.WebClient
[xml]$xml = $wc.DownloadString($url)

$message = $xml.svm.message
if ($message -ne $null) {
    Write-ErrorMessage $message
    Exit 1
}

$versions = @();

$xml.svm.releases.item |% {
    $version = New-Object PSObject -Property @{
        Version               = $_.version
        PublishedDate         = $_.publishedDate
        URL                   = $_.downloadURL
    }
    $versions += $version
}

$sorted = @()
$sorted = $versions | Sort-Object -Property PublishedDate -Descending
$dl_url = $sorted[0].URL
$latest_version = $sorted[0].Version
Write-Host "Latest scripcs version:" $latest_version
Write-Host "URL:" $dl_url

#$dl_file = [System.IO.Path]::Combine($PSScriptRoot, 'scriptcs.zip')
$cwd = Convert-Path -Path '.'
Write-Host "cwd:"  $cwd
$pkg_dir = [System.IO.Path]::Combine($cwd, 'packages');
If(!(test-path $pkg_dir)){
    New-Item -ItemType Directory -Force -Path $pkg_dir
}
$dl_file = [System.IO.Path]::Combine($cwd, 'packages', 'scriptcs.zip');
Write-Host "dowloading '$dl_url' to '$dl_file'";
$wc.DownloadFile($dl_url, $dl_file);

$cmd = "7z -y e `"packages\scriptcs.zip`" tools\* -oscriptcs | $env:windir\system32\FIND `"ing archive`""
iex $cmd
