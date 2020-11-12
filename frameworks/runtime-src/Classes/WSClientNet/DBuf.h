#ifndef _WSCLIENTNET_DBUF_H_
#define _WSCLIENTNET_DBUF_H_

#include "cocos2d.h"
USING_NS_CC;

struct DBufType								//DBUF的类型
{
	enum
	{
		eUser,											// 默认，用户自定义

		eNetClientNormalMsg,							// 做为客户端收到普通消息
		eNetError,										// 网络错误

		eAppDispatchMsg,								// 应用层发出的消息，备用
	};
};

class DBuf
{
private:
	DBuf();
	~DBuf();

public:
	static DBuf* TakeNewBuf();
	static void BackBuf(DBuf** pBack);

public:
	void FreeBuf();
	bool Attach(char* pBuf, int nBufLen);
	void DAttach();
	void Reset();
	bool Attached(){ return m_bAttached; }
	char* GetCurPos(){ return m_pBuf ? (m_pBuf + m_nCurPos) : nullptr; }
	char* SetCurPos(int nOffset){ m_nCurPos = nOffset; return m_pBuf ? (m_pBuf + nOffset) : nullptr; }
	int GetCurPosOffset(){ return m_nCurPos; }
	char* GetBuf(){ return m_pBuf; }
	int  GetLength(){ return m_nBufLen; }
	int GetRemainLen(){ return (m_nBufLen - m_nCurPos); };

	bool ReadByte(unsigned char& byValue);
	bool ReadShort(short& shtValue);
	bool ReadInteger(int& intValue);
	bool ReadUint32(unsigned int& utValue);
	bool ReadDouble(double& dblValue);
	bool ReadString(std::string& strValue);

	bool WriteByte(unsigned char byValue);
	bool WriteShort(short shtValue);
	bool WriteInteger(int intValue);
	bool WriteUint32(unsigned int utValue);
	bool WriteDouble(double dblValue);
	bool WriteString(const std::string& strValue);
	bool WriteBuffer(const char* szBuf, int nLen);

public:
	bool SetNetMsg(unsigned char byType, const char* szMsg, int nBufLen);
	void BeginNetBuf(unsigned int utTag, unsigned int utNetObjID, unsigned int utMsgID);
	void EndNetBuf();

public:
	enum{ eMinAllocSize = 64, };			//每次分配的内存会是64字节的整数倍

private:
	char* GetMem(int nAllocSize);
	int AlignNumForMinSize(int& nIn);
	char* Shift(int nSize);

public:
	unsigned char m_byBufType;          //表示BUF的类型

private:
	char* m_pBuf;						//真实的数据区
	int   m_nBufLen;
	int   m_nBufRealSize;
	int   m_nCurPos;					//完成一次写入后，指向下一个未写过的地方
	bool  m_bAttached;

};

#endif