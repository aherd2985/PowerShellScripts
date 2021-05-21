$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
$Username = "someEmail@domain.com"
$Password = "Pa22w0rd"

$message = New-Object System.Net.Mail.MailMessage
$message.subject = "Here is the Subject"
$message.body = "<h1>Hello there</h1>It's 'General' Kenobi"
$message.bcc.add("someEmail@domain.com")
$message.from = "Me <someEmail@domain.com>"
$message.IsBodyHTML = $true

$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message)
