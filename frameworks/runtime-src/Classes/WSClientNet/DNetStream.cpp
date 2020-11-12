//
//  DNetStream.cpp
//  weishiGame
//
//  Created by apple03 on 15-9-18.
//
//

#include "DNetMsgBase.h"
#include "DBuf.h"
#include "DLongConnect.h"
#include "DNetStream.h"

DNetStream::DNetStream()
{
    m_pConn = nullptr;
    m_pBuffer = nullptr;
    m_nBufferUse = 0;
    m_nBufRealSize = 0;
    
    m_pNetBuf = nullptr;
}

DNetStream::~DNetStream()
{
    Final();
}

bool DNetStream::Init(DLongConnect* pConn)
{
    if(!pConn)
        return false;
    m_pConn = pConn;
    
    FreeBuf();
    if (m_pNetBuf != nullptr)
        DBuf::BackBuf(&m_pNetBuf);
    m_pNetBuf = DBuf::TakeNewBuf();
    
    return true;
}

void DNetStream::Final()
{
    FreeBuf();
    if (m_pNetBuf != nullptr)
        DBuf::BackBuf(&m_pNetBuf);
    m_pConn = nullptr;
}

/*
 处理粘包的函数
 参数：
 szInBuf:IOCP线程中收到的消息包
 dwRecv:IOCP线程中收到的消息包长度
 
 处理方法
 1、首先判断是否是一个完整包，如果是完整包，直接给LINKER
 2、然后把包内存拷贝到缓冲中
 3、从缓冲区的零开始到长度，轮询看有没有包头标识，如果有，看有没有完整数据。如果有，则把完整数据发给LINKER
 */
bool DNetStream::DealWithSocketMsg(const char* szInBuf,unsigned int dwRecv)
{
    char szLog[1024] = {0};
    
    //首先判断是否是完整消息
    m_pNetBuf->FreeBuf();
    if (dwRecv > NETMSG_HEADER_LEN)
    {
        m_pNetBuf->Attach((char*)szInBuf,dwRecv);
        unsigned int utRead = 0;
        if (m_pNetBuf->ReadUint32(utRead))
        {
            if (utRead == NET_MSG_TAG)			//有消息包头，且可能是完整数据
            {
                m_pNetBuf->ReadUint32(utRead);		//网络消息包长度（是整个包的长度，包括消息头）
                if ((utRead >= MAX_NETMSG_LEN) || (utRead < NETMSG_HEADER_LEN))
                {
                    snprintf(szLog,sizeof(szLog),"DNetStream::DealWithSocketMsg.发送消息长度不合法.消息长度:%d.消息内容:", utRead);
                    strncat(szLog,szInBuf,800);	//把收到的消息打印出来,要防止数组越界
                    CCLOG("%s", szLog);
                    m_pConn->SendAppThreadMsg(DBufType::eNetError);
                    return false;
                }
                else if(utRead == dwRecv)		//长度相符，正好 一个完整包，就不进缓冲区，直接发给应用层
                {
                    m_pConn->SendAppThreadMsg(DBufType::eNetClientNormalMsg,szInBuf,dwRecv);
                    return true;
                }
            }
        }
    }
    
    //把收到的消息拷贝到缓冲区
    if((m_nBufferUse + dwRecv) >= MAX_NETMSG_LEN)
    {
        snprintf(szLog, sizeof(szLog), "DNetStream::DealWithSocketMsg.处理粘包缓冲区超过最大值.");
        CCLOG("%s", szLog);
        m_pConn->SendAppThreadMsg(DBufType::eNetError);
        return false;
    }
    memcpy(GetMem(dwRecv),szInBuf,dwRecv);
    m_nBufferUse += dwRecv;
    
    
    LoopBuffer();		//轮询看是已经有完整消息包
    
    return true;
}

bool DNetStream::LoopBuffer()
{
    if (m_nBufferUse < NETMSG_HEADER_LEN)
        return true;
    
    char szLog[1024] = {0};
    m_pNetBuf->FreeBuf();
    m_pNetBuf->Attach(m_pBuffer, m_nBufferUse);
    unsigned int utRead = 0;
    bool bRet = m_pNetBuf->ReadUint32(utRead);		//包头
    if ((!bRet) || (utRead != NET_MSG_TAG))
    {
        snprintf(szLog,sizeof(szLog),"DNetStream::LoopBuffer.发送消息包头不合法.BuffUse长度:%d.消息内容:", m_nBufferUse);
        strncat(szLog,m_pBuffer,(m_nBufferUse > 800 ? 800 : m_nBufferUse));	//要防止数组越界
        CCLOG("%s", szLog);
        m_pConn->SendAppThreadMsg(DBufType::eNetError);
        return false;
    }
    
    m_pNetBuf->ReadUint32(utRead);		//网络消息包长度（是整个包的长度，包括消息头）
    if ((!bRet) || (utRead >= MAX_NETMSG_LEN) || (utRead < NETMSG_HEADER_LEN))
    {
        snprintf(szLog,sizeof(szLog),"DNetStream::LoopBuffer.发送消息包头不合法.长度:%d.消息内容:", m_nBufferUse);
        strncat(szLog,m_pBuffer,(m_nBufferUse > 800 ? 800 : m_nBufferUse));	//要防止数组越界
        CCLOG("%s",szLog);
        m_pConn->SendAppThreadMsg(DBufType::eNetError);
        return false;
    }
    
    if (utRead < m_nBufferUse)
    {
        m_pConn->SendAppThreadMsg(DBufType::eNetClientNormalMsg,m_pBuffer, utRead);
        
        //内存移动
        memcpy(m_pBuffer, (m_pBuffer + utRead), (m_nBufferUse - utRead));
        m_nBufferUse -= utRead;
        
        LoopBuffer();
    }
    else if (utRead == m_nBufferUse)
    {
        m_pConn->SendAppThreadMsg(DBufType::eNetClientNormalMsg,m_pBuffer, utRead);
        
        memset(m_pBuffer,0,m_nBufRealSize);
        m_nBufferUse = 0;
        
        //如果已经申请了超大内存。退还内存，下次有需要再申请(否则会出现一次超长数据发送，就会让缓冲区变大再不会变小)
        if(m_nBufRealSize > eMinBufferSize)
            FreeBuf();
    }
    
    return true;
}

void DNetStream::FreeBuf()
{
    if(m_pBuffer)
        delete[] m_pBuffer;
    m_pBuffer = nullptr;
    m_nBufferUse = 0;
    m_nBufRealSize = 0;
}

char* DNetStream::GetMem(int nAllocSize)
{
    int nNewSize = (m_nBufferUse + nAllocSize);
    if(nNewSize > m_nBufRealSize)		//原有内存已经不够用
    {
        AlignNumForMinSize(nNewSize);
        char* pNewBuf = new char[nNewSize];
        if(!pNewBuf)
        {
            CCLOG("Error:DNetStream::GetMem.得不到新内存");
            return nullptr;
        }
        memset(pNewBuf,0,nNewSize);
        if(m_pBuffer)		//原来就有数据
        {
            memcpy(pNewBuf,m_pBuffer,m_nBufferUse);
            delete[] m_pBuffer;
            m_pBuffer = nullptr;
        }
        m_pBuffer = pNewBuf;
        m_nBufRealSize = nNewSize;
    }
    
    return (m_pBuffer + m_nBufferUse);
}

int DNetStream::AlignNumForMinSize(int& nIn)
{
    if(nIn < eMinBufferSize)
        nIn = eMinBufferSize;
    
    int nTemp = nIn % eMinBufferSize;
    if(nTemp != 0)
        nIn += (eMinBufferSize - nTemp);
    
    return nIn;
}
