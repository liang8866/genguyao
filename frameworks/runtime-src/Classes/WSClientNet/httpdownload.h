#ifndef __HTTPDOWNLOAD_H__
#define __HTTPDOWNLOAD_H__

#include <string>

class Httpdownload;
struct HttpdownloadSink
{
	virtual void onProgress(Httpdownload* pdownload) = 0;
	virtual void onLoaded(bool b) = 0;
};

class Httpdownload
{
public:
	Httpdownload();
	~Httpdownload();

public:
	bool start(const std::string& strUrl, const std::string strStorage = "", bool bfile = true, HttpdownloadSink* pSink = 0);
	int	onDownload(void *ptr, size_t size,size_t nmemb);
	int onProgress(double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded);
	void getProgress(double& totalDown, double& nowDown);
	bool isSucceed();
	std::string getOutFile();
	std::string getStrRet();

private:
	bool downloadFile(const std::string& strFile);
	bool downloadString(const std::string& strFile);

private:
	std::string m_strUrl;
	std::string m_storagePath;
	bool m_bfile;
	FILE *m_fp;
	std::string m_strOutFile;
	std::string m_strRet;
	HttpdownloadSink *m_pSink;
	double m_totalToDownload;
	double m_nowDownload;
	bool m_bSucceed;
};

#endif // __HTTPDOWNLOAD_H__