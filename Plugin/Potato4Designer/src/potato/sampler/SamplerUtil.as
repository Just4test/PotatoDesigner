/**
 * Created with IntelliJ IDEA.
 * User: ShockMana Jiang
 * Date: 13-3-18
 * Time: 下午8:17
 * To change this template use File | Settings | File Templates.
 */
package potato.sampler
{
	import core.system.System;
	
	import flash.sampler.DeleteObjectSample;
	import flash.sampler.NewObjectSample;
	import flash.sampler.Sample;
	import flash.sampler.StackFrame;
	import flash.sampler.clearSamples;
	import flash.sampler.getSamples;
	import flash.utils.Dictionary;
	
	import potato.logger.Logger;
	
	/**
	 * 系统采样分析的工具方法类
	 */
	public class SamplerUtil
	{
		public static function output(log:Logger, level:int = 5):void
		{
			System.gc();
			
			var cpuCount:int;
			var newCount:int, newSize:int;
			var delCount:int, delSize:int;
			var nos:NewObjectSample, dos:DeleteObjectSample;
			
			var callDic:Object = {};
			var timeDic:Object = {};
			var newDic:Dictionary = new Dictionary();
			var clzDic:Dictionary = new Dictionary();			// 对象类型字典，Key: Class  Value: instance count
			var sizDic:Dictionary = new Dictionary();			// 对象在内存中所占内存总数
			var clzSizeDic:Dictionary = new Dictionary();		// Key: Class  Value: unreleased memory
			var id:*;
			var type:Class;
			var stackFrame:StackFrame;
			var call:String;
			var count:int;
			var time:Date;
			
			for each (var sam:Sample in getSamples())
			{
				//			stackFrame = sam.stack ? sam.stack[sam.stack.length - 1] : null;
				//			call = stackFrame ? stackFrame.name + stackFrame.scriptID : null;
				call =  sam.stack ? sam.stack.map(mapStackFramesName).reverse().join(' >>> ') : null;
				
				if (call)
				{
					if (!callDic[call])
					{
						callDic[call] = 1;
						time = new Date();
						time.time = sam.time;
						timeDic[call] = time;
					}
					else
					{
						callDic[call] ++;
						//					timeDic[call] += sam.time;
					}
				}
				
				nos = sam as NewObjectSample;
				if (nos)
				{
					newCount ++;
					newSize += nos.size;
					
					if (!newDic[nos.id])
					{
						newDic[nos.id] = 1;
						clzDic[nos.id] = nos.type;
						sizDic[nos.id] = nos.size;
					}
					else
					{
						newDic[nos.id] ++;
						sizDic[nos.id] += nos.size;
					}
					
					//				if (!sizDic[nos.type])
					//				{
					//					sizDic[nos.type] = nos.size;
					//				}
					//				else
					//				{
					//					sizDic[nos.type] += nos.size;
					//				}
					
					continue;
				}
				
				dos = sam as DeleteObjectSample;
				if (dos)
				{
					delCount ++;
					delSize += dos.size;
					
					if (newDic[dos.id])
					{
						newDic[dos.id] --;
						sizDic[dos.id] -= dos.size;
					}
					
					//				type = clzDic[dos.id];
					//				if (type && sizDic[type])
					//				{
					//					sizDic[type] -= dos.size;
					//				}
					
					continue;
				}
				
				cpuCount ++;
			}
			
			clearSamples();
			
			var result:Array = [
				'-----==========-----',
				'创建对象数：\t' + newCount,
				'创建内存：\t' + (newSize >> 10) + ' k',
				'删除对象数：\t' + delCount,
				'删除内存：\t' + (delSize >> 10) + ' k',
				'CPU 采样数：\t' + cpuCount,
				'-----==========-----'
			];
			
			result.push('--------------------');
			
			var objDic:Dictionary = new Dictionary();
			
			for (id in newDic)
			{
				type = clzDic[id];
				if (type)
					if (!objDic[type])
					{
						objDic[type] = newDic[id];
						clzSizeDic[type] = sizDic[id];
					}
					else
					{
						objDic[type] += newDic[id];
						clzSizeDic[type] += sizDic[id];
					}
			}
			
			for (id in objDic)
			{
				result.push(id + '\t' + objDic[id] + '\t' + (clzSizeDic[id] >> 10) + ' k');
			}
			
			result.push('====================');
			
			for (call in callDic)
			{
				result.push(call + '\t' + callDic[call] + '\t' + timeDic[call]);
			}
			
			log.debug(result.join('\n'));
		}
		
		private static function mapStackFramesName(element:StackFrame, index:int, array:Array):String
		{
			return element.name;
		}
	}
}
