avm
	AVM运行环境
	
FlashBuilder WorkSpace Guest
	客户端的FlashBuilder工作空间
	
FlashBuilder WorkSpace Host
	主机端的FlashBuilder工作空间
	-locale en_US
	-include-libraries "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\frameworks\libs\spark.swc"
	-include-libraries "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\frameworks\libs\air\airspark.swc"
	-include-libraries "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\frameworks\libs\sparkskins.swc"
	-include-libraries "../../Framwork Host\bin\Framework Host.swc"
	
Framwork Guest
	客户端框架
	
Framwork Host
	主机端框架
	-locale en_US
	-define=CONFIG::HOST,true
	-define=CONFIG::GUEST,false
	-define=CONFIG::DEBUG,false
	
Plugin Bootloader Guest
	启动引导器客户端插件
	
Plugin Bootloader PotatoOverride
	启动引导器Potato覆盖类
	
Plugin GuestManager Guest
	客户端管理器客户端插件
	
Plugin GuestManager Host
	客户端管理器主机端插件
	
Plugin UIDesigner Guest
	UI设计工具客户端插件
	
Plugin UIDesigner Host
	UI设计工具主机端插件
	
Plugin Window
	窗口创建插件（仅主机端）
	
Potato4Designer
	客户端用Potato类库
	
PotatoDesigner Guest
	客户端主应用程序
	
PotatoDesigner Host
	主机端主应用程序
	
WorkSpace Guest
	客户端工作空间
	
WorkSpace Host
	主机端工作空间