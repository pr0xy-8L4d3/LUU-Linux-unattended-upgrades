#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
echo
echo "****************************************************************************************************************"
echo -e "
                 (&,,,,,,,,@                 @,,,,,,,(@
                    @,,,,,,,,@                  @,,,,,,,@                 LUU - Linux unattended upgrades with gmail
          @,(@        *@,,,,,,@                  @,,,,,,,,/@                    notification
          %,,,,@        ,,,,,,,                  @,,,,,,,,,,,@                  
          @,,,,,,/@   &%,,,,,,@                  @,,,,,,,,,,,,,@          This script will save your time installing
           @,,,,,,,,,,,,,,,,,,,@               @,,,,,,,,,,,,,,,,/         unattended upgrades and ssmtp. After that
             @,,,,,,,,,,,,,,,,,,,,@         .@,,,,,,,,@,,,,,,,,,,,@@@@    your linux system will performing automatic
                 %@@@@@@@,,,,,,,,,,,@     @,,,,,,,,@         @,,,,,,,,/   upgrades and notify you over email.
                          .@,,,,,,,,,,,@@,,,,,,,,@           */,,,,,,@
                             @,,,,@&@@,,,,,,,,@              ,*,,,&#      Note: this only works for gmail accounts.
                               @#,,,,,,,,,,*@
                             @,,,,,,,,,,,,*,,,@                           Author: pr0xy-8L4d3
                          @,,,,,,,,,,,,,,*/,,,,,,@                        Version: 1.0
                       *@,,,,,,,,,,,,,,@,,,,,,,,,,,&,,,,,,&@
                     @,,,,,,,,,,,,,,,@    @,,,,,,,,,,,,,,,,,,,&*
                  @,,,,,,,,,,,,,,,@.        @*,,,,,,,,,,,,,,,,,,@
               .@,,,,,,,,,,,,,,,@            (,,,,,,@     @,,,,,,@
             @,,,,,,,,,,,,,,,/@              ,,,,,,%        @(,,,@
            ,,,,,,,,,,,,,,,@                 @,,,,,,,@         @,/
              @,,,,,,,,,,@                    @,,,,,,,,@(
                 @,,,,@,                        &@,,,,,,,,@  "
echo
echo "****************************************************************************************************************"
read -p  "1.) Sender gmail address: " sender
echo "****************************************************************************************************************"
echo -ne "2.) Sender password: "
stty -echo
CHARCOUNT=0
while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
do
    # Enter - accept password
    if [[ $CHAR == $'\0' ]] ; then
        break
    fi
    # Backspace
    if [[ $CHAR == $'\177' ]] ; then
        if [ $CHARCOUNT -gt 0 ] ; then
            CHARCOUNT=$((CHARCOUNT-1))
            PROMPT=$'\b \b'
            password="${password%?}"
        else
            PROMPT=''
        fi
    else
        CHARCOUNT=$((CHARCOUNT+1))
        PROMPT='*'
        password+="$CHAR"
    fi
done
stty echo
echo
echo "****************************************************************************************************************"
read -p "3.) Recipient email address: " recipient
echo "****************************************************************************************************************"
echo
printf "${RED}Note: Don't forget to enable less secure apps to access gmail account, otherwise sending emails will not work!${NC}"
echo
echo
echo "****************************************************************************************************************"

#install unattended-upgrades
sudo apt install unattended-upgrades apt-listchanges bsd-mailx
sudo dpkg-reconfigure -plow unattended-upgrades

#add settings to conf fie
echo -e 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
echo -e 'Unattended-Upgrade::Mail' '"'$recipient'";' >> /etc/apt/apt.conf.d/50unattended-upgrades

#install email
sudo apt install ssmtp

#clean conf file
sudo rm /etc/ssmtp/ssmtp.conf
sudo echo /etc/ssmtp/ssmtp.conf

#add conf settings
printf "root=username@gmail.com\nmailhub=smtp.gmail.com:587\nrewriteDomain=gmail.com\nhostname=yourlocalhost.yourlocaldomain.tld\nTLS_CA_FILE=/etc/ssl/certs/ca-certificates.crt\nUseTLS=Yes\nUseSTARTTLS=Yes\nAuthUser=$sender\nAuthPass=$password\nAuthMethod=LOGIN\nFromLineOverride=yes" >> /etc/ssmtp/ssmtp.conf

echo -e "root:$sender:smtp.gmail.com:587\nmainuser:$sender:smtp.gmail.com:587" >> /etc/ssmtp/revaliases
