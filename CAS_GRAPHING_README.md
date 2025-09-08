# Calculator Plugin - CAS and Graphing Features

This document describes the new Computer Algebra System (CAS) and graphing features added to the calculator plugin.

## New Features Added

### 1. Computer Algebra System (CAS)

The calculator now includes basic symbolic mathematics capabilities:

#### Available CAS Functions:

**Symbolic Differentiation:**
- `derivative("expression", "variable")` - Computes symbolic derivatives
- Default variable is "x" if not specified
- Examples:
  - `derivative("x^2")` → `"2*x"`
  - `derivative("sin(x)")` → `"cos(x)"`
  - `derivative("exp(x)")` → `"exp(x)"`

**Symbolic Integration:**
- `integrate("expression", "variable")` - Computes symbolic integrals
- Examples:
  - `integrate("x")` → `"x^2/2+C"`
  - `integrate("sin(x)")` → `"-cos(x)+C"`

**Expression Simplification:**
- `simplify("expression")` - Simplifies algebraic expressions
- Examples:
  - `simplify("x+0")` → `"x"`
  - `simplify("x*1")` → `"x"`
  - `simplify("x^0")` → `"1"`

**Expression Expansion:**
- `expand("expression")` - Expands algebraic expressions
- Examples:
  - `expand("(x+1)^2")` → `"x^2+2*x+1"`
  - `expand("(x-1)^2")` → `"x^2-2*x+1"`

**Expression Factoring:**
- `factor("expression")` - Factors algebraic expressions
- Examples:
  - `factor("x^2-y^2")` → `"(x+y)*(x-y)"`

### 2. Function Graphing

The calculator now includes a graphing interface for plotting mathematical functions:

#### Accessing the Graph Dialog:
- Click the **📈** button in the main calculator interface
- Or look for the "Graph" button in the toolbar

#### Features:
- **Function Input**: Enter any mathematical function of x (e.g., `sin(x)`, `x^2`, `cos(x)+sin(x)`)
- **Range Control**: Set custom X-axis ranges for plotting
- **Example Functions**: Quick access to common mathematical functions
- **Text-based Plot**: ASCII-style graph visualization

#### Supported Functions for Graphing:
- Trigonometric: `sin(x)`, `cos(x)`, `tan(x)`
- Exponential: `exp(x)`, `ln(x)`, `log(x)`
- Polynomial: `x^2`, `x^3`, etc.
- Combined expressions: `sin(x)+cos(x)`, `x^2-4`

## Usage Examples

### Using CAS Functions:
1. Open the calculator
2. Type a CAS function, for example:
   ```
   derivative("x^3")
   ```
3. Press Enter
4. Result: `3*x^2`

### Using the Graphing Feature:
1. Open the calculator
2. Click the **📈** button
3. Enter a function like `sin(x)` or `x^2`
4. Click "Plot" to see the graph
5. Use "Range" to adjust the viewing window
6. Use "Examples" for quick function selection

## Technical Implementation

### Files Added/Modified:
- `cas.lua` - Core CAS functionality
- `calculatorgraphdialog.lua` - Graphing interface
- `main.lua` - Added graph button and CAS integration
- `formulaparser/formulaparser.lua` - Added CAS functions to parser
- `formulaparser/parserhelp.lua` - Added CAS function implementations

### Architecture:
- **CAS Module**: Implements symbolic mathematics using pattern matching and string manipulation
- **Graph Dialog**: Creates text-based function plots using the existing formula parser
- **Integration**: CAS functions are seamlessly integrated into the existing calculator interface

## Testing

Run the test script to verify CAS functionality:
```bash
lua5.3 test_cas.lua
```

This will test all CAS functions and display example outputs.

## Future Enhancements

Potential improvements for future versions:
- More advanced symbolic operations (partial derivatives, multiple integration)
- Enhanced graphing with zoom/pan capabilities
- 3D function plotting
- Equation solving
- Matrix operations
- More sophisticated polynomial manipulation

## Compatibility

These features maintain full backward compatibility with the existing calculator functionality. All previous functions and operations continue to work as before.