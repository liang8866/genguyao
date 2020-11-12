#include "DBuf.h"

DBuf::DBuf()
{
	m_byBufType = DBufType::eUser;
	m_pBuf = nullptr;
	m_nBufLen = 0;
	m_nBufRealSize = 0;
	m_nCurPos = 0;
	m_bAttached = false;
}

DBuf::~DBuf()
{
	FreeBuf();
}

DBuf* DBuf::TakeNewBuf()
{
	DBuf* pRet = new DBuf();
	return pRet;
}

void DBuf::BackBuf(DBuf** pBack)
{
	if (*pBack != nullptr)
	{
		delete *pBack;
		*pBack = nullptr;
	}
}

void DBuf::FreeBuf()
{
	if (m_bAttached)
		DAttach();
	else
	{
		if (m_pBuf)
		{
			delete[] m_pBuf;
			m_pBuf = nullptr;
		}
		m_pBuf = nullptr;
		m_nBufLen = 0;
		m_nBufRealSize = 0;
		m_nCurPos = 0;
		m_bAttached = false;
	}
}

bool DBuf::Attach(char* pBuf, int nBufLen)
{
	if (m_pBuf)
		FreeBuf();

	if (!pBuf)
		return false;

	m_pBuf = pBuf;
	m_nBufLen = nBufLen;
	m_nBufRealSize = m_nBufLen;
	m_nCurPos = 0;
	m_bAttached = true;

	return true;
}

void DBuf::DAttach()
{
	m_pBuf = nullptr;
	m_nBufLen = 0;
	m_nBufRealSize = 0;
	m_nCurPos = 0;
	m_bAttached = false;
}

void DBuf::Reset()
{
	m_nBufLen = 0;
	m_nCurPos = 0;
}

bool DBuf::ReadByte(unsigned char& byValue)
{
	if (GetRemainLen() < sizeof(unsigned char))
		return false;

	unsigned char* temp = (unsigned char*)(GetCurPos());
	memcpy(&byValue, temp, sizeof(unsigned char));
	Shift(sizeof(unsigned char));
	return true;
}

bool DBuf::ReadShort(short& shtValue)
{
	if (GetRemainLen() < sizeof(short))
		return false;

	short* temp = (short*)(GetCurPos());
	memcpy(&shtValue, temp, sizeof(short));
	Shift(sizeof(short));
	return true;
}

bool DBuf::ReadInteger(int& intValue)
{
	if (GetRemainLen() < sizeof(int))
		return false;

	int* temp = (int*)(GetCurPos());
	memcpy(&intValue, temp, sizeof(int));
	Shift(sizeof(int));
	return true;
}

bool DBuf::ReadUint32(unsigned int& utValue)
{
	if (GetRemainLen() < sizeof(unsigned int))
		return false;

	unsigned int* temp = (unsigned int*)(GetCurPos());
	memcpy(&utValue, temp, sizeof(unsigned int));
	Shift(sizeof(unsigned int));
	return true;
}

bool DBuf::ReadDouble(double& dblValue)
{
	if (GetRemainLen() < sizeof(double))
		return false;

	double* temp = (double*)(GetCurPos());
	memcpy(&dblValue, temp, sizeof(double));
	Shift(sizeof(double));
	return true;
}

bool DBuf::ReadString(std::string& strValue)
{
	if (GetRemainLen() < sizeof(short))
		return false;

	strValue = "";
	short nLen = 0;
	if (ReadShort(nLen) && nLen > 0)
	{
		if (GetRemainLen() < nLen)
			return false;

		strValue.append((char*)GetCurPos(), nLen);
		strValue += "\0";
		Shift(nLen);
		if (strValue.c_str() == nullptr)  //这里要设置为空字符串，否则lua取出来就变成了nil
		{
			strValue = "";
		}
	}
	return true;
}

bool DBuf::WriteByte(unsigned char byValue)
{
	unsigned char* pCur = (unsigned char*)(GetMem(sizeof(unsigned char)));
	if (pCur)
	{
		memcpy(pCur, &byValue, sizeof(unsigned char));
		Shift(sizeof(unsigned char));
		return true;
	}
	return false;
}

bool DBuf::WriteShort(short shtValue)
{
	short* pCur = (short*)(GetMem(sizeof(short)));
	if (pCur)
	{
		memcpy(pCur, &shtValue, sizeof(short));
		Shift(sizeof(short));
		return true;
	}
	return false;
}

bool DBuf::WriteInteger(int intValue)
{
	int* pCur = (int*)(GetMem(sizeof(int)));
	if (pCur)
	{
		memcpy(pCur, &intValue, sizeof(int));
		Shift(sizeof(int));
		return true;
	}
	return false;
}

bool DBuf::WriteUint32(unsigned int utValue)
{
	unsigned int* pCur = (unsigned int*)(GetMem(sizeof(unsigned int)));
	if (pCur)
	{
		memcpy(pCur, &utValue, sizeof(unsigned int));
		Shift(sizeof(unsigned int));
		return true;
	}
	return false;
}

bool DBuf::WriteDouble(double dblValue)
{
	double* pCur = (double*)(GetMem(sizeof(double)));
	if (pCur)
	{
		memcpy(pCur, &dblValue, sizeof(double));
		Shift(sizeof(double));
		return true;
	}
	return false;
}

bool DBuf::WriteString(const std::string& strValue)
{
	short nLen = (short)strValue.length();
	WriteShort(nLen);
	char* pCur = (char*)(GetMem(nLen));
	if (pCur)
	{
		memcpy(pCur, strValue.c_str(), nLen);
		Shift(nLen);
		return true;
	}
	return false;
}

bool DBuf::WriteBuffer(const char* szBuf, int nLen)
{
	char* pCur = (char*)(GetMem(nLen));
	if (pCur)
	{
		memcpy(pCur, szBuf, nLen);
		return true;
	}
	return false;
}

bool DBuf::SetNetMsg(unsigned char byType, const char* szMsg, int nBufLen)
{
	if (m_pBuf)
		FreeBuf();

	Reset();
	m_byBufType = byType;
	if (szMsg && (nBufLen > 0))			//不是所有类型的消息都有消息内容
	{
		GetMem(nBufLen);
		memcpy(m_pBuf, szMsg, nBufLen);
	}
	return true;
}

void DBuf::BeginNetBuf(unsigned int utTag, unsigned int utNetObjID, unsigned int utMsgID)
{
	if (m_pBuf)
		FreeBuf();

	WriteUint32(utTag);					//网络消息包头
	WriteUint32(0);						//网络消息包长度(占位)
	WriteUint32(utNetObjID);			//网络对象ID
	WriteUint32(utMsgID);
}

void DBuf::EndNetBuf()
{
	//重新处理长度
	unsigned int* utLen = (unsigned int*)SetCurPos(sizeof(unsigned int));
	*utLen = m_nBufLen;
}

char* DBuf::GetMem(int nAllocSize)
{
	if ((m_nCurPos + nAllocSize) > m_nBufRealSize)		//原有内存已经不够用
	{
		if (m_bAttached)
		{
			CCLOG("if DBuf::GetMem.m_bAttacked == true then can not malloc memory");
			return nullptr;		//如果是attached，不能申请内存
		}

		int nNewSize = (m_nCurPos + nAllocSize);
		AlignNumForMinSize(nNewSize);
		char* pNewBuf = new char[nNewSize];
		if (!pNewBuf)
		{
			CCLOG("DBuf::GetMem.得不到新内存");
			return nullptr;
		}
		memset(pNewBuf, 0, nNewSize);
		if (m_pBuf)		//原来就有数据
		{
			memcpy(pNewBuf, m_pBuf, m_nBufLen);
			delete[] m_pBuf;
			m_pBuf = nullptr;
		}
		m_pBuf = pNewBuf;
		m_nBufRealSize = nNewSize;
	}

	int nOff = (m_nCurPos + nAllocSize) - m_nBufLen;
	if (nOff > 0)
		m_nBufLen += nOff;

	return (m_pBuf + m_nCurPos);
}

int DBuf::AlignNumForMinSize(int& nIn)
{
	if (nIn < eMinAllocSize)
		nIn = eMinAllocSize;

	int nTemp = nIn % eMinAllocSize;
	if (nTemp != 0)
		nIn += (eMinAllocSize - nTemp);

	return nIn;
}

//todo:这里应该要判断一下，不能移动到合法的区域外面，以免造成非法访问
char* DBuf::Shift(int nSize)
{
	if ((m_nCurPos + nSize) > m_nBufLen)
	{
		char szMsg[200] = { 0 };
		CCLOG(szMsg, "DBuf::shift发现越界读写，中止缓冲区读写。m_nCurPos=%d m_nBufLen=%d", m_nCurPos, m_nBufLen);
	}
	else
		m_nCurPos += nSize;

	return m_pBuf + m_nCurPos;
}