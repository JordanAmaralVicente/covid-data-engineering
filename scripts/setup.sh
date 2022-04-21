GREEN='\033[0;32m'
BLUE='\33[0;96m'
NC='\033[0m'

echo "${BLUE}Sending Files to Namenode container...${NC}";
docker cp data/ namenode:/data && echo "${GREEN}Files sent successfully!${NC}";

echo "\n${BLUE}Creating directory /user/root on HDFS${NC}"
docker exec namenode hdfs dfs -mkdir /user/root && echo "${GREEN}Directory created successfully!${NC}";

echo "\n${BLUE}Sending Files to HDFS from Namenode";
docker exec namenode hdfs dfs -put /data /user/root && echo "${GREEN}Files sent to HDFS sucsessfully${NC}";
docker exec namenode hdfs dfs -chmod 777 /user/root/data
docker exec namenode hdfs dfs -chmod 777 /user/root/data/*.csv

echo "\n${BLUE}HDFS output from list the /user/root/data folder${NC}:";
docker exec namenode hdfs dfs -ls /user/root/data
