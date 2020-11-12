#ifndef _WSCLIENTNET_NETLUAFUNC_H_
#define _WSCLIENTNET_NETLUAFUNC_H_

#include "cocos2d.h"
USING_NS_CC;

class DBuf;
class NetLuaFunc : public Ref
{
public:
	NetLuaFunc(){};
	~NetLuaFunc(){};
	bool init(){ return true; };
	CREATE_FUNC(NetLuaFunc);
	
public:
	// lua 调用 C++
	unsigned char readRecvByte();
	short readRecvShort();
	int readRecvInt();
	unsigned int readRecvUint32();
	double readRecvDouble();
	std::string readRecvString();
	bool writeSendByte(unsigned char byValue);
	bool writeSendShort(short shtValue);
	bool writeSendInt(int nValue);
	bool writeSendUint32(unsigned int unValue);
	bool writeSendDouble(double dblValue);
	bool writeSendString(std::string strValue);
	void beginSendBuf(unsigned int unMsgId);
	void endSendBuf();
	void sendSvrBuf(std::string strFarAddr, unsigned int uPort,bool bDirect);
	void downloadFile(const char* url, const char* path, bool bFile);
	std::string getOutFile();
	std::string getStrRet();
};

#endif