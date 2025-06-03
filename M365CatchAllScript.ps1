# PARAMETERS

# 1
$catchalladdress = "catchall@domain.com"
$displayName = "Catch All Mailbox"
$password = ConvertTo-SecureString -String "Password01" -AsPlainText -Force
# 2
$distributiongroup = "Exclude from Catch All"
$aliasdistributiongroup = "exclude-from-catchall"
# 3
$catchallalias = (Get-EXOMailbox -Identity $catchalladdress).Alias
$flowruletitle = "JV-NL-Catchall"
$flowruledesc = "Your rule description"
# 4
$catchalldomain = "Your domainname"

# ------ Seperator -----------

# Step 1: Create Catch All Mailbox
New-Mailbox -UserPrincipalName $catchalladdress `
            -DisplayName $displayName `
            -Password $password `
            -FirstName "New" `
            -LastName "User"

# Step 2: Create Dynamic Distribution Group
New-DynamicDistributionGroup -Name '$distributiongroup' -Alias '$aliasdistributiongroup' -OrganizationalUnit $null -IncludedRecipients 'MailboxUsers'

# Step 3: Create the mailflow rule
New-TransportRule -FromScope 'NotInOrganization' -RedirectMessageTo '$doelalias' -ExceptIfSentToMemberOf $distributiongroup -Name 'AllMailboxes' -StopRuleProcessing:$false -Mode 'Enforce' -Comments $flowruledesc -RuleErrorAction 'Ignore' -SenderAddressLocation 'Header'

# Step 4: Set the relay of Internal
Set-AcceptedDomain -Identity $catchalldomain -DomainType InternalRelay
