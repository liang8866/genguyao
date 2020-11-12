#include "httpdownload.h"
#include <curl/curl.h>
#include <curl/easy.h>
#include <stdio.h>
#include <vector>
#include <cocos2d.h>
#include "../customCpp/FileTools.h"

USING_NS_CC;

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#endif

static size_t downLoadFile(void *ptr, size_t size, size_t nmemb, void *userdata)
{
	Httpdownload *hp = (Httpdownload*)userdata;
	return hp->onDownload(ptr, size, nmemb);
}

static int progressFunc(void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	Httpdownload *hp = (Httpdownload*)ptr;
	return hp->onProgress(totalToDownload, nowDownloaded,totalToUpLoad, nowUpLoaded);
}

Httpdownload::Httpdownload()
	: m_bfile(true)
	, m_fp(0)
	, m_pSink(0)
	, m_totalToDownload(0)
	, m_nowDownload(0)
	, m_bSucceed(false)
{

}

Httpdownload::~Httpdownload()
{
	if (m_fp)
	{
		fclose(m_fp);
		m_fp = 0;
	}
}

bool Httpdownload::start(const std::string& strUrl, const std::string strStorage, bool bfile, HttpdownloadSink* pSink)
{
	m_storagePath = CCFileUtils::sharedFileUtils()->getWritablePath() + strStorage;
	m_strUrl = strUrl;
	m_bfile = bfile;

	m_pSink = pSink;
	size_t pos = m_strUrl.find_last_of("/");

	size_t pos1 = 0;
	pos1 = m_strUrl.find("/", pos1);
	pos1 += 1;
	pos1 = m_strUrl.find("/", pos1);
	pos1 += 1;
	pos1 = m_strUrl.find("/", pos1);

	if (pos == std::string::npos || pos1 == std::string::npos)
		return false;

	if (pos != pos1)
	{
		std::string substr = m_strUrl.substr(pos1, pos - pos1 + 1);
		m_storagePath += substr;
	}

	if (m_bfile)
	{
		return downloadFile(m_strUrl.substr(pos + 1));
	}
	else
		return downloadString(m_strUrl.substr(pos + 1));

	return true;
}

int Httpdownload::onDownload(void *ptr, size_t size, size_t nmemb)
{
	int ret = 0;
	if (m_fp)
		ret = fwrite(ptr, size, nmemb, m_fp);
	else
		m_strRet.append((char*)ptr, (ret = size * nmemb));
	return ret;
}

int Httpdownload::onProgress(double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded)
{
	m_totalToDownload = totalToDownload;
	m_nowDownload = nowDownloaded;
	if (m_pSink)
		m_pSink->onProgress(this);

	return 0;
}

void Httpdownload::getProgress(double& totalDown, double& nowDown)
{
	totalDown = m_totalToDownload; 
	nowDown = m_nowDownload;
}

bool Httpdownload::isSucceed()
{
	return m_bSucceed;
}

std::string Httpdownload::getOutFile()
{
	return m_strOutFile;
}

std::string Httpdownload::getStrRet()
{
	return m_strRet;
}

bool Httpdownload::downloadFile(const std::string& strFile)
{
	CURL*_curl = curl_easy_init();
	if(_curl == 0)
		return false;
	curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYHOST, 0L);
	curl_easy_setopt(_curl,CURLOPT_NOSIGNAL,1);
	//curl_easy_setopt(_curl, CURLOPT_FORBID_REUSE, 1); 
	//createDirectory
	if (createDirectory(m_storagePath.c_str()) == false)
	{
		if (createFullDirectory(m_storagePath) == false)
			return false;
	}
	std::string strSlash = "/";
	m_strOutFile = m_storagePath + strSlash + strFile; // m_storagePath +"/"+ strFile

	std::string backfile = m_strOutFile + ".bak";
	m_fp = fopen(backfile.c_str(), "wb+");
	if (!m_fp)
	{
		CCLOG("can not create file %s", backfile.c_str());
		return false;
	}

	CCLOG("Httpdownload::downloadFile() begin download packag %s", m_strUrl.c_str());
	// Download pacakge
	CURLcode res;
	curl_easy_setopt(_curl, CURLOPT_URL, m_strUrl.c_str());
	curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadFile);
	curl_easy_setopt(_curl, CURLOPT_WRITEDATA, this);
	curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
	curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, progressFunc);
	curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, this);
	res = curl_easy_perform(_curl);

	long retcode = 0;
	if(res == CURLE_OK)
		curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE , &retcode); 

	curl_easy_cleanup(_curl);

	if (res != CURLE_OK || retcode != 200)
	{
		CCLOG("Httpdownload::downloadFile() error when download package %s %d", m_strUrl.c_str(), res);
		fclose(m_fp);
		m_fp = 0;
		deleteFile(backfile);				// Ê§°ÜÁËÉ¾³ýÎÄ¼þ
		if(m_pSink)
		  m_pSink->onLoaded(false);		
		return false;
	}
	fflush(m_fp);
	fclose(m_fp);
	m_fp = 0;
	m_bSucceed = true;
	deleteFile(m_strOutFile);
    renameFile(backfile,m_strOutFile);
	if (m_pSink)
		m_pSink->onLoaded(true);
	return true;
}

bool Httpdownload::downloadString(const std::string& strFile)
{
    CURL*_curl = curl_easy_init();
    if (_curl == 0)
		return false;
	CURLcode res;
	curl_easy_setopt(_curl,CURLOPT_NOSIGNAL,1);
	curl_easy_setopt(_curl, CURLOPT_URL, m_strUrl.c_str());
	curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, downLoadFile);
	curl_easy_setopt(_curl, CURLOPT_WRITEDATA, this);
	curl_easy_setopt(_curl, CURLOPT_NOPROGRESS, false);
	curl_easy_setopt(_curl, CURLOPT_PROGRESSDATA, this);
	curl_easy_setopt(_curl, CURLOPT_PROGRESSFUNCTION, progressFunc);
	res = curl_easy_perform(_curl);
	curl_easy_cleanup(_curl);
	if (res != 0)
	{		
		if (m_pSink)
		m_pSink->onLoaded(false);
		return false;
	}
	m_bSucceed = true;
	if (m_pSink)
		m_pSink->onLoaded(true);
	return true;
}

