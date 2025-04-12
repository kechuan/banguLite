# banguLite

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b5d3920ab1d04d3baaca63ce5a8ea09a)](https://app.codacy.com/gh/kechuan/banguLite?utm_source=github.com&utm_medium=referral&utm_content=kechuan/banguLite&utm_campaign=Badge_Grade)



*banguLite —— Lite to surf bangumi*



![Platform](https://img.shields.io/badge/support%20platform-android%7Cwindow-green)



透过Flutter编写，由MD风格打造的简约bangumi信息浏览客户端。



****



目前功能如下:



- [x] 番剧页面展示
  - [x] 番剧进度
  - [x] 查看分数投票分布
  - [x] 相关条目
  - [x] 用户的日志查看
  - [x] 讨论板
- [x] 浏览单个番剧的吐槽
  - [x] 浏览番剧中的单集内的吐槽
  - [x] bbcode与表情包贴纸适配
- [x] 搜索/筛选条件找番

- [x] 黑暗模式

- [x] 本地收藏

- [x] 应用内检查更新



目前支持Android 与 windows 双端，

在项目release处下载。

> 如果不知道Android端要哪一个就选 arm64 的那个



:heart:  ? :star: : null;



****

### 功能展示



![image-20240918094319382](./images/mainPage_desktop.png)



#### 番剧界面详情

![image-20240918100342635](./images/detailPage_desktop.png)



#### 吐槽评论界面

![](./images/commentViewPage_desktop.png)



**搜索&筛选**

![image-20240918102318110](./images/search.png)



![image-20240918102704952](./images/fliter.png)



**订阅界面**

![](./images/star_mobile.png)





****





### 移动端界面适配



![image-20240918102838048](./images/mainPage_mobile.png)



![image-20240918103553584](./images/fliter_mobile.png)





![image-20240918103651425](./images/commentViewPage_mobile.png)



**黑暗模式**



![](./images/dark_detail_mobile.png)



****



## TODO



#### [enchantment]

- [ ] [Low-level] 基础的国际化

#### [**feature**]



- 其他板块区域(除 **人物信息** 以及 **杂项信息**)

- 账号系统


​	因为如果要引入账号 就意味着要额外引入极多的输入性交互，个人信息管理。

​	以及好友等等的问题 尚不清楚那之后还能不能保持"Lite"之名。

​	目前个人认为最多先把平常web端不登录能访问到什么数据 这里就有什么数据的地步

#### [UI]



设置页

- ~~主题色调切换~~



受限于API暂无法完成的部分

- ~~贴纸表情reaction(已完成)~~
- ~~用户的动态关联到某个番剧处理(已完成)~~
