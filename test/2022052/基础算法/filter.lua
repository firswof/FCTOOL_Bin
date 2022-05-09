--[[
    了解号码组合如何产生有助于更好使用当前文档及提高预期的运算能力，如下：

    1>号码组合穷举生成器        ↓↓↓
    2>基本过滤器                ↓↓↓
    3>中级过滤器(QuickCheck)    ↓↓↓
    4>高级过滤器                ↓↓↓
    5>最终过滤器(LastCheck)     ↓↓↓
    6>输出号码组合              END

    如上，在 QuickCheck() 执行早于 LastCheck()，这意味着，如果
    两者执行同样检查 QuickCheck 更早返回。
--]]


--[[
    内部变量定义表(如下)
    (注意！！！不要试图向内部变量赋值，否则运算结果将不可靠。)

    ------------------------------------------------------
    变量                   |    注释
    ------------------------------------------------------
    red[1]  ... red[6]     |    红1        ...  红6
    tail[1] ... tail[6]    |    红1   尾   ...  红6 尾
    s012[1] ... s012[6]    |    红1   012  ...  红6 012
    sodd[1] ... sodd[6]    |    红1   奇?  ...  红6 奇?
    zone[1] ... zone[3]    |    区间1 数   ...  区间3 数
    diff[1] ... diff[5]    |    红1-2 间差 ...  红5-6 间差
    ac                     |    AC值
    sum                    |    和值
    odd                    |    奇数
    maxDiff                |    跨度
    series                 |    连号数
    seriesGroup            |    连号组数
    ------------------------------------------------------
--]]

-- 输出格式
-- 0    :   '       1:  1  2  6 14 16 25'
-- 1    :   '       1: 01 02 06 14 16 25'
-- 2    :   '       1:  1,  2,  6, 14, 16, 25'
-- 3    :   '       1: 01, 02, 06, 14, 16, 25'
-- 4    :   ' 1  2  6 14 16 25'
-- 5    :   '01 02 06 14 16 25'
-- 6    :   ' 1,  2,  6, 14, 16, 25'
-- 7    :   '01, 02, 06, 14, 16, 25'
output_style=0


-- QuickCheck()    :    级别: 中级过滤器
-- return true     :    放行-当前组合
-- return false    :    拦截-当前组合
function QuickCheck()
	if ac < 5 then return false end
	if seriesGroup == 3 then return false end
	if zone[1] > 4 or zone[2] > 4 or zone[3] > 4 then return false end
	if t012(0) > 4 or t012(1) > 4 or t012(2) > 4 then return false end

	-- 同尾数限制
	for _,v in ipairs({0,4,5,6,7,8,9}) do
		if ttail(v) >= 3 then return false end
	end
	for i=1,3 do
		if ttail(i) >= 4 then return false end
	end

	-- 杀上期跨度
	if maxDiff == 31 then return false end

	-- 杀上期和值尾号
	if sum%10 == 9 then return false end

    -- 放行
--~     do
--~         return true
--~     end

-- 截止2021-01-23 最近 150期区间比数据：
-- 区间比: (2,2,2)        27 Frq:18.00%
-- 区间比: (3,2,1)        21 Frq:14.00%
-- 区间比: (3,1,2)        13 Frq:8.67%
-- 区间比: (2,3,1)        12 Frq:8.00%
-- 区间比: (2,1,3)        10 Frq:6.67%
-- 区间比: (1,2,3)        10 Frq:6.67%
-- 区间比: (1,3,2)         9 Frq:6.00%
-- 区间比: (1,1,4)         9 Frq:6.00%
-- 区间比: (4,1,1)         7 Frq:4.67%
-- 区间比: (3,0,3)         5 Frq:3.33%
-- 区间比: (0,3,3)         5 Frq:3.33%
-- 区间比: (4,2,0)         4 Frq:2.67%
-- 区间比: (3,3,0)         4 Frq:2.67%
-- 区间比: (0,4,2)         3 Frq:2.00%
-- 区间比: (1,4,1)         3 Frq:2.00%
-- 区间比: (0,2,4)         2 Frq:1.33%
-- 区间比: (2,0,4)         2 Frq:1.33%
-- 区间比: (2,4,0)         2 Frq:1.33%
-- 区间比: (5,0,1)         1 Frq:0.67%
-- 区间比: (6,0,0)         1 Frq:0.67%
-- 区间比: Other           0 Frq:0.00%
	-- 区间比预测
	if tableEqu(zone,  {2,2,2})	or tableEqu(zone, {3,2,1}) or tableEqu(zone, {3,1,2}) or
		tableEqu(zone, {2,3,1}) or tableEqu(zone, {2,1,3}) or tableEqu(zone, {1,2,3}) or
		tableEqu(zone, {1,3,2}) or tableEqu(zone, {1,1,4}) or tableEqu(zone, {4,1,1}) or
		-- 以上命中率 78.68%
		(zone[1] == 3 or zone[2] == 3 or zone[3] == 3) or
		(zone[1] == 2 or zone[2] == 2 or zone[3] == 2) or
		(zone[1] == 1 or zone[2] == 1 or zone[3] == 1)
	then
		--pass
	else
		return false
	end

	-- 过滤近几期奇偶分布
	if 	tableEqu(sodd, {0, 1, 1, 1, 1, 1}) or tableEqu(sodd, {1, 1, 0, 0, 1, 1}) or 
        tableEqu(sodd, {0, 0, 1, 0, 1, 0}) or tableEqu(sodd, {1, 1, 1, 0, 0, 1}) 
	then return false end

	-- 过滤近几期尾号组合
	if 	tableLike(tail, {2, 5, 1, 7, 1, 3}) or tableLike(tail, {3, 5, 8, 4, 7, 3}) or 
        tableLike(tail, {2, 4, 7, 8, 5, 6}) or tableLike(tail, {5, 7, 7, 0, 6, 1}) or 
        tableLike(tail, {3, 7, 8, 4, 7, 0}) or tableLike(tail, {2, 1, 4, 5, 7, 0}) or 
        tableLike(tail, {3, 2, 7, 8, 9, 8}) or tableLike(tail, {1, 7, 8, 1, 3, 9}) or 
        tableLike(tail, {2, 7, 0, 3, 5, 7}) or tableLike(tail, {5, 0, 1, 1, 2, 0}) 
	then return false end

	-- 过滤近几期步长组合
	if 	tableLike(diff, {3, 6, 6, 4, 12 }) or tableLike(diff, { 2, 3, 6, 13, 6}) or 
        tableLike(diff, {2, 3, 11, 7, 1 }) or tableLike(diff, { 2, 10, 3, 6, 5}) or 
        tableLike(diff, {4, 1, 6, 13, 3 }) or tableLike(diff, { 9, 13, 1, 2, 3}) or 
        tableLike(diff, {9, 5, 1, 1, 9  }) or tableLike(diff, { 6, 1, 13, 2, 6}) or 
        tableLike(diff, {15, 3, 3, 2, 2 }) or tableLike(diff, { 5, 1, 10, 1, 8}) 
	then return false end

	-- 过滤近几期012路序列
	if 	tableEqu(s012, {2, 2, 2, 2, 0, 0}) or tableEqu(s012, {0, 2, 2, 2, 0, 0}) or 
        tableEqu(s012, {2, 1, 1, 0, 1, 2}) or tableEqu(s012, {2, 1, 2, 2, 2, 1}) or 
        tableEqu(s012, {0, 1, 2, 2, 0, 0}) or tableEqu(s012, {2, 2, 0, 1, 0, 0}) or 
        tableEqu(s012, {0, 0, 2, 0, 1, 1}) or tableEqu(s012, {1, 1, 2, 0, 2, 2}) or 
        tableEqu(s012, {2, 2, 2, 2, 1, 0}) or tableEqu(s012, {2, 1, 2, 0, 1, 0}) 
	then return false end


	-- 邻号或直线
	if series == 0 and AtSameLine() == false then return false end

-- 定义每个红球可选择项
	-- {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33}
	if red1NotIn({1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}) then return false end
	if red2NotIn({2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22}) then return false end
	if red3NotIn({5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27}) then return false end
	if red4NotIn({10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29}) then return false end
	if red5NotIn({14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32}) then return false end
	if red6NotIn({18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33}) then return false end

	-- 360 冷码
--~ 	result, count = redsIn({5, 13, 20, 21, 30})
--~ 	if not result then return false end
--~ 	if count > 3 then return false end

	-- 360 温码
--~ 	result, count = redsIn({1,2,3,4,6,7,10,11,12,14,15,16,18,19,22,23,24,25,27,28,29,30,31,32,33})
--~ 	if not result then return false end
--~ 	if count < 3 then return false end

	-- 360 热码
--~ 	result, count = redsIn({8,9,26})
--~ 	if not result then return false end
--~ 	if count > 2 then return false end

	-- 重号
	result, count = redsIn({2, 5, 11, 17, 21, 33})
--~ 	if not result then return false end
	if count > 3 then return false end

	-- 邻近
	result, count = redsIn({32, 1, 3, 4, 6, 10, 12, 16, 18, 20, 22})
	if not result then return false end
	if count > 4 then return false end

	-- 连号
	if series > 4 or seriesGroup == 3 or (series==4 and seriesGroup == 1) then return false end

	-- 组杀
	result, count = redsIn({19, 20, 21, 22, 23, 26, 27, 28, 29, 30, 31})
--~ 	if not result then return false end
	if count > 4 then return false end

	-- 组荐
	result, count = redsIn({32, 1, 3, 4, 6, 10, 12, 16, 18, 20, 22})
	if not result then return false end
	if count > 4 then return false end

	-- 公式推荐 1
	result, count = redsIn({32, 33, 1, 11, 21, 28, 29, 30, 31})
--~ 	if not result then return false end
	if count > 4 then return false end

	-- 公式推荐 2
	result, count = redsIn({9, 16, 17, 18, 19, 20, 21, 22, 29})
--~ 	if not result then return false end
	if count > 3 then return false end

	-- 公式推荐 3
	result, count = redsIn({5, 12, 13, 14, 15, 16, 17, 18, 25})
--~ 	if not result then return false end
	if count > 4 then return false end

	-- 公式推荐 4
	result, count = redsIn({4, 5, 6, 7, 8, 9, 10, 17, 27})
--~ 	if not result then return false end
	if count > 3 then return false end

	-- 公式推荐 5
	result, count = redsIn({33, 3, 10, 11, 12, 13, 14, 15, 16, 23})
--~ 	if not result then return false end
	if count > 4 then return false end

	-- 公式推荐 6
	result, count = redsIn({8, 18, 25, 26, 27, 28, 29, 30, 31})
--~ 	if not result then return false end
	if count > 3 then return false end

    return true    -- 放行
end


-- LastCheck()     :    级别: 最终过滤器
-- return true     :    放行-当前组合
-- return false    :    拦截-当前组合
function LastCheck()
    return true    -- 放行
end


function t012(value)
	result = 0

	for _,v in ipairs(s012) do
		if v == value then result = result + 1 end
	end

	return result
end

function ttail(value)
	result = 0

	for _,v in ipairs(tail) do
		if v == value then result = result + 1 end
	end

	return result
end

function tableContain(host, item)
	for _, v in ipairs(host) do
		if v ==  item then
			return true
		end
	end

	return false
end

function tableEqu(a,b)
	if #a == #b then
		for i,v in ipairs(a) do
			if a[i] ~= b[i] then return false end
		end
	else
		return false
	end

	return true
end

function tableLike(a,b)
	if #a == #b then
		table.sort(a)
		table.sort(b)
		if tableEqu(a, b) then return true end
	else
		return false
	end

	return false
end

function redsIn(sets)
	result = 0

	for _,v in ipairs(sets) do
		for _, v2 in ipairs(red) do
			if v == v2 then
				result = result + 1
				break
			end
		end
	end

	return (result~=0), result
end

function redsNotIn(sets)

	for _,v in ipairs(sets) do
		for _, v2 in ipairs(red) do
			if v == v2 then
				return false
			end
		end
	end

	return true
end

function redXIn(index, sets)

	for _,v in ipairs(sets) do
		if v==red[index] then return true end
	end

	return false
end

function red1In(sets) return redXIn(1, sets) end
function red2In(sets) return redXIn(2, sets) end
function red3In(sets) return redXIn(3, sets) end
function red4In(sets) return redXIn(4, sets) end
function red5In(sets) return redXIn(5, sets) end
function red6In(sets) return redXIn(6, sets) end

function redXNotIn(index, sets)

	for _,v in ipairs(sets) do
		if v==red[index] then return false end
	end

	return true
end

function red1NotIn(sets) return redXNotIn(1, sets) end
function red2NotIn(sets) return redXNotIn(2, sets) end
function red3NotIn(sets) return redXNotIn(3, sets) end
function red4NotIn(sets) return redXNotIn(4, sets) end
function red5NotIn(sets) return redXNotIn(5, sets) end
function red6NotIn(sets) return redXNotIn(6, sets) end

function AtSameLine()
    index = 0
    while index < 11 do
        result, count = redsIn({1+index, 12+index, 23+index})
        if count > 0 then return true end

        index = index + 1
    end
    
    return false
end
