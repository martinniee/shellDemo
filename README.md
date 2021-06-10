# 完成本地hexo blog自动部署和备份到远端仓库



## 目的

自动化Hexo本地server预览和部署工作

增加到本地文件夹和推送到GitHub私有仓库



前言:

使用Hexo搭建博客部署到GitHub上时,仓库中的文件是将Markdown渲染后的html静态文件
不是 源文件,所以有时想修改文章内容是不行的。
关于博客备份的问题,是偶尔想到如果要看以前的文章怎么办,如何记录下来
所以备份主要指的是版本的管理,但是有时又需要储存到非本地(GitHub),这样可以随时在新电脑继续搭建博客,基于这样的想法,加上以往部署备份博客的方式需要手动输入命令,很繁琐,所以了解了一下`Shell`脚本的基础知识,尝试编写一个`脚本`,自动化完成这些操作

---





## 简介

---

**实现脚本功能**

- 本地启动server预览
- 预览结束后选择是否部署
- 部署后选择是否备份到本地备份目录
- 备份后是否推送到GitHhub



**特性**

- 根据命令执行成功与否给出不同高亮提示
- 若执行不成功,则提示重新执行

---



帮助网站:

[shellcheck.net](https://www.shellcheck.net/)

##  使用

**文件准备和结构**

- 博客部署目录(`blog`)和博客源文件备份目录`blog_backup`



```css
    parent
          │
          │
          ├───blog
          │     │
          │     ├───.deploy_git
          │     │
          │     └─── xxxx
          │
          │
          └───blog_backup
```





1、新建文件`DeployAndBackup.sh`,复制以下代码

<details>

<summary>代码预览</summary>


```bash
#!/usr/bin/bash
localServerAndDeploy(){
	cd D:/blog/  # < ---更改为实际 博客根目录
	hexo clean && hexo generate && start  http://localhost:4000 && hexo server
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
localBlogBackup(){
	cd D:/blog/   # < ---更改为实际 博客根目录
	if [ ! -f "./blog/.git" -a -f "./blog/.deploy_git" ];then
		echo -e "\033[31m file .git or .deploy_git not exists \033[0m"
	else
		cd /d    # < ---更改为实际 博客根目录的父目录
		if rm -rf ./blog/.git ./blog/.deploy_git ;then
			echo -e "\033[32m  .git and .deploy_git have deleted ! \033[0m"
			if cp -R ./blog ./blog_backup/ ;then
				echo -e "\033[32m  blog have backuped to blog_backup/ \033[0m"
				deployAfterBackup
			else
				echo -e "\033[31m error: failed to backup blog to blog_backup/ \033[0m"
			fi
		else
			echo -e "\033[31m error: failed to delete .git or .deploy_git file \033[0m"
		fi
	fi
}
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
			read -p "please input commment for commit to remote repository: " commmitComment
			cd /d/blog_backup/  # < ---更改为实际 博客本地备份目录
			git add .
			git commit -m "$commmitComment"
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
localServerAndDeploy
```

</details>

2、将`line3`,`line28`,`line32`和`line58`修改为实际的目录

注意三个目录: `博客部署根目录/d/blog`,`博客本地备份目录/d/blog_backup`和`博客部署根目录的父目录/d/`

`blog`和`blogBackup`建议在同一目录下,且在`/d/`下



3、使用命令行运行

```bash
$ sh DeployAndBackup.sh
```

经历阶段

1)启动hexo server本地预览

按键盘<kbd>Ctrl</kbd><kbd>+</kbd><kbd>C</kbd> 停止hexo server,提示选择

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155630712-1406618615.png" alt="image" style="zoom:50%;" />



2)选择是否部署博客到云端仓库

~~选择`N`则放弃,开始备份本地博客源文件到备份目录~~

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155630712-1406618615.png" alt="image" style="zoom:50%;" />

⚠️此处改进: 当选择`Y`部署博客时才会自动备份到`blog_backup`



3)选择是否推送到GitHub仓库

选择`Y`推送,输入commit注释`test1.1.3`

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155652574-617636456.png" alt="image" style="zoom:50%;" />



4)推送成功,提示绿色信息

选择是否

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155707605-1678685849.png" alt="image" style="zoom:50%;" />

5)查看云端仓库

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155720022-944481610.png" alt="image" style="zoom:50%;" />





---



## 编写过程









###  本地部署

#### 一、测试

shell获取用户输入

1、基本读取

 ```bash
# 1、 -n 参数, 允许用户在提示信息后输入
echo -n "enter your name: "
read name
echo "hello $name ,welcome to my program."

# 2、-p 参数, 允许直接在read命令后指定提示,并接收用户输入 
# 注意: 提示信息结尾的 " 和 接受输入的变量age之间需要空格
read -p "please enter your age: " age
echo "your age is $age"
 ```



▶Test01: 测试 -n 参数

1、新建文件

```bash
root@ubuntu:/home/hadoop/Documents# cat t1.sh 
#!/usr/bin/bash
echo -n "enter your last name: " 
read name
echo "hello $name,welcome to my program."
```

2、执行文件

```bash
root@ubuntu:/home/hadoop/Documents# sh t1.sh 
enter your last name: nathan
hello nathan,welcome to my program.
```



▶Test02: 测试 -p 参数

1、新建文件

```shell
root@ubuntu:/home/hadoop/Documents# cat t2.sh 
#!/usr/bin/bash
read -p "please enter you age: " age 
echo "your age is $age"
```

2、执行程序

```shell
root@ubuntu:/home/hadoop/Documents# sh t2.sh 
please enter you age: 20
your age is 20
```

---



#### 二、Demo





目的: 接受用户输入字符,判断是否部署,根据if else执行不同的语句和提示信息。



▶Demo01: 在bash命令行打印提示信息,接收用户输入,根据输入字符执行不同的语句

```bash
#!/usr/bin/bash
# 1、进入到博客根目录
cd D:/blog/
# 2、部署
read -p "if continue to deploy to the remote repository[Y/N]: " ifDeploy
# 解释参数 $1 是 $ifDeploy表示判断是否执行部署
# 判断选择
# 如果不部署
if [ "$ifDeploy" == "N" ]
then
	echo "thank you ,catch you later!"
# 如果选择部署
elif [ "$ifDeploy" == "Y" ]
then
	# 部署过程... (做异常处理)
	if hexo deploy;then
		echo "deploy to remote successfully!"
	else
		echo "error: can not deploy to the remote!"
	fi
# 如果不是 Y 或者 N 则是 符号输入错误
else
	echo "The content(Y/N) is wrong,please check again!"
fi
```

运行结果:

```bash
Martin@LAPTOP-ANG1G62G MINGW64 ~/Desktop
$ sh blogDeploy1.0.sh
if continue to deploy to the remote repository[Y/N]: N
thank you ,catch you later!
```

▶Demo02: 使用编写的脚本`blogDeploy.sh`部署hexo本地博客到远端github仓库

完整过程

```bash
Martin@LAPTOP-ANG1G62G MINGW64 ~/Desktop
$ sh blogDeploy1.0.sh
if continue to deploy to the remote repository[Y/N]: Y
INFO
  ===================================================================

      #####  #    # ##### ##### ###### #####  ###### #      #   #
      #    # #    #   #     #   #      #    # #      #       # #
      #####  #    #   #     #   #####  #    # #####  #        #
      #    # #    #   #     #   #      #####  #      #        #
      #    # #    #   #     #   #      #   #  #      #        #
      #####   ####    #     #   ###### #    # #      ######   #

                            3.2.0
  ===================================================================
INFO  Deploying: git
INFO  Clearing .deploy_git folder...
INFO  Copying files from public folder...
INFO  Copying files from extend dirs...
[master 17c973d] Site updated: 2021-06-07 13:57:39
 2 files changed, 2 insertions(+), 2 deletions(-)
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 16 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 416 bytes | 416.00 KiB/s, done.
Total 4 (delta 3), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
To xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   669c87d..17c973d  HEAD -> master
Branch 'master' set up to track remote branch 'master' from 
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
INFO  Deploy done: git
INFO  Total precache size is about 9.93 MB for 231 resources.
deploy to remote successfully!

```



🙋‍♂️改进:

给部署成功的提示加上高亮,颜色提示

1. 当部署成功: 则 输出<span style="color:green">绿色高亮提示信息</span>
2. 当部署失败: 则 输出<span style="color:red">红色高亮提示信息</span>

```bash
if hexo deploy;then
		echo -e "\033[33m deploy to remote successfully! \033[0m"
	else
		echo -e "\033[32m error: can not deploy to the remote! \033[0m"
	fi
```

示意图:

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155745658-333957480.png" alt="image" style="zoom:44%;" />



阶段性代码: 完成博客部署

```bash
#!/usr/bin/bash
# 1、进入到博客根目录
cd D:/blog/

# 2、部署
read -p "if continue to deploy to the remote repository[Y/N]: " ifDeploy
# 判断选择
# 如果不部署
if [ "$ifDeploy" == "N" ]
then
	echo "thank you ,catch you later!"
# 如果选择部署
elif [ "$ifDeploy" == "Y" ]
then
	# 部署过程... (做异常处理)
	if hexo deploy;then
		echo -e "\033[32m deploy to remote successfully! \033[0m"
	else
		echo -e "\033[31m error: can not deploy to the remote! \033[0m"
	fi
# 如果不是 Y 或者 N 则是 符号输入错误
else
	echo -e "\033[31m The content(Y/N) is wrong,please check again! \033[0m"      
fi
```



---



注意事项和细节:

1. if else elif 的使用 空格的问题
2. if else使用格式的问题



踩坑:

- xxxxx.sh line 13: if[ == N\]: [command not found](https://segmentfault.com/a/1190000040133891)



相关文章: 

- [linux shell获取用户输入](https://www.cnblogs.com/zqifa/p/linux-shell-1.html)
- [Shell 语法——if else 详解](https://blog.csdn.net/HappyRocking/article/details/90476264)
- [如何在shell中处理异常（Part 1）](https://www.cnblogs.com/clam/archive/2012/12/17/2821684.html)
- [执行shell脚本进入指定目录](https://blog.csdn.net/codigger/article/details/9187989)
- [自定义shell实现hexo常用命令](https://jacean.github.io/2016/03/16/%E8%87%AA%E5%AE%9A%E4%B9%89shell%E5%AE%9E%E7%8E%B0hexo%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4/)
- [Shell入门](http://jacean.github.io/2016/03/16/Shell%E5%85%A5%E9%97%A8/#)



---



---

### 本地备份

目的: 删除blog目录下的`.git`隐藏文件,后复制整个blog目录(包括其下文件,文件夹)到blog目录同目录下的blog_backup目录下,实现备份



假设有如下文件目录树形结构图:

```css
 nathan
        │
        ├───blog
        │     │
        │     ├──.git
        │     │
        │     └──source
        │
        │
        │
        └───blog_backup

```



目的: 先删除blog目录下的 `.git`隐藏文件,然后将整个 blog目录复制到 blog_backup目录下



关于“整个 blog目录复制到 blog_backup目录下”的原理示意:

```bash
# 先创建 blog 和 blog_backup
mkdir blog 
mkdir blog_backup
# 再在blog目录中新建 .git隐藏文件
cd blog
touch .git
# 新建普通目录 source
mkdir source
```

执行脚本后:

```css
           nathan
             │
             ├───blog
             │     │
             │     ├──.git
             │     │
             │     └──source
             │
             │
             │
             └───blog_backup
                         │
                         └──blog
                              │
                              ├──.git
                              │
                              └──source
```

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155832904-311347945.png" alt="image" style="zoom:50%;" />



▶Demo01: 先删除blog目录下的 `.git`隐藏文件,然后将整个 blog目录复制到 `blog_backup`目录下

```bash
#!/usr/bin/bash
# 判断如果 .git文件不存在则提示 "文件不存在" ,加上 红色高亮提示
if [ ! -f "./blog/.git" ];then
	echo -e "\033[31m .git文件不存在 \033[0m" # 红色
else
	# 表示将 当前目录下的 blog/.git删除(仅删除.git) 
    rm -f ./blog/.git 
    echo -e "\033[33m .git文件已经删除 \033[0m" # 黄色
fi
# 复制当前blog目录及下的所有内容到 当前blog_backup目录下 ( # r 和 f不能在一起)
cp -R ./blog ./blog_backup/ 
```

效果图:

<img src="https://img2020.cnblogs.com/blog/1890468/202106/1890468-20210608155846909-914061244.png" alt="image" style="zoom:50%;" />





完成功能:

本地备份

```bash
#!/bin/bash
# 进入到blog/下
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
		else
			echo -e "\033[31m error: failed to backup blog to blog_backup/ \033[0m"
		fi
	else
		echo -e "\033[31m error: failed to delete .git or .deploy_git file \033[0m"
	fi
fi
```





---





相关文章:

- [linux 如何以树形结构显示文件目录结构](https://blog.csdn.net/xuehuafeiwu123/article/details/53817161)
- [linux终端下一次删除多个文件夹](https://blog.csdn.net/weizhen1990/article/details/23625665)
- [linux下拷贝命令中的文件过滤操作记录](https://blog.csdn.net/weixin_34392906/article/details/85845601)
- [if 判断 多个目录/多个文件是否同时存在 _shell](https://www.jianshu.com/p/34a211f600d3)
- [while 语句](https://www.runoob.com/linux/linux-shell-process-control.html)



阶段代码: 本地server预览 + 部署

```bash
#!/usr/bin/bash


# 1、进入到博客根目录
cd D:/blog/

# 2、本地预览server
hexo clean && hexo generate && start  http://localhost:4000 && hexo server

# 3、部署
read -p "if continue to deploy to the remote repository[Y/N]: " ifDeploy
if [ "$ifDeploy" == "N" ]
then
	echo "thank you ,catch you later!"
elif [ "$ifDeploy" == "Y" ]
then
	if hexo deploy;then
		echo -e "\033[32m deploy to remote successfully! \033[0m"
	else
		echo -e "\033[31m error: can not deploy to the remote! \033[0m"
	fi
else
	echo -e "\033[31m The content(Y/N) is wrong,please check again! \033[0m"      
fi

```





---

---



### 函数封装

**相关文章**

- [Shell脚本之八 函数](https://www.cnblogs.com/linuxAndMcu/p/11121918.html)
- [解决hexo deploy时出现的警告：LF will be replaced by CRLF](https://www.jianshu.com/p/783f7736e77e)
- [git push 出现Everything up-to-date 解决方法](https://blog.csdn.net/A_Runner/article/details/79634640)
- [github报错：The file will have its original line endings in your working directory](https://blog.csdn.net/qq_37521610/article/details/88327286)
- [git如何避免”warning: LF will be replaced by CRLF“提示？ - 知乎](https://www.zhihu.com/question/50862500) 
- [python困惑：unix(LF)和windows(CR LF)](https://blog.csdn.net/duanlianvip/article/details/79324997)
- [反转布尔变量](https://qastack.cn/unix/24500/invert-boolean-variable)
- [布尔运算](https://www.kancloud.cn/kancloud/shellbook/68982)
- [git 连接远程仓库方法](https://blog.csdn.net/u013372487/article/details/52925960)

- [Linux shell编程之循环控制命令 break、continue](https://blog.csdn.net/guoyajie1990/article/details/54645135)



---



#### 有注释



```bash
#!/usr/bin/bash
# 函数1: 实现本地server预览和部署
localServerAndDeploy(){
	# 1、进入到博客根目录
	cd D:/blog/  # < ---更改为实际 博客根目录
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
	cd D:/blog/   # < ---更改为实际 博客根目录
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
			cd /d/blog_backup/  # < ---更改为实际 博客本地备份目录
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
```



#### 无注释

```bash
#!/usr/bin/bash
localServerAndDeploy(){
	cd D:/blog/  # < ---更改为实际 博客根目录
	hexo clean && hexo generate && start  http://localhost:4000 && hexo server
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
localBlogBackup(){
	cd D:/blog/   # < ---更改为实际 博客根目录
	if [ ! -f "./blog/.git" -a -f "./blog/.deploy_git" ];then
		echo -e "\033[31m file .git or .deploy_git not exists \033[0m"
	else
		cd /d    # < ---更改为实际 博客根目录的父目录
		if rm -rf ./blog/.git ./blog/.deploy_git ;then
			echo -e "\033[32m  .git and .deploy_git have deleted ! \033[0m"
			if cp -R ./blog ./blog_backup/ ;then
				echo -e "\033[32m  blog have backuped to blog_backup/ \033[0m"
				deployAfterBackup
			else
				echo -e "\033[31m error: failed to backup blog to blog_backup/ \033[0m"
			fi
		else
			echo -e "\033[31m error: failed to delete .git or .deploy_git file \033[0m"
		fi
	fi
}
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
			read -p "please input commment for commit to remote repository: " commmitComment
			cd /d/blog_backup/  # < ---更改为实际 博客本地备份目录
			git add .
			git commit -m "$commmitComment"
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
localServerAndDeploy
```