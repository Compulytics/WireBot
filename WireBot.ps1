Import-Module Selenium
$WebDriver = Start-SeEdge
$MessageHashes = @{}
$MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$UTF8 = New-Object -TypeName System.Text.UTF8Encoding
Enter-SeUrl https://wireclub.com/login -Driver $WebDriver
$UserNameField = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("//*[@id=`"Username`"]"))
$PasswordField = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("//*[@id=`"Password`"]"))
$LoginButton = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("//*[@id=`"login-dialog`"]/div[3]/form/div[5]/span[2]/input"))
$UserNameField.SendKeys('MYBOTUSERNAME')
$PasswordField.SendKeys('MYBOTPASSWORD')
$LoginButton.Click()
$LoggedIn = $TRUE
$Replied = $FALSE
sleep 3
Enter-SeUrl https://www.wireclub.com/chat/room/MYROOM -Driver $WebDriver
$LoopCount = 0
$TextField = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("/html/body/div[3]/div[2]/div[2]/div/div[2]/div/div/div[1]/textarea"))
$EnterButton = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("/html/body/div[3]/div[2]/div[2]/div/div[2]/div/div/div[1]/input"))
function ReadChat{
    $Element = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("/html/body/div[3]/div[2]/div[2]/div/table/tbody/tr/td[1]/div/div"))
    foreach($RawMessage in $Element){
        $TimeStamp = [string](Get-Date -UFormat %s -Millisecond 0)
        $UserAndMessage = $RawMessage.Text -split "`n"
        $MessageContent = "$($UserAndMessage[0]) $($UserAndMessage[1])"
        $MessageID = [System.BitConverter]::ToString($MD5.ComputeHash($UTF8.GetBytes($MessageContent)))
        if(-not $MessageHashes.ContainsKey($MessageID)){
            if($UserAndMessage[0] -ne ""){
				$NewMessageFound = $True
				$Message = $UserAndMessage[1] -replace "`"", "\`""
                Write-Host "MessageID:" $MessageID
                Write-Host "TimeStamp: "$TimeStamp
                Write-Host "User: "$UserAndMessage[0]
                Write-Host "Message: "$Message
                Write-Host "-------------------------------------------------------------------------------"
                $CSVFormattedLine = '"{0}","{1}","{2}"' -f $TimeStamp, $UserAndMessage[0], $Message
                Add-Content -Path "C:\Users\$Env:UserName\Desktop\Philosophy.csv" -Value $CSVFormattedLine
                $MessageHashes.Add($MessageID, $TimeStamp)
				if (($Message  -match "MYBOTUSERNAME") -and ($Message -match "hello" -or $Message -match "hey" -or $Message -match "heya" -or $Message -match "hi")){
					$Reply = $True
					$ReplyMessage = $Message
					$ReplyUser = $UserAndMessage[0]
				}
            }
        }
    }
	if ($Reply){
		$TextField.SendKeys("Hello $ReplyUser")
		Write-Host "I replied to $ReplyUser with a hello!"
		$EnterButton.Click()
	}
}
While($LoggedIn){
	$RestTime = $(1..120 | get-random)
	Write-Host "I read the room..."
	ReadChat
	Write-Host "I now sleep for $RestTime seconds..."
	sleep $RestTime
}
