 curl -X POST  'https://admin-pre.myrightone.com/api/app/tableFree/query?app_key=isolation&model_name=service_base_info&database=test' |jq -r  .data[].sources  >sources


数组

❯ declare -A user_dict

# 添加一些键值对
user_dict["name"]="Alice"
user_dict["age"]=30
user_dict["city"]="New York"

# 打印数组中的值
echo "Name: ${user_dict["name"]}"
echo "Age: ${user_dict["age"]}"
echo "City: ${user_dict["city"]}"
Name: Alice
Age: 30
City: New York


提前声明数组



https://unix.stackexchange.com/questions/711789/how-to-hide-email-from-shell-prompt-with-starship