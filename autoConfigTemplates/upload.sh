#!/bin/bash
#参数一 podespec文件名
#参数二 提交备注
#参数三 tag版本号
#参数四 tag备注
#参数五 私有库

confirmed="n"
Cyan='\033[0;36m'
Default='\033[0;m'
podspecName=""
commitMsg=""
tagVersion=""
tagVersionMsg=""
sourcesName=""

# #获取podspec文件名
# getPodspecName() {
#     read -p "podspec文件名: " podspecName
#     if test -z "$podspecName"; then
#         getPodspecName
#     fi
# }

# #获取commit的备注
# getCommitMsg() {
#     read -p "提交备注: " commitMsg
#     if test -z "$commitMsg"; then
#         getCommitMsg
#     fi
# }

# #获取tag的版本
# getTagVersion() {
#     read -p "tag的版本: " tagVersion
#     if test -z "$tagVersion"; then
#         getTagVersion
#     fi
# }

# #获取tag版本的提交备注
# getTagVersionMsg() {
#     read -p "tag版本的提交备注: " tagVersionMsg
#     if test -z "$tagVersionMsg"; then
#         getTagVersionMsg
#     fi
# }

getInfomation() {
  podspecName=$1
  podspecName=${podspecName//.podspec/}
  commitMsg=$2
  tagVersion=$3
  tagVersionMsg=$4
  sourcesName=$5
  if  test -n "$sourcesName" ;then
    sourcesName=${sourcesName//sources/}
    sourcesName=${sourcesName// /}
    sourcesName=${sourcesName//-/}
    sourcesName=${sourcesName//=/}
  fi
  echo -e "${Default}======================参数======================"
  echo -e "  Podspec Name    :  ${Cyan}${podspecName}${Default}"
  echo -e "  Commit Msg      :  ${Cyan}${commitMsg}${Default}"
  echo -e "  Tag Version     :  ${Cyan}${tagVersion}${Default}"
  echo -e "  Tag Version Msg :  ${Cyan}${tagVersionMsg}${Default}"
  echo -e "  Repo Name       :  ${Cyan}${sourcesName}${Default}"
  echo -e "======================参数======================"
}

while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
  if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
    getInfomation $1 $2 $3 $4 $5
  fi
  read -p "confirm? (y/n):" confirmed
done

# echo "pod lib lint $podspecName.podspec"
echo "开始验证podspec文件"
pod cache clean --all
result=`pod lib lint $podspecName.podspec --sources=master,$sourcesName`
# echo  "pod lib lint $podspecName.podspec $sourcesName"
result=$result|grep -e "$podspecName passed validation"
if [[ -n "$result" ]]; then
  echo -e "\033[32m本地验证通过\033[0m"
  git add .
  git commit -m "$commitMsg"
  git tag -d $tagVersion
  git tag -a $tagVersion -m "$tagVersionMsg"
  git push origin -d tag $tagVersion
  git push origin master
  git push --tags
  echo "开始验证远程podspec文件"
  result=`pod spec lint $podspecName.podspec --sources=master,$sourcesName`
  result=$result|grep -e "$podspecName.AFNetworking.podspec passed validation."
  if [[ -n "$result" ]]; then
    echo -e "\033[32m远程验证通过\033[0m"
    if [[ -n "$sourcesName" ]]; then
      pod repo push $sourcesName $podspecName.podspec --verbose --allow-warnings
    fi
  else
    echo $result
    echo -e "\033[31m远程验证失败\033[0m"  
  fi
else
  echo $result
  echo -e "\033[31m本地验证失败\033[0m"
  exit -1;
fi
# echo "开始验证远程podspec文件"
# git add .
# git commit -m "$commitMsg"
# git -a $tagVersion -m "$tagVersionMsg"



# pod repo push TBJRepo AFNetworking.podspec --verbose --allow-warnings
