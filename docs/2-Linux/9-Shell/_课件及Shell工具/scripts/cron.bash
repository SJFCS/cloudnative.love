# 备份策略：周3、周5、周日全备，周1，周2，周4,周6增备

03 01 * * 0   bash /backup/full.sh 
03 01 * * 1   bash /backup/incremental1.sh 
03 01 * * 2   bash /backup/incremental2.sh 
03 01 * * 3   bash /backup/full.sh 
03 01 * * 4  bash /backup/incremental1.sh  
03 01 * * 5   bash /backup/full.sh 
03 01 * * 6   bash /backup/incremental1.sh 