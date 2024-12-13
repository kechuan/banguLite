# banguLite







![Platform](https://img.shields.io/badge/support%20platform-android%7Cwindow-green)



### 功能展示



#### 简约的bangumi信息浏览。

![image-20240918094319382](./images/mainPage_desktop.png)



#### 番剧界面详情

![image-20240918100342635](./images/detailPage_desktop.png)



#### 吐槽评论界面

![](./images/commentViewPage_desktop.png)



搜索&筛选

![image-20240918102318110](./images/search.png)



![image-20240918102704952](./images/fliter.png)



****





### 移动端界面适配



![image-20240918102838048](./images/mainPage_mobile.png)



![image-20240918103553584](./images/fliter_mobile.png)





![image-20240918103651425](./images/commentViewPage_mobile.png)



****





## TODO



待更新内容:



#### [enchantment]

- [x] 本地收藏功能(Hive存储) - 本地订阅页面
- [x] gridView切换
- [x] 关联浏览器应用打开原始 番剧/评论 网页
- [x] 单集详情(ep内容)
- [x] 表情符号转义

- [ ] 增加Android端的通知(预定为收藏之后每次到更新日期会弹一个通知)

#### [UI]

- [x] 番剧详情页面提取番剧主题色作为背景渐变 

  原版的Theme里ImageProvider提取色非常的难用。。 但确实至少是做出来了。
  
- [ ] 预计会重新构建一次番剧Info的组件内容 目标在于评分的信息量



#### [状况通知]

- [ ] 网络检测与对应的组件行为
  - 侦测断网时 直接不予加载 除非网络检测重新更新为网络正常
- [ ] 移动端通知(因为桌面端没人会一直挂着app 这只能是适用移动端的行为)
