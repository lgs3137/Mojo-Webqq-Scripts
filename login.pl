#!/usr/bin/perl

use Mojo::Webqq;

#注意:
#程序内部数据全部使用UTF8编码，因此二次开发源代码也请尽量使用UTF8编码进行编写，否则需要自己做编码处理
#在终端上执行程序，会自动检查终端的编码进行转换，以防止乱码
#如果在某些IDE的控制台中查看执行结果，程序无法自动检测输出编码，可能会出现乱码，可以手动设置输出
#手动设置输出编码参考文档中关于 log_encoding 的说明

#帐号可能进入保护模式的原因:
#多次发言中包含网址
#短时间内多次发言中包含敏感词汇
#短时间多次发送相同内容
#频繁异地登陆

#推荐手机安装[QQ安全中心]APP，方便随时掌握自己帐号的情况

my $qq = 284759461;

#初始化一个客户端对象，设置登录的qq号

my $client=Mojo::Webqq->new(
ua_debug    =>  0,         #是否打印详细的debug信息
log_level   => "info",     #日志打印级别
qq          =>  $qq,       #登录的qq帐号
login_type  =>  "qrlogin", #"qrlogin"表示二维码登录
);

#注意: 腾讯可能已经关闭了帐号密码的登录方式，这种情况下只能使用二维码扫描登录

#发送二维码到邮箱
#$client->load("PostQRcode",data=>{
#smtp    =>  'smtp.xxx.com', #邮箱的smtp地址
#port    =>  '25', #smtp服务器端口，默认25
#from    =>  'xxx@xxx.com', #发件人
#to      =>  'xxx@xxx.com', #收件人
#user    =>  'xxxxxxxxx', #smtp登录帐号
#pass    =>  'xxxxxxxxx', #smtp登录密码
#});

#发送验证码到邮箱
#$client->load("PostImgVerifycode",data=>{
#smtp    =>  'smtp.xxx.com', #邮箱的smtp地址
#port    =>  '25', #smtp服务器端口，默认25
#from    =>  'xxx@xxx.com', #发件人
#to      =>  'xxx@xxx.com', #收件人
#user    =>  'xxxxxxxxx', #smtp登录帐号
#pass    =>  'xxxxxxxxx', #smtp登录密码
#post_host => '127.0.0.1' , #本机公网IP地址，需要远程访问
#post_port => '1987'            , #提交验证码的链接地址中使用的端口，默认1987
#});

#客户端进行登录
$client->login();

#客户端加载ShowMsg插件，用于打印发送和接收的消息到终端
$client->load("ShowMsg");

#主要用于主动更新好友、群、讨论组数据库，或者用于测试
$client->on(receive_message=>sub{
my $msg = $_[1];
  $client->relogin() if $msg->content eq "relogin";
  $client->_relink() if $msg->content eq "_relink";
  $client->relink() if $msg->content eq "relink";
  $client->update_user() if $msg->content eq "update_user";
  $client->update_group() if $msg->content eq "update_group";
  $client->update_group_ext() if $msg->content eq "update_group_ext";
  $client->update_friend() if $msg->content eq "update_friend";
  $client->update_friend_ext() if $msg->content eq "update_friend_ext";
  $client->update_discuss() if $msg->content eq "update_discuss";
});

#显示perl文档
#$client->load("Perlcode");
#示例 perldoc -f|-v xxx

#执行perl命令
#$client->load("Perldoc");
#示例 >>> print "hello world";

#加载群管理
#$client->load("GroupManage");
#默认包含新人入群欢迎、成员离开提醒、群成员改名通知、限制发言频率、限制发图频率
#其中加群欢迎 离群告别 群名片提醒 这些是没办法开关的
#发送频率限制之类的 默认是不开启的 需要自己设置限制频率之类的
#具体请参考代码以及以下链接
#http://search.cpan.org/dist/Mojo-Webqq/doc/Webqq.pod#Mojo::Webqq::Plugin::GroupManage

#smartQQ
$client->load("SmartReply");
#需要私聊或@机器人

#对大神进行鄙视
$client->load("FuckDaShen");

#创建知识库
$client->load("KnowledgeBase");
#示例：learn 今天天气怎么样  天气很好
#      学习  "你吃了吗"      当然吃了
#      learn '哈哈 你真笨'   "就你聪明"
#      del   今天天气怎么样
#       删除  '哈哈 你真笨'

#翻译
$client->load("Translation");
#示例：翻译 hello

#手机归属地查询
$client->load("MobileInfo");
#示例：手机 1888888888

#代码测试
$client->load("ProgramCode");
#示例：code|c>>>
#        #include <stdio.h>
#        int main() {
#            printf("Hello World!\n");
#            return 0;
#        }

#股票查询
$client->load("StockInfo");
#示例：股票 000001


#提供HTTP API接口，方便获取客户端帐号、好友、群、讨论组信息，以及通过接口发送和接收好友消息、群消息、群临时消息和讨论组临时消息
$client->load("Openqq",data=>{
listen => [ {host=>"127.0.0.1",port=>5011}, ] , #监听的地址和端口，支持多个
#auth   => sub {my($param,$controller) = @_},    #可选，认证回调函数，用于进行请求鉴权
#post_api => 'http://xxxx',                      #可选，设置接收消息的上报接口
});

#开启本地irc server
#需要先安装Mojo::IRC::Server::Chinese
$client->load("IRCShell",data=>{
  host=>"127.0.0.1", #默认0.0.0.0
  port=>6667, #默认6667
#master_irc_user     #和qq匹配的irc user帐号，默认按照和qq号相同的user或者客户端ip是本机地址作为识别规则
#load_friend         #0|1 默认是1 是否初始为每个好友生成irc虚拟帐号并加入频道 #我的好友
#image_api           #兼容elimage图床api地址，将qq图片转为连接，方便在irc上查看图片，默认没有启用
                    #推荐依云的elimage http://img.vim-cn.com/
});

#客户端开始运行
$client->run();