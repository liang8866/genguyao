//
//  FileTools.h
//  GameClient
//
//  Created by app05 on 15-9-19.
//
//

#ifndef __GameClient__FileTools__
#define __GameClient__FileTools__

#include <stdio.h>
#include <stdlib.h>
#include <string>

class FileTools
{
public:
	static void WriteToFile(const char *storagePath, const char *filedata = buffer, size_t size = filesize)
	{
		do
		{
			FILE *pf = fopen(storagePath, "w");
			fwrite(filedata, sizeof(char), size, pf);
			fclose(pf);

		} while (0);
	}

	static char* ReadToFile(const char *filename)
	{
		do
		{
			if (buffer != nullptr)
			{
				free(buffer);
				buffer = nullptr;
			}
			FILE *pf = fopen(filename, "r");
			fseek(pf, 0, SEEK_END);
			filesize = ftell(pf);
			fseek(pf, 0, SEEK_SET);
			buffer = (char*)malloc(filesize);
			fread(buffer, sizeof(char), filesize, pf);
			fclose(pf);

		} while (0);

		return buffer;
	}

	// 文件操作完最终都要调用这个释放内存结束
	static void DeleteObj()
	{
		if (buffer != nullptr)
		{
			free(buffer);
			buffer = nullptr;
		}
	}

private:
	static char* buffer;
	static int filesize;
};

bool createDirectory(const char* path);
bool createFullDirectory(const std::string& path);
void deleteFile(const std::string& path);
int renameFile(const std::string& path1, const std::string& path2);

#endif // defined(__GameClient__FileTools__)
