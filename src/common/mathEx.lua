local math = require("math")

local mathEx = {}

--小数四舍五入，正数有效
--mathEx:round(1.3) == 1   math.floor(1.3) == 1
--mathEx:round(1.5) == 2   math.floor(1.5) == 1
--mathEx:round(-1.5) == -1  math.floor(-1.3) == -2    math.floor(-1.5) == -2
function mathEx:round(num)  
    return math.floor(num + 0.5)
end
function mathEx:getIntPart(x)
    if x <= 0 then
        return math.ceil(x);
    end

    if math.ceil(x) == x then
        x = math.ceil(x);
    else
        x = math.ceil(x) - 1;
    end
    return x;
end

return mathEx