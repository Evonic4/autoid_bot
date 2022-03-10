# autoid_bot
   
1. install docker docker-compose   
2. configure settings.conf  
#1-TOKEN  
#2-RS waiting time in sec   
#3-simple proxy (example 192.168.56.101:3111)  
#4-seconds between api telegram checks   
#5-chat_id for start message   
3. start docker-compose:  

version: "3.8"  
  
services:  
  autoid_bot:  
    image: evonic/autoid_bot  
    volumes:  
      - ./settings.conf:/usr/share/autoid_bot/settings.conf  
   
   
send /myid and get user_id in response  
send /id and get chat_id in response  
  