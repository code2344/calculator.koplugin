--[[
Computer Algebra System (CAS) Functions for Calculator Plugin

This module provides basic symbolic mathematics capabilities:
- Symbolic differentiation 
- Basic integration
- Expression simplification
- Polynomial operations

Author: GitHub Copilot
Version: 1.0.0
]]

local CAS = {}

-- Error messages
local err_no_val = "Value expected!"
local err_invalid_expr = "Invalid expression for symbolic operation!"
local err_no_var = "Variable not specified!"

-- Basic symbolic differentiation
-- For now, we'll handle simple cases: polynomials, trig functions, exponentials
function CAS.derivative(expr, variable)
    if not expr or not variable then
        return nil, err_no_val
    end
    
    -- For this minimal implementation, we'll handle string expressions
    -- and return symbolic results as strings
    local expr_str = tostring(expr)
    local var_str = tostring(variable)
    
    -- Simple pattern matching for basic derivatives
    -- d/dx(x^n) = n*x^(n-1)
    local power_pattern = var_str .. "%^(%d+)"
    local coefficient, power = expr_str:match("(%d*)%*?" .. power_pattern)
    if power then
        coefficient = coefficient == "" and 1 or tonumber(coefficient)
        power = tonumber(power)
        if power == 1 then
            return tostring(coefficient)
        elseif power == 2 then
            return tostring(coefficient * power) .. "*" .. var_str
        else
            return tostring(coefficient * power) .. "*" .. var_str .. "^" .. tostring(power - 1)
        end
    end
    
    -- d/dx(x) = 1
    if expr_str == var_str then
        return "1"
    end
    
    -- d/dx(sin(x)) = cos(x)
    if expr_str:match("sin%(" .. var_str .. "%)") then
        return "cos(" .. var_str .. ")"
    end
    
    -- d/dx(cos(x)) = -sin(x)  
    if expr_str:match("cos%(" .. var_str .. "%)") then
        return "-sin(" .. var_str .. ")"
    end
    
    -- d/dx(exp(x)) = exp(x)
    if expr_str:match("exp%(" .. var_str .. "%)") then
        return "exp(" .. var_str .. ")"
    end
    
    -- d/dx(ln(x)) = 1/x
    if expr_str:match("ln%(" .. var_str .. "%)") then
        return "1/" .. var_str
    end
    
    -- d/dx(constant) = 0
    if not expr_str:find(var_str) then
        return "0"
    end
    
    -- Default case - return symbolic notation
    return "d/d" .. var_str .. "(" .. expr_str .. ")"
end

-- Basic symbolic integration
function CAS.integrate(expr, variable)
    if not expr or not variable then
        return nil, err_no_val
    end
    
    local expr_str = tostring(expr)
    local var_str = tostring(variable)
    
    -- ∫x^n dx = x^(n+1)/(n+1) + C
    local power_pattern = var_str .. "%^(%d+)"
    local coefficient, power = expr_str:match("(%d*)%*?" .. power_pattern)
    if power then
        coefficient = coefficient == "" and 1 or tonumber(coefficient)
        power = tonumber(power)
        local new_power = power + 1
        local new_coeff = coefficient / new_power
        if new_power == 1 then
            return tostring(new_coeff) .. "*" .. var_str .. "+C"
        else
            return tostring(new_coeff) .. "*" .. var_str .. "^" .. tostring(new_power) .. "+C"
        end
    end
    
    -- ∫x dx = x^2/2 + C
    if expr_str == var_str then
        return var_str .. "^2/2+C"
    end
    
    -- ∫sin(x) dx = -cos(x) + C
    if expr_str:match("sin%(" .. var_str .. "%)") then
        return "-cos(" .. var_str .. ")+C"
    end
    
    -- ∫cos(x) dx = sin(x) + C
    if expr_str:match("cos%(" .. var_str .. "%)") then
        return "sin(" .. var_str .. ")+C"
    end
    
    -- ∫exp(x) dx = exp(x) + C
    if expr_str:match("exp%(" .. var_str .. "%)") then
        return "exp(" .. var_str .. ")+C"
    end
    
    -- ∫1/x dx = ln(|x|) + C
    if expr_str == "1/" .. var_str then
        return "ln(abs(" .. var_str .. "))+C"
    end
    
    -- ∫constant dx = constant*x + C
    if not expr_str:find(var_str) then
        return expr_str .. "*" .. var_str .. "+C"
    end
    
    -- Default case - return symbolic notation
    return "∫(" .. expr_str .. ")d" .. var_str
end

-- Basic expression simplification
function CAS.simplify(expr)
    if not expr then
        return nil, err_no_val
    end
    
    local expr_str = tostring(expr)
    
    -- Simple algebraic simplifications
    -- x + 0 = x, 0 + x = x
    expr_str = expr_str:gsub("([%w_]+)%+0", "%1")
    expr_str = expr_str:gsub("0%+([%w_]+)", "%1")
    
    -- x - 0 = x
    expr_str = expr_str:gsub("([%w_]+)%-0", "%1")
    
    -- x * 1 = x, 1 * x = x
    expr_str = expr_str:gsub("([%w_]+)%*1", "%1")
    expr_str = expr_str:gsub("1%*([%w_]+)", "%1")
    
    -- x * 0 = 0, 0 * x = 0
    expr_str = expr_str:gsub("([%w_]+)%*0", "0")
    expr_str = expr_str:gsub("0%*([%w_]+)", "0")
    
    -- x / 1 = x
    expr_str = expr_str:gsub("([%w_]+)/1", "%1")
    
    -- x^1 = x
    expr_str = expr_str:gsub("([%w_]+)%^1", "%1")
    
    -- x^0 = 1
    expr_str = expr_str:gsub("([%w_]+)%^0", "1")
    
    return expr_str
end

-- Expand polynomial expressions (basic)
function CAS.expand(expr)
    if not expr then
        return nil, err_no_val
    end
    
    local expr_str = tostring(expr)
    
    -- Handle (a+b)^2 = a^2 + 2ab + b^2
    local a, b = expr_str:match("%(([%w_]+)%+([%w_]+)%)%^2")
    if a and b then
        if b == "1" then
            return a .. "^2+2*" .. a .. "+1"
        else
            return a .. "^2+2*" .. a .. "*" .. b .. "+" .. b .. "^2"
        end
    end
    
    -- Handle (a-b)^2 = a^2 - 2ab + b^2
    a, b = expr_str:match("%(([%w_]+)%-([%w_]+)%)%^2")
    if a and b then
        if b == "1" then
            return a .. "^2-2*" .. a .. "+1"
        else
            return a .. "^2-2*" .. a .. "*" .. b .. "+" .. b .. "^2"
        end
    end
    
    -- Handle (a+b)(c+d) = ac + ad + bc + bd
    local a1, b1, c1, d1 = expr_str:match("%(([%w_]+)%+([%w_]+)%)%*%(([%w_]+)%+([%w_]+)%)")
    if a1 and b1 and c1 and d1 then
        return a1 .. "*" .. c1 .. "+" .. a1 .. "*" .. d1 .. "+" .. b1 .. "*" .. c1 .. "+" .. b1 .. "*" .. d1
    end
    
    -- If no patterns match, return original
    return expr_str
end

-- Factor simple expressions
function CAS.factor(expr)
    if not expr then
        return nil, err_no_val
    end
    
    local expr_str = tostring(expr)
    
    -- Handle x^2 - y^2 = (x+y)(x-y)
    local a, b = expr_str:match("([%w_]+)%^2%-([%w_]+)%^2")
    if a and b then
        return "(" .. a .. "+" .. b .. ")*(" .. a .. "-" .. b .. ")"
    end
    
    -- Handle ax + bx = x(a + b)
    local coeff1, var1, coeff2, var2 = expr_str:match("(%d*)%*?([%w_]+)%+(%d*)%*?([%w_]+)")
    if var1 == var2 then
        coeff1 = coeff1 == "" and "1" or coeff1
        coeff2 = coeff2 == "" and "1" or coeff2
        return var1 .. "*(" .. coeff1 .. "+" .. coeff2 .. ")"
    end
    
    return expr_str
end

return CAS