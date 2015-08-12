#!/usr/bin/env python
import os

DumpsysDir="autotest"
OutputFileName="dumpsys.cvs"

resultFile=open(OutputFileName,"w")
mainCount=0
NativeHeapIndex=7

def getDataFile(count):
	dataFile = "%s/mem%d"%(DumpsysDir,count)
	return open(dataFile,"r")

resultFile.write("round\t%s\t%s\t%s\t%s\t%s\n" %("native heap","Dalvik Heap","Dalvik other","Unknow","total"))

fileInFd = getDataFile(mainCount)
while fileInFd:
	index=0
	while index<NativeHeapIndex:
		line=fileInFd.readline()
		index+=1
	
	line=fileInFd.readline()
	#print(line)
	#print(line.split()[2])
	resultFile.write("%d\t%s\t"%(mainCount,line.split()[2]))
	line=fileInFd.readline()
	resultFile.write("%s\t"%(line.split()[2]))
	line=fileInFd.readline()
	resultFile.write("%s\t"%(line.split()[2]))
	
	while not "Unknown" in line:
		line=fileInFd.readline()
	
	print(line)
	resultFile.write("%s\t"%(line.split()[1]))
	line=fileInFd.readline()
	#print(line)
	resultFile.write("%s\n"%(line.split()[1]))
	fileInFd.close()

	mainCount+=5
	fileInFd = getDataFile(mainCount)

resultFile.close()
