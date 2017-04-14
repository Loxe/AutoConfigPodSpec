#!/bin/bash

getProjectName() {
  projectName="$1"
  arr=(${projectName//_/ })  
  projectName=${arr[0]};    
  projectName=${projectName//.\//}
  desc=""
}

getURLName() {
  urlName="$projectName"
}

getHTTPSRepo() {
  httpsRepo="http://$gitURL/$gitGroup/$urlName.git"
}

getSSHRepo() {
  sshRepo="git@$gitURL:$gitGroup/$urlName.git"
}

getHomePage() {
  homePage="http://$gitURL/$gitGroup/$urlName"
}

getVersion() {
  version="$1"
  arr=(${version//_/ })  
  version=${arr[1]};    
  if [ -z "$version" ] ; then
    version="1.0.0"
  fi
}

getDESC() {
  desc="$1"
  arr=(${desc//_/ })  
  desc=${arr[2]};   
  if [ -z "$desc" ]; then
    desc="this is $projectName"
  fi
}

getInfomation() {
  getProjectName $1
  getURLName $1
  getHTTPSRepo
  getSSHRepo
  getHomePage
  getVersion $1
  getDESC $1

  echo -e "${Default}======================参数======================"
  echo -e "  Project Name  :  ${Cyan}${projectName}${Default}"
  echo -e "  HTTPS Repo    :  ${Cyan}${httpsRepo}${Default}"
  echo -e "  SSH Repo      :  ${Cyan}${sshRepo}${Default}"
  echo -e "  Home Page URL :  ${Cyan}${homePage}${Default}"
  echo -e "  Version       :  ${Cyan}${version}${Default}"
  echo -e "======================参数======================"
}


for file in ./*
do
  if test -d $file
    then
    if [ "$file" == "./autoConfigTemplates" ]; then
        continue
    fi
    Cyan='\033[0;36m'
    Default='\033[0;m'

    gitURL="git.tongbanjie.com"
    gitGroup="Client_iOS"

    projectName=""
    urlName=""
    httpsRepo=""
    sshRepo=""
    homePage=""
    confirmed="n"
    version=""
    desc=""

    # echo -e "${Cyan}==========进入 $file 目录=========${Default}"
    # while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
    # do
    #   if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
        getInfomation $file
    #   fi
    #   read -p "confirm? (y/n):" confirmed
    # done



    licenseFilePath="$file/FILE_LICENSE"
    gitignoreFilePath="$file/.gitignore"
    specFilePath="$file/${projectName}.podspec"
    readmeFilePath="$file/readme.md"
    uploadFilePath="$file/upload.sh"
    podfilePath="$file/Podfile"

    echo  "正在将文件移动到Classes文件夹"
    cp -r "$file/" ".tmp"
    cd $file
    rm -rf  *
    mkdir -p "Classes"
    cd ..
    cp -r ".tmp/" "$file/Classes"
    rm -rf ".tmp/"

    echo "正在拷贝 $licenseFilePath"
    cp -f ./autoConfigTemplates/FILE_LICENSE "$licenseFilePath"
    echo "正在拷贝 $gitignoreFilePath"
    cp -f ./autoConfigTemplates/gitignore    "$gitignoreFilePath"
    echo "正在拷贝 $specFilePath"
    cp -f ./autoConfigTemplates/pod.podspec  "$specFilePath"
    echo "正在拷贝 $readmeFilePath"
    cp -f ./autoConfigTemplates/readme.md    "$readmeFilePath"
    echo "正在拷贝 $uploadFilePath"
    cp -f ./autoConfigTemplates/upload.sh    "$uploadFilePath"
    echo "正在拷贝 $podfilePath"
    cp -f ./autoConfigTemplates/Podfile      "$podfilePath"
    echo "正在拷贝项目文件"
    cp -r -f ./autoConfigTemplates/ProjectTemplate/ "$file"
    mv "$file/--ProjectName--" "$file/$projectName"
    mv "$file/--ProjectName--.xcodeproj" "$file/$projectName.xcodeproj"


    echo "修改模板文件..."
    sed -i "" "s%__ProjectName__%${projectName}%g" "$gitignoreFilePath"
    sed -i "" "s%__ProjectName__%${projectName}%g" "$readmeFilePath"
    sed -i "" "s%__ProjectName__%${projectName}%g" "$uploadFilePath"
    sed -i "" "s%__ProjectName__%${projectName}%g" "$podfilePath"

    sed -i "" "s%__ProjectName__%${projectName}%g" "$specFilePath"
    sed -i "" "s%__HomePage__%${homePage}%g"      "$specFilePath"
    sed -i "" "s%__HTTPSRepo__%${httpsRepo}%g"    "$specFilePath"
    sed -i "" "s%__Version__%${version}%g"        "$specFilePath"
    sed -i "" "s%__DESC__%${projectName} ${desc}%g"        "$specFilePath"

    sed -i "" "s%--ProjectName--%${projectName}%g" "$file/$projectName.xcodeproj/project.pbxproj"
    echo "修改完成"




    echo "清除临时文件 初始化GIT..."
    cd $file
    git init &> /dev/null
    git remote add origin $sshRepo  &> /dev/null
    git rm -rf --cached ./Pods/     &> /dev/null
    git rm --cached Podfile.lock    &> /dev/null
    git rm --cached .DS_Store       &> /dev/null
    git rm -rf --cached $projectName.xcworkspace/           &> /dev/null
    git rm -rf --cached $projectName.xcodeproj/xcuserdata &> /dev/null
    git rm -rf --cached $projectName.xcodeproj/project.xcworkspace/xcuserdata &> /dev/null
    git add . &> /dev/null
    git status &> /dev/null
    git commit -m "init" &> /dev/null
    git push -u origin master &> /dev/null
    # git tag -a $version -m "v$version"
    # git push --tags
    echo "初始化完毕"
    echo -e "${Cyan}==========完成 $file 目录配置=========${Default}\n"
    # ./upload.sh

    cd ..
  fi
done