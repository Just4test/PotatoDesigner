avm
	AVM运行环境
	
FlashBuilder WorkSpace Guest
	客户端的FlashBuilder工作空间
	
FlashBuilder WorkSpace Host
	主机端的FlashBuilder工作空间
	
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
	额外打包参数：
	-include-libraries "../../Framwork Guest\bin\Framwork Guest.swc"
	
PotatoDesigner Host
	主机端主应用程序
	额外打包参数：
	-include-libraries "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\frameworks\libs\spark.swc"
	-include-libraries "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\frameworks\libs\air\airspark.swc"
	-include-libraries "C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\frameworks\libs\sparkskins.swc"
	-include-libraries "../../Framwork Host\bin\Framework Host.swc"
	需要显式引用Air框架，是因为运行时动态载入了需要这些框架的插件。
	即使显式引用了框架，在插件中添加了新MXML组件时，仍然可能报找不到皮肤/风格错误。
	此时需要手动指定风格。
	需要以“合并到代码中”方式引用Windows插件。
	
WorkSpace Guest
	客户端工作空间
	
WorkSpace Host
	主机端工作空间
	
公共编译器参数：
	-locale en_US
	-define=CONFIG::DEBUG,false
	视情况开关debug。
	
主机端编译器参数：
	-define=CONFIG::HOST,true
	-define=CONFIG::GUEST,false
	
客户端编译器参数：
	-define=CONFIG::HOST,false
	-define=CONFIG::GUEST,true
	
主机端库项目必须引用share目录作为源路径（如果有）
客户端库项目需要引用对应的主机端库项目的share目录（如果有）

所有插件项目如果引用其他插件或框架，必须以“外部”方式引用。