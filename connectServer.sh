#!/bin/bash

echo "please input your PASSCODE:"
read PASSCODE
username="*******"
ip="***.***.***.***"
expect -c "set timeout -1;
                spawn -noecho ssh -o StrictHostKeyChecking=no name@ip;
                expect {
			*assword:* { send -- public key\r;exp_continue; }
			*ASSCODE:* { send -- ${username}${PASSCODE}\r;exp_continue; } 
			*):*       { send -- ${ip}\r; }
                }	
	    interact;
	    exit;
	  "	
