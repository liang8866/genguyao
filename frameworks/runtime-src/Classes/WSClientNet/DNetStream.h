//
//  DNetStream.h
//  weishiGame
//
//  Created by apple03 on 15-9-18.
//
//

#ifndef __weishiGame__DNetStream__
#define __weishiGame__DNetStream__
#include "cocos2d.h"
USING_NS_CC;

class DLongConnect;
class DBuf;
class DNetStream
{
public:
    DNetStream();
    ~DNetStream();
    
    bool Init(DLongConnect* pConn);		//初始化，分配内存
    void Final();							//释放资源
    
    bool DealWithSocketMsg(const char* szInBuf,unsigned int dwRecv);	//最重要的函数，处理粘包
    bool LoopBuffer();											//轮询整个BUFFER，查找有没有完整的消息包
    void FreeBuf();
    
private:
    char* GetMem(int nAllocSize);
    int AlignNumForMinSize(int& nIn);
    
public:
    enum{eMinBufferSize = 1024,};							//每次最小申请内存
    
private:
    DLongConnect* m_pConn;					//对应的连接
    char* m_pBuffer;
    int m_nBufferUse;							//已经使用了多少BUFFER，其实是STREAM的长度
    int m_nBufRealSize;							//buf的实际长度
    DBuf* m_pNetBuf;								//用于处理网络消息的DBUF类
};


#endif /* defined(__weishiGame__DNetStream__) */
