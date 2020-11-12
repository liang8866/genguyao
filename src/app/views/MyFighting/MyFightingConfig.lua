-- 战斗相关定义

MyFightingConfig = {

        -- 阵营
        ECamp = {

            Player = 1,  -- 玩家
            Enemy  = 2,  -- 敌人 

        },


        -- 子弹路径
        EBulletPath = {

            Top     = 1,  -- 上路 
            Middle  = 2,  -- 中路
            Bottom  = 3,  -- 下路

        },


        -- 技能类型
        ESkillType = {

            Normal     = 1,  -- 普通技能
            Other = 2,  -- 大招

        },

        -- 战斗类型
        EBattleType = {

            PVE  = 1,  -- 人机对战
            PVP  = 2,  -- 人人对战

        },

        -- 角色状态
        ERoleState = {
            Stand = 1,  -- 站立
            Run = 2,    -- 跑
            Attack = 3, -- 攻击
            Wound = 4,  -- 受击
            Dead = 5,   -- 死亡

        },
        BulletType = {
        FibbleSkill = 1,--飞宝的
        GodSkill = 2,  -- 神将的

        },
        moveTime = 2.0,      -- 出场移动时间
}

return MyFightingConfig