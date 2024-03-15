Import-Module Selenium
$WebDriver = Start-SeEdge
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
Enter-SeUrl https://www.wireclub.com/chat/room/philosophy -Driver $WebDriver
$LoopCount = 0
$TextField = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("/html/body/div[3]/div[2]/div[2]/div/div[2]/div/div/div[1]/textarea"))
$EnterButton = $WebDriver.FindElements([OpenQA.Selenium.By]::XPath("/html/body/div[3]/div[2]/div[2]/div/div[2]/div/div/div[1]/input"))
While($LoggedIn){
	$RestTime = $(1..120 | get-random)
	$MessagesToSend = Import-CSV -Path ChatText.txt
	$CurrentMessage = [string]$($MessagesToSend | Get-Random | Select-Object Message).Message
	$TextField.SendKeys($CurrentMessage)
	$EnterButton.Click()
	Write-Host "I said: $CurrentMessage"
	Write-Host "I now sleep for $RestTime seconds..."
	sleep $RestTime
}
