package potato.utils
{
	import core.system.System;
	public class DataEyeUtil
	{
		/**
		 * 数据眼统计  
		 * 必须先调 dataEyestartWithAppkey 方法
		 * 
		 */		
		public function DataEyeUtil()
		{
		}
		/**
		 *    初始化数据眼
		 * @param appKey       数据眼appKey.
		 * @param channelName  渠道名称.
		 * 
		 */		
		public static function dataEyestartWithAppkey(appKey:String,channelName:String):void{
			System.nativeCall("DataEyestartWithAppkey", [appKey,channelName]);
		}
		/**
		 * 获得设备id
		 * @return 设备id
		 * 
		 */		
		public static function dataEyeGetDeviceId():String{
			return System.nativeCall("DataEyeGetDeviceId", []);
		}
		/**
		 * 设置帐号(必须调用，上报系统信赖accountId进行数据分析,帐号id，必须分配且唯一。如果无注册系统，可以使用设备绑定的id)
		 * @param userId  账户id
		 * 
		 */		
		public static function dataEyelogin(userId:String):void{
			System.nativeCall("DataEyelogin", [userId])
		}
		/**
		 * 登出账户
		 * 
		 */		
		public static function dataEyelogout():void{
			System.nativeCall("DataEyelogout", [])
		}
		/**
		 *   标记玩家属于哪一类玩家，即给玩家加玩家类型标记，如：任务党、成就党、聊天党等
		 * @param id   玩家标识
		 * 
		 */		
		public static function dataEyetag(id:String):void{
			System.nativeCall("DataEyetag", [id])
		}
		/**
		 * 将一种玩家标记从玩家身上去除
		 * @param id   玩家标识玩家标识
		 * 
		 */		
		public static function dataEyeunTag(id:String):void{
			System.nativeCall("DataEyeunTag", [id])
		}
		/**
		 * 设置帐号类型
		 * @param type 账户类型    
		 *  0 =  匿名帐户
		 *  1 =  显性注册帐户
		 *  2 =  新浪微博
		 *  3 =  QQ帐户
		 *  4 =  腾讯微博
		 *  5 =  91帐户
		 *  11 =预留1
		 *  12 =预留2
		 *  13 =预留3
		 *  14 =预留4
		 */		
		public static function dataEyeSetAccountType(type:int):void{
			System.nativeCall("DataEyeSetAccountType", [type])
		}
		/**
		 * 设置帐号等级(用户升级后务必调用)
		 * @param level   等级
		 * 
		 */		
		public static function dataEyeSetLevel(level:int):void{
			System.nativeCall("DataEyeSetLevel", [level])
		}
		/**
		 * 设置性别
		 * @param type   0：未知   1：男  2：女
		 * 
		 */		
		public static function dataEyeSetGender(type:int):void{
			System.nativeCall("DataEyeSetGender", [type])
		}
		/**
		 * 设置年龄
		 * @param num  年龄
		 * 
		 */		
		public static function dataEyeSetAge(num:int):void{
			System.nativeCall("DataEyeSetAge", [num])
		}
		/**
		 * 设置区服
		 * @param id  区服
		 * 
		 */		
		public static function dataEyeGameServer(id:String):void{
			System.nativeCall("DataEyeGameServer", [id])
		}
		/**
		 * 虚拟币充值
		 * @param ordersId      订单id最多32个字符
		 * @param packsId       礼包ID
		 * @param num           现金金额
		 * @param currency      币种     需要使用ISO4217中规范的3字母代码，如美元USD、人民币CNY等
		 * @param payType       支付类型    最多16个字符
		 * 
		 */		
		public static function dataEyeonCharge(ordersId:String,packsId:String,num:Number,currency:String,payType:String):void{
			System.nativeCall("DataEyeonCharge", [ordersId,packsId,num,currency,payType])
		}
		/**
		 * 虚拟币充值成功
		 * @param orders 订单号
		 * 
		 */		
		public static function dataEyeonChargeSuccess(orders:String):void{
			System.nativeCall("DataEyeonChargeSuccess", [orders])
		}
		/**
		 * 虚拟币充值请求，用于只能发起充值请求，无法获取充值完成详情的情形
		 * @param num        现金金额
		 * @param currency   币种       需要使用ISO4217中规范的3字母代码，如美元USD、人民币CNY等
		 * @param payType    支付类型    最多16个字符
		 * 
		 */		
		public static function dataEyeonChargeOnlySuccess(num:Number,currency:String,payType:String):void{
			System.nativeCall("DataEyeonChargeOnlySuccess", [num,currency,payType])
		}
		/**
		 * 设置虚拟币数量
		 * @param num  虚拟币数量
		 * 
		 */		
		public static function dataEyesetCoinNum(num:int):void{
			System.nativeCall("DataEyesetCoinNum", [num])
		}
		/**
		 * 玩家失去虚拟币
		 * @param type    失去虚拟币原因，后台以该参数作为统计ID
		 * @param lose    失去虚拟币数量
		 * @param remain  剩余虚拟币总量
		 * 
		 */		
		public static function dataEyelostCoin(type:String,lose:int,remain:int):void{
			System.nativeCall("DataEyelostCoin", [type,lose,remain]);
		}
		/**
		 * 玩家获得虚拟币
		 * @param type   获得虚拟币原因，后台以该参数作为统计ID
		 * @param lose   失去虚拟币数量
		 * @param remain 剩余虚拟币总量
		 * 
		 */		
		public static function dataEyegainCoin(type:String,lose:int,remain:int):void{
			System.nativeCall("DataEyegainCoin", [type,lose,remain]);
		}
		/**
		 * 一项监控
		 * @param name    监控名称 最大32个字符
		 * @param isType  此次调用是否成功 1:成功;0:不成功
		 * @param time    花费时长，以秒为单位
		 * 
		 */		
		public static function dataEyeonMonitor(name:String,isType:int,time:int):void{
			System.nativeCall("DataEyeonMonitor", [name,isType,time]);
		}
		/**
		 * 获取String类型参数
		 * @param key   用户事先配置好的 key-value 键值对
		 * @param value 键 key 对应的默认值 value,接口获取 Key 对应的值不成功时会返回该 value
		 * @return 
		 * 
		 */		
		public static function dataEyegetConfigParams(key:String,value:String):String{
			return System.nativeCall("DataEyegetConfigParams", [key,value]);
		}
		
		/**
		 * 棋牌游戏专项统计   1
		 * @param roomName  玩家玩游戏所在的房间 ID
		 * @param record    完成一局游戏时可能需要记录的属性值
		 * @param num       获得或者丢失的虚拟币数量,大于 0 表示赢得虚拟币数量,小于 0 表示失去的虚拟币数量。
		 * @param endNum    完成游戏后系统回收的虚拟币数量,可以为 0
		 * @param loseNum   系统结算后,玩家剩余的虚拟币总量
		 * 
		 */		
		public static function dataEyeCardsplay(roomName:String,record:String,num:int,endNum:int,loseNum:int):void{
			System.nativeCall("DataEyeCardsplay", []);
		}
		
		/**
		 * 棋牌游戏专项统计 2
		 * @param roomName       玩家玩游戏所在的房间 ID
		 * @param consumption    玩家消耗虚拟币的原因
		 * @param consumptionNmu 消耗虚拟币的数量
		 * @param loseNum        系统结算后,玩家剩余的虚拟币总量
		 * 
		 */		
		public static function dataEyeCardslostCoin(roomName:String,consumption:String,consumptionNmu:int,loseNum:int):void{
			System.nativeCall("DataEyeCardslostCoin", []);
		}
		/**
		 * 棋牌游戏专项统计 3
		 * @param roomName       玩家玩游戏所在的房间 ID
		 * @param obtain         玩家获得虚拟币的原因
		 * @param obtainNum      获得虚拟币的数量
		 * @param loseNum        系统结算后,玩家剩余的虚拟币总量
		 * 
		 */		
		public static function dataEyeCardsgainCoin(roomName:String,obtain:String,obtainNum:int,loseNum:int):void{
			System.nativeCall("DataEyeCardsgainCoin", []);
		}
		/**
		 * 
		 * @param evnet   事件id
		 * 
		 */		
		public static function dataEyeonEventCount(evnet:String,count:int=0):void{
			System.nativeCall("DataEyeonEventCount", [evnet,count]);
		}
		/**
		 * 
		 * @param event  事件id
		 * 
		 */		
		public static function dataEyeonEvent(event:String):void{
			System.nativeCall("DataEyeonEvent", [event]);
		}
		/**
		 * 
		 * @param event   事件ID
		 * @param label   分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * 
		 */		
		public static function dataEyeonEventlabel(event:String,label:String):void{
			System.nativeCall("DataEyeonEventlabel", [event,label]);
		}
		/**
		 * 
		 * @param event   事件ID
		 * @param num     累加值。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数。
		 * 
		 */		
		public static function dataEyeonEventDuration(event:String,num:int):void{
			System.nativeCall("DataEyeonEventDuration", [event,num]);
		}
		/**
		 * 
		 * @param event   事件ID
		 * @param label   分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比
		 * @param num     累加值。为减少网络交互，可以自行对某一事件ID的某一分类标签进行累加，再传入次数作为参数。
		 * 
		 */		
		public static function dataEyeonEventlabelDuration(event:String,label:String,num:int):void{
			System.nativeCall("DataEyeonEventlabelDuration", [event,label,label]);
		}
		/**
		 * 
		 * @param event   事件ID
		 * 要和    dataEyeonEventEnd  配对使用
		 */		
		public static function dataEyeonEventBegin(event:String):void{
			System.nativeCall("DataEyeonEventBegin", [event]);
		}
		/**
		 * 
		 * @param event   事件ID
		 * 要和    dataEyeonEventBegin  配对使用
		 */		
		public static function dataEyeonEventEnd(event:String):void{
			System.nativeCall("DataEyeonEventEnd", [event]);
		}
		
	}
}