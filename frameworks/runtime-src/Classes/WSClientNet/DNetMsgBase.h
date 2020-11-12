#ifndef _WSCLIENTNET_DNETMSGBASE_H_
#define _WSCLIENTNET_DNETMSGBASE_H_

#define MAX_NETMSG_LEN			131072					// 网络消息的最大长度。128K
#define NETMSG_HEADER_LEN		16						// 网络消息包头长度
#define NET_MSG_TAG				0xAF668899				// 消息包头
#define NETIOBUFLEN             4096                    // 每次发送的长度
#define CLIENTNETID				0xBD336699				// 客户端发给服务端通用的NETID

#endif