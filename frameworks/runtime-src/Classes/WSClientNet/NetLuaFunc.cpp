#include "DBuf.h"
#include "DNetScheduler.h"
#include "DNetMsgBase.h"
#include "NetLuaFunc.h"

unsigned char NetLuaFunc::readRecvByte()
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	unsigned char n = 0;
	p->ReadByte(n);
	return n;
}

short NetLuaFunc::readRecvShort()
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	short n = 0;
	p->ReadShort(n);
	return n;
}

int NetLuaFunc::readRecvInt()
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	int n = 0;
	p->ReadInteger(n);
	return n;
}

unsigned int NetLuaFunc::readRecvUint32()
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	unsigned int n = 0;
	p->ReadUint32(n);
	return n;
}

double NetLuaFunc::readRecvDouble()
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	double n = 0;
	p->ReadDouble(n);
	return n;
}

std::string NetLuaFunc::readRecvString()
{
	DBuf* p = DNetScheduler::Instance()->GetRecvDBuf();
	std::string s = "";
	p->ReadString(s);

	return s;
}

bool NetLuaFunc::writeSendByte(unsigned char byValue)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	return (p->WriteByte(byValue));
}

bool NetLuaFunc::writeSendShort(short shtValue)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	return (p->WriteShort(shtValue));
}

bool NetLuaFunc::writeSendInt(int nValue)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	return (p->WriteInteger(nValue));
}

bool NetLuaFunc::writeSendUint32(unsigned int unValue)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	return (p->WriteUint32(unValue));
}

bool NetLuaFunc::writeSendDouble(double dblValue)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	return (p->WriteDouble(dblValue));
}

bool NetLuaFunc::writeSendString(std::string strValue)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	return (p->WriteString(strValue));
}

void NetLuaFunc::beginSendBuf(unsigned int unMsgId)
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	p->BeginNetBuf(NET_MSG_TAG, CLIENTNETID, unMsgId);
}

void NetLuaFunc::endSendBuf()
{
	DBuf* p = DNetScheduler::Instance()->GetSendDBuf();
	p->EndNetBuf();
}

void NetLuaFunc::sendSvrBuf(std::string strFarAddr, unsigned int uPort,bool bDirect)
{
	DNetScheduler::Instance()->SendBufToSvr(strFarAddr.c_str(), uPort,bDirect);
}

void NetLuaFunc::downloadFile(const char* url, const char* path, bool bFile)
{
	DNetScheduler::Instance()->DownloadFile(url, path, bFile);
}

std::string NetLuaFunc::getOutFile()
{
	return DNetScheduler::Instance()->getOutFile();
}

std::string NetLuaFunc::getStrRet()
{
	return DNetScheduler::Instance()->getStrRet();
}