#!/usr/bin/env lua5.3
--[[
Test script for Calculator CAS functions

This script demonstrates the new Computer Algebra System (CAS) functionality
added to the calculator plugin.
]]

print("Calculator CAS Functions Test")
print("=============================")

-- Set up path for testing
package.path = 'formulaparser/?.lua;' .. package.path
local Parser = require('formulaparser')

-- Test CAS demo functions that work with the calculator
print("\nWorking CAS Demo Functions:")
print("dx_x() =", Parser:eval(Parser:parse('dx_x()')))
print("dx_x2() =", Parser:eval(Parser:parse('dx_x2()')))
print("dx_x3() =", Parser:eval(Parser:parse('dx_x3()')))
print("dx_sinx() =", Parser:eval(Parser:parse('dx_sinx()')))
print("dx_cosx() =", Parser:eval(Parser:parse('dx_cosx()')))
print("dx_expx() =", Parser:eval(Parser:parse('dx_expx()')))
print("dx_lnx() =", Parser:eval(Parser:parse('dx_lnx()')))

print("\nIntegration Demo Functions:")
print("int_x() =", Parser:eval(Parser:parse('int_x()')))
print("int_x2() =", Parser:eval(Parser:parse('int_x2()')))
print("int_sinx() =", Parser:eval(Parser:parse('int_sinx()')))
print("int_cosx() =", Parser:eval(Parser:parse('int_cosx()')))
print("int_expx() =", Parser:eval(Parser:parse('int_expx()')))

print("\nExpansion Demo:")
print("expand_demo() =", Parser:eval(Parser:parse('expand_demo()')))

print("\nDirect CAS Module Tests (for reference):")
local CAS = require('formulaparser/cas')
print("CAS.derivative('x^2', 'x') =", CAS.derivative('x^2', 'x'))
print("CAS.integrate('x', 'x') =", CAS.integrate('x', 'x'))
print("CAS.simplify('x+0') =", CAS.simplify('x+0'))
print("CAS.expand('(x+1)^2') =", CAS.expand('(x+1)^2'))

print("\nAll tests completed!")
print("\nTo use these functions in the calculator:")
print("1. Start the calculator")
print("2. Type CAS demo functions like: dx_x2()")
print("3. Press Enter to see the symbolic result")
print("4. Use the 📈 button to access graphing functionality")
print("5. Try typing 'help()' to see all available functions")