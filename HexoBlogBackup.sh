#!/usr/bin/bash
# 函数1: 实现本地server预览和部署
localServerAndDeploy(){
	# 1、进入到博客根目录
	cd D:/blog/
	# 2、本地预览server
	hexo clean && hexo generate && start  http://localhost:4000 && hexo server
	# 3、是否部署
	flag=true
	while ($flag)
	do 
		read -p "if continue to deploy to the remote repository[Y/N]: " ifDeploy
		if [ "$ifDeploy" == "N" ]
		then
			echo "thank you ,catch you later!"
			break
		elif [ "$ifDeploy" == "Y" ]
		then
			# 部署
			if hexo deploy;then
				echo -e "\033[32m deploy to remote successfully! \033[0m"
				localBlogBackup
				break
			else
				echo -e "\033[31m failed to deploy to the remote repository!  \033[0m"
			fi
		else
			echo -e "\033[31m The content(Y/N) is wrong,please check again! \033[0m"      
		fi
	done
}
# ---------------------------------------------
# 函数2: 实现本地博客备份
localBlogBackup(){
	# 进入blog目录判断文件是否存在
	cd D:/blog/
	if [ ! -f "./blog/.git" -a -f "./blog/.deploy_git" ];then
		echo -e "\033[31m file .git or .deploy_git not exists \033[0m"
	else
		# 1、表示将 当前目录下的 blog/.git .deploy_git
		# 进入到d盘下
		cd /d
		if rm -rf ./blog/.git ./blog/.deploy_git ;then
			echo -e "\033[32m  .git and .deploy_git have deleted ! \033[0m"
			#开始复制
			if cp -R ./blog ./blog_backup/ ;then
				echo -e "\033[32m  blog have backuped to blog_backup/ \033[0m"
				# 备份成功,则推送到远端
				deployAfterBackup
			else
				echo -e "\033[31m error: failed to backup blog to blog_backup/ \033[0m"
			fi
		else
			echo -e "\033[31m error: failed to delete .git or .deploy_git file \033[0m"
		fi
	fi
}
# -----------------------------------------------------------------
# 函数3: 实现备份后推送到github
deployAfterBackup(){
	flag=true
	while ($flag)
	do 
		read -p "if continue to push to the remote backup repository[Y/N]: " ifBackup
		if [ "$ifBackup" == "N" ]
		then
			echo "thank you ,catch you later!"
			break
		elif [ "$ifBackup" == "Y" ]
		then
			# 启动备份
			read -p "please input commment for commit to remote repository: " commmitComment
			# 进入 blog_backup/
			cd /d/blog_backup/ 
			# git config --global core.autocrlf true
			git add .
			git commit -m "$commmitComment"
			# 判断,如果git push失败则提示是否重新push
			while ($flag)
			do
				if git push origin master ;then
					echo -e "\033[32m  blog have pushed to the remote backup repository \033[0m"
					break 2
				else
					echo -e "\033[31m  blog have failed to push to the remote backup repository \033[0m"
				fi
			done
		else
			echo -e "\033[31m The content(Y/N) is wrong,please check again! \033[0m"      
		fi
	done
}
# 函数调用
localServerAndDeploy