//
//  FileTools.cpp
//  GameClient
//
//  Created by app05 on 15-9-19.
//
//

#include "cocos2d.h"
USING_NS_CC;
#include "FileTools.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/stat.h>
#include <unistd.h>
#else
#include <windows.h>
#endif

char* FileTools::buffer = nullptr;
int FileTools::filesize = 0;

bool createDirectory(const char* path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	mode_t processMask = umask(0);
	int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
	umask(processMask);
	if (ret != 0 && (errno != EEXIST))
		return false;
	return true;
#else
	bool ret = CreateDirectoryA(path, NULL);
	if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
		return false;
	return true;
#endif
}

bool createFullDirectory(const std::string& path)
{
	char *c = (char *)path.c_str();
	while (*c != 0)
	{
		if (*c == '\\')
			*c++ = '/';
		else
			c++;
	}

	if (path.length() == 1)
		return true;

	std::string  subpath = path.substr(0, path.length() - 1);
	if (subpath == "")
		return true;

	std::string sub_file_path;
	size_t pos = subpath.find_last_of("/");
	if (pos != std::string::npos)
		sub_file_path = subpath.substr(0, pos + 1);
	else
		return true;

	if (sub_file_path != "")
	{
		if (createFullDirectory(sub_file_path) == false)
			return false;
	}

	if (createDirectory(path.c_str()) == false)
		return false;

	return true;
}

void deleteFile(const std::string& path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	unlink(path.c_str());
#else 
	_unlink(path.c_str());
#endif 
}

int renameFile(const std::string& path1, const std::string& path2)
{
	return rename(path1.c_str(), path2.c_str());
}
