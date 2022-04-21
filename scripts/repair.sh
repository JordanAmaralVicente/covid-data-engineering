GREEN='\033[0;32m'
BLUE='\33[0;96m'
RED='\33[0;33m'
NC='\033[0m'

echo "${RED}Resending data to container...${NC}";
docker exec namenode rm -rf /data && docker cp data/ namenode:/data && echo "${GREEN}Files sent successfully!${NC}";

echo "\n${RED}Recreating directory /user/root on HDFS${NC}"
docker exec namenode hdfs dfs -rm -r -f /user/root && docker exec namenode hdfs dfs -mkdir /user/root && echo "${GREEN}Directory created successfully!${NC}";

echo "\n${BLUE}Resending data to HDFS";
docker exec namenode hdfs dfs -put /data /user/root && echo "${GREEN}Files sent to HDFS sucsessfully${NC}";