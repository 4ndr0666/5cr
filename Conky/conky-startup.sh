#!/bin/bash
#
# check if user has logged in
if [[ $LOGED_USER = *andro* ]]; then

 
 notify-send -i $notifyIcon "Information display will start in few seconds";
 echo "Information display will start in few seconds";
 
 
# Dell xps14 won;t stat with usbguard
#SERVICE='usbguard-applet-qt';
#if !(ps ax | grep -v grep | grep $SERVICE > /dev/null)
#then
	#usbguard=$(cat $Jason_file_name | jq -r .usbguardstatus);
	#if [[ "$usbguard" == *Yes* ]]
	#then
		#sudo killall usbguard-applet-qt;
		#sudo nohup usbguard-applet-qt &  > /dev/null 2>&1;   
		#sleep 3;
	#fi			
#fi		
 
	# First boot message
	#xP=$(id -u $LOGED_USER)
	#if [[ $xP != 1000 ]] 
	#then
	#	sleep 40;
	#	xfdesktop -A;
		#No need fixed in 20.04
	#	cinnamon-session -r;
	#else
	#	echo "Skip cinnamon-session restart";		
	#	#No need fixed in 20.04
	#	sleep 15;
	#	cinnamon-session -r;
	#fi
	
	
	 
	while true; do
		showConky=$(cat $Jason_file_name | jq -r .showconky);
		if [[ "$showConky" == *Yes* ]]
		then 
			if [[ $LOGED_USER = $EXEC_USER ]]; then
				SERVICE='conkyrc0';
				if !(ps ax | grep -v grep | grep $SERVICE > /dev/null)
				then		
					
					SERVICE='cinnamon-desktop';
					if (ps ax | grep -v grep | grep $SERVICE > /dev/null)
					then
						#sleep 1;
						sudo killall conky;
						sleep 5;
						# use for cron for now killall is enopugh
						#export pid=`ps aux | grep conkyrc7 | awk 'NR==1{print $2}' | cut -d' ' -f1`;kill -9 $pid;
						sleep 1;
						conky -d -c "/home/andro/.conky/4ndr0666/Gotham";	
						sleep 1
						conky -d -c "/home/andro/.conky/4ndr0666/.conkyrc1";	
						sleep 1
						conky -d -c "/home/andro/.conky/4ndr0666/.conkyrc3";	
						sleep 1
						conky -d -c "/home/andro/.conky/4ndr0666/.conkyrc2";						
						#sleep 1
						#conky -d -c "$Mykodachi_path/.conkyrc4";	
						# Fix Networkapplet showing twice
												
					fi
				fi
			fi
		fi
		sleep 15;
		
		# Replaced with xfce4-panel -r
		#sleep 3;
		
		# Network applet issues fix
		#theTotal=$(ps ax | grep -v grep | grep nm-applet|wc -l)	
		#if [[ $theTotal -gt 1 ]]
		#then 
			#sudo pkill nm-applet && nm-applet & > /dev/null;
			#echo "in 1";
		#fi 	
		
		#sleep 3;
		
		#SERVICE='nm-applet';
		#if !(ps ax | grep -v grep | grep $SERVICE > /dev/null)
		#then	
			#nm-applet;
		#fi						
		
	 
	done				

fi
