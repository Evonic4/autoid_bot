# autoid_bot
   
1. install docker  
2. configure settings.conf  
#1-TOKEN
#2-RS waiting time in sec 
#3-simple proxy (example 192.168.56.101:3111)
#4-seconds between api telegram checks 
#5-chat_id for start message 
3. start:  
docker run -v "./settings.conf:/usr/share/autoid_bot/settings.conf" evonic/autoid_bot
  