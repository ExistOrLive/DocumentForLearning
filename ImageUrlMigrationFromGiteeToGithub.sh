
function dealItem() {

    item=$1
    echo "dcasdas"${item}

    if [ -d ${item} ]
    then
        cd $item
        array=(`ls`)
        for tmp in ${array[@]}
        do 
            dealItem "${tmp}"
        done 
        cd ..
    elif  [ -f ${item} ]
    then 
         mdItem=`echo ${item} | grep .md`
         if ! [ -d ${mdItem} ]
         then 
             targetFile="`pwd`/${mdItem}"
             echo ${targetFile}
             sed -i -e 's/https:\/\/gitee.com\/existorlive\/exist-or-live-pic/https:\/\/github.com\/existorlive\/existorlivepic/g' "${targetFile}"
             rm ${targetFile}-e
         fi  
    fi 


    return 0
} 




# 输入目录
targetDir=$1
echo $targetDir
if ! [ -d ${targetDir} ]
then
   echo ${targetDir}不是一个目录
   exit 1 
fi

# 遍历目录
dealItem ${targetDir}




    

