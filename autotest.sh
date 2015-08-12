RUN_HOST=true
WORK_PATH=""
OP_LOG_FILE_NAME="op.log"
function opLog()
{
	#arg1 is string to log
	timeStr=`date +"%Y-%m-%d %H:%M:%S"`
	echo "$timeStr:$1">>"$WORK_PATH/$OP_LOG_FILE_NAME"
}
function runCmd()
{
	cmd=""
	adb="adb shell "
	if  $RUN_HOST;
	then
		cmd="$adb $1"
	else
		cmd="$1"
	fi
	echo $cmd
	eval $cmd

}
function dumpMem()
{
	#arg1 stand for round count
	#arg2 stand for pid or process name
	opLog "get mem usage count:$1"
	runCmd "dumpsys meminfo $2 > $WORK_PATH/mem$1"
	#runCmd "procrank > $WORK_PATH/procrank$1"
	#runCmd "am dumpheap $2 >$WORK_PATH/$1.hprof"
	#deviceHprofPath="/sdcard/hprof"
	#adb shell "mkdir $deviceHprofPath"
	#adb shell "am dumpheap $2 $deviceHprofPath/$1.hprof"
	#sleep 0.5
	#adb pull "$deviceHprofPath/$1.hprof" "$WORK_PATH"
}
function getLog()
{
#arg1 get log reason
	timeStr=`date +"%Y%m%d-%H%M%S"`
	logPath="$WORK_PATH/$timeStr"
	if [ -n "$1" ]
	then
		logPath="$logPath-$1"
	fi
	mkdir -p "$logPath"
	runCmd "logcat -v threadtime -d > $logPath/logcat"
}
function startAct()
{
	#arg1 is the activity name to start
	runCmd "am start -W -n $1"
	opLog "start activity:$1"
}
function getCurAct(){
	cur=`runCmd "dumpsys window windows|grep mCurrentFocus"`
	cur=${cur##* u0 }
	cur=${cur%%??}
	echo  $cur
}
function isCurAct(){
	#check is arg1 is the current activity
	curAct=`getCurAct`
	if [ "$curAct" = "$1" ];
	then
		echo "equal"
		return 0
	fi
	#wait 0.3S retry
	sleep 0.3
	curAct=`getCurAct`
	if [ $curAct = $1 ];
	then
		echo "retry equal"
		return 0
	fi
	echo "not equal"
	return -1
}
function tap()
{
	#arg1 x 
	#arg2 y
	runCmd "input tap $1 $2"
	opLog "tap $1 $2"
}
function backKey()
{
	runCmd "input keyevent 4"
	opLog "back key pressed"
}
function homeKey()
{
	runCmd "input keyevent 3"
	opLog "home key pressed"
}
function init()
{
	if $RUN_HOST
	then
		WORK_PATH="$(pwd)/autotest"
	else
		WORK_PATH="/sdcard/autotest"
	fi
	rm -rf "$WORK_PATH"
	mkdir -p "$WORK_PATH"
	#adb shell rm -rf "/sdcard/hprof"
	opLog "init"
	homeKey
}
function mainLoop()
{
	act="com.tencent.tmsecure.demo/com.tencent.tmsecure.demo.DemoMainActivity"
	act2="com.tencent.tmsecure.demo/com.tencent.tmsecure.demo.deepclean.DeepcleanActivity"
	processName="com.tencent.tmsecure.demo"
	startAct $act
	count=10001  #loop times
	opLog "main loop"
	for (( i=0;i<count;++i ))
	do
		opLog "test round:$i"
		echo  "test round:$i"
		if ! isCurAct $act
		then
			errStr=`getCurAct`
			opLog "test exception:expact act $act,but current is:$errStr"
			exit -1
		fi
		#G620 tap 547 781
		#tap 821 1390 #nexus6
		#tap 320 795 #64 huawei
		tap 365 305
		if ! isCurAct $act2
		then
			errStr=`getCurAct`
			opLog "test exception:expact act $act2,but current is:$errStr"
			exit -1
		fi
		if [[ $((i%5)) -eq 0 ]]
		then
			dumpMem $i $processName
		fi
		backKey
	done
}
#main begin
echo "test begin"
init
mainLoop
echo "test end"
#main end
