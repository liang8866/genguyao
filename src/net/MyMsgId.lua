local MyMsgId = {

    noNoticeID     = {                                               -- 特殊的通知不出现圈圈
         CL_SERVER_RANDOMNICKNAME                     = 1019,        -- 客户端请求随机姓名
         CL_SERVER_TIME                               = 1202,        -- 客户端向服务端请求当前时间
         CL_SERVER_REQUEST_COPY_BATTLE                = 1505,        -- 客户端向服务器请求战斗 
         CL_SERVER_TRANSPORT_LIST                     = 1351,        -- 客户端向服务端请求押镖列表
     },       


}

function MyMsgId:getiIsNeedLoadFalsh(nId)
	local flag = false
    for key, var in pairs(MyMsgId.noNoticeID) do
		if var == nId  then
			flag = true
			break
		end
	end
	return flag
end

return MyMsgId