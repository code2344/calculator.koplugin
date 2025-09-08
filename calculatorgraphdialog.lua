--[[--
This widget displays the calculator graphing dialog
]]

local Blitbuffer = require("ffi/blitbuffer")
local ButtonTable = require("ui/widget/buttontable")
local CenterContainer = require("ui/widget/container/centercontainer")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local InputContainer = require("ui/widget/container/inputcontainer")
local InputDialog = require("ui/widget/inputdialog")
local LineWidget = require("ui/widget/linewidget")
local MovableContainer = require("ui/widget/container/movablecontainer")
local Size = require("ui/size")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Widget = require("ui/widget/widget")
local _ = require("gettext")
local Screen = require("device").screen
local logger = require("logger")

local Parser = require("formulaparser/formulaparser")

-- Custom GraphWidget for drawing mathematical plots
local GraphWidget = Widget:new{
    function_expr = "sin(x)",
    x_min = -10,
    x_max = 10,
    y_min = -5,
    y_max = 5,
    plot_points = 200,
    grid_color = Blitbuffer.COLOR_GRAY_E,
    axis_color = Blitbuffer.COLOR_BLACK,
    curve_color = Blitbuffer.COLOR_BLUE,
    margin = 30,
}

function GraphWidget:init()
    self.dimen = Geom:new{
        w = self.width or 400,
        h = self.height or 300,
    }
end

function GraphWidget:paintTo(bb, x, y)
    -- Clear the drawing area
    bb:paintRect(x, y, self.dimen.w, self.dimen.h, Blitbuffer.COLOR_WHITE)
    
    -- Calculate plot area (leave margins for labels)
    local plot_x = x + self.margin
    local plot_y = y + self.margin
    local plot_w = self.dimen.w - 2 * self.margin
    local plot_h = self.dimen.h - 2 * self.margin
    
    -- Draw border around plot area
    bb:paintBorder(plot_x, plot_y, plot_w, plot_h, 1, self.axis_color)
    
    -- Calculate coordinate transformations
    local x_scale = plot_w / (self.x_max - self.x_min)
    local y_scale = plot_h / (self.y_max - self.y_min)
    
    -- Helper function to convert math coordinates to screen coordinates
    local function math_to_screen(mx, my)
        local sx = plot_x + (mx - self.x_min) * x_scale
        local sy = plot_y + plot_h - (my - self.y_min) * y_scale  -- Flip Y axis
        return math.floor(sx), math.floor(sy)
    end
    
    -- Draw grid lines
    local grid_step_x = (self.x_max - self.x_min) / 10
    local grid_step_y = (self.y_max - self.y_min) / 10
    
    -- Vertical grid lines
    for i = 0, 10 do
        local mx = self.x_min + i * grid_step_x
        local sx1, sy1 = math_to_screen(mx, self.y_min)
        local sx2, sy2 = math_to_screen(mx, self.y_max)
        bb:paintRect(sx1, sy1, 1, sy2 - sy1, self.grid_color)
    end
    
    -- Horizontal grid lines
    for i = 0, 10 do
        local my = self.y_min + i * grid_step_y
        local sx1, sy1 = math_to_screen(self.x_min, my)
        local sx2, sy2 = math_to_screen(self.x_max, my)
        bb:paintRect(sx1, sy1, sx2 - sx1, 1, self.grid_color)
    end
    
    -- Draw axes if they're in the visible range
    if self.x_min <= 0 and self.x_max >= 0 then
        -- Y-axis
        local sx1, sy1 = math_to_screen(0, self.y_min)
        local sx2, sy2 = math_to_screen(0, self.y_max)
        bb:paintRect(sx1, sy1, 2, sy2 - sy1, self.axis_color)
    end
    
    if self.y_min <= 0 and self.y_max >= 0 then
        -- X-axis
        local sx1, sy1 = math_to_screen(self.x_min, 0)
        local sx2, sy2 = math_to_screen(self.x_max, 0)
        bb:paintRect(sx1, sy1, sx2 - sx1, 2, self.axis_color)
    end
    
    -- Plot the function
    local step = (self.x_max - self.x_min) / self.plot_points
    local prev_sx, prev_sy = nil, nil
    local point_count = 0
    
    for i = 0, self.plot_points do
        local mx = self.x_min + i * step
        local expr = self.function_expr:gsub("x", tostring(mx))
        local result = Parser:eval(Parser:parse(expr))
        
        if result and type(result) == "number" and math.finite(result) and 
           result >= self.y_min and result <= self.y_max then
            local sx, sy = math_to_screen(mx, result)
            
            -- Draw point
            bb:paintRect(sx - 1, sy - 1, 3, 3, self.curve_color)
            
            -- Draw line to previous point if exists
            if prev_sx and prev_sy then
                self:drawLine(bb, prev_sx, prev_sy, sx, sy, self.curve_color)
            end
            
            prev_sx, prev_sy = sx, sy
            point_count = point_count + 1
        else
            -- Break the line for discontinuities
            prev_sx, prev_sy = nil, nil
        end
    end
end

-- Simple line drawing using Bresenham's algorithm
function GraphWidget:drawLine(bb, x0, y0, x1, y1, color)
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy
    
    while true do
        if x0 >= 0 and y0 >= 0 and x0 < self.dimen.w and y0 < self.dimen.h then
            bb:paintRect(x0, y0, 1, 1, color)
        end
        
        if x0 == x1 and y0 == y1 then break end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x0 = x0 + sx
        end
        if e2 < dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
end

function GraphWidget:setFunction(func_expr)
    self.function_expr = func_expr
end

function GraphWidget:setRange(x_min, x_max, y_min, y_max)
    self.x_min = x_min or self.x_min
    self.x_max = x_max or self.x_max
    self.y_min = y_min or self.y_min
    self.y_max = y_max or self.y_max
end

local CalculatorGraphDialog = InputContainer:new{
    is_always_active = true,
    title = _("Function Graphing"),
    modal = true,
    stop_events_propagation = true,
    width = math.floor(Screen:getWidth() * 0.9),
    height = math.floor(Screen:getHeight() * 0.8),
    face = Font:getFace("cfont", 20),
    border_size = Size.border.window,
    graph_function = "sin(x)",
    x_min = -10,
    x_max = 10,
    y_min = -5,
    y_max = 5,
    plot_points = 100,
}

function CalculatorGraphDialog:init()
    -- Calculate graph area dimensions
    self.graph_width = self.width - 100
    self.graph_height = self.height - 150
    
    -- Create the graphical graph widget
    self.graph_widget = GraphWidget:new{
        width = self.graph_width,
        height = self.graph_height,
        function_expr = self.graph_function,
        x_min = self.x_min,
        x_max = self.x_max,
        y_min = self.y_min,
        y_max = self.y_max,
    }
    
    -- Create the graph area container
    self.graph_area = FrameContainer:new{
        background = Blitbuffer.COLOR_WHITE,
        bordersize = 2,
        width = self.graph_width,
        height = self.graph_height,
        padding = 0,
        margin = 0,
        self.graph_widget,
    }
    
    -- Create input field for function
    local function_input = InputDialog:new{
        title = _("Enter function of x:"),
        input = self.graph_function,
        input_hint = _("e.g. sin(x), x^2, cos(x)+sin(x)"),
        buttons = {
            {
                {
                    text = _("Cancel"),
                    id = "close",
                    callback = function()
                        UIManager:close(function_input)
                    end,
                },
                {
                    text = _("Plot"),
                    callback = function()
                        self.graph_function = function_input:getInputText()
                        UIManager:close(function_input)
                        self:updateGraph()
                    end,
                },
            }
        },
    }
    
    -- Create buttons
    local buttons = {
        {
            {
                text = _("Function"),
                callback = function()
                    UIManager:show(function_input)
                end,
            },
            {
                text = _("Range"),
                callback = function()
                    self:showRangeDialog()
                end,
            },
            {
                text = _("Examples"),
                callback = function()
                    self:showExamplesDialog()
                end,
            },
            {
                text = _("Close"),
                callback = function()
                    UIManager:close(self)
                end,
            },
        }
    }
    
    self.button_table = ButtonTable:new{
        buttons = buttons,
        zero_sep = true,
        show_parent = self,
    }
    
    -- Main content
    self.function_text = TextWidget:new{
        text = string.format("f(x) = %s", self.graph_function),
        face = Font:getFace("cfont", 16),
    }
    
    self[1] = FrameContainer:new{
        background = Blitbuffer.COLOR_WHITE,
        bordersize = 0,
        padding = Size.padding.default,
        CenterContainer:new{
            dimen = Geom:new{
                w = self.width,
                h = self.height,
            },
            VerticalGroup:new{
                align = "center",
                TextWidget:new{
                    text = self.title,
                    face = self.face,
                },
                VerticalSpan:new{ width = Size.span.vertical_default },
                self.function_text,
                VerticalSpan:new{ width = Size.span.vertical_default },
                self.graph_area,
                VerticalSpan:new{ width = Size.span.vertical_default },
                self.button_table,
            }
        }
    }
end

function CalculatorGraphDialog:updateGraph()
    -- Update the graph widget with new parameters
    self.graph_widget:setFunction(self.graph_function)
    self.graph_widget:setRange(self.x_min, self.x_max, self.y_min, self.y_max)
    
    -- Trigger a refresh of the display
    UIManager:setDirty(self, "ui")
    
    -- Update the function display text
    self.function_text:setText(string.format("f(x) = %s", self.graph_function))
end

function CalculatorGraphDialog:showRangeDialog()
    local range_input = InputDialog:new{
        title = _("Set X Range"),
        input = string.format("%.1f,%.1f", self.x_min, self.x_max),
        input_hint = _("Enter x_min,x_max (e.g. -5,5)"),
        buttons = {
            {
                {
                    text = _("Cancel"),
                    callback = function()
                        UIManager:close(range_input)
                    end,
                },
                {
                    text = _("Apply"),
                    callback = function()
                        local input_text = range_input:getInputText()
                        local x_min, x_max = input_text:match("([%d%-%.]+),([%d%-%.]+)")
                        if x_min and x_max then
                            self.x_min = tonumber(x_min)
                            self.x_max = tonumber(x_max)
                            UIManager:close(range_input)
                            self:updateGraph()
                        end
                    end,
                },
            }
        },
    }
    UIManager:show(range_input)
end

function CalculatorGraphDialog:showExamplesDialog()
    local examples = {
        "sin(x)",
        "cos(x)", 
        "tan(x)",
        "x^2",
        "x^3",
        "sqrt(x)",
        "exp(x)",
        "ln(x)",
        "sin(x)+cos(x)",
        "x^2-4",
    }
    
    local buttons = {}
    for i = 1, #examples, 2 do
        local row = {}
        table.insert(row, {
            text = examples[i],
            callback = function()
                self.graph_function = examples[i]
                self:updateGraph()
                UIManager:close(self.examples_dialog)
            end,
        })
        if examples[i+1] then
            table.insert(row, {
                text = examples[i+1],
                callback = function()
                    self.graph_function = examples[i+1]
                    self:updateGraph()
                    UIManager:close(self.examples_dialog)
                end,
            })
        end
        table.insert(buttons, row)
    end
    
    table.insert(buttons, {{
        text = _("Close"),
        callback = function()
            UIManager:close(self.examples_dialog)
        end,
    }})
    
    self.examples_dialog = ButtonTable:new{
        title = _("Example Functions"),
        buttons = buttons,
        tap_close_callback = function()
            UIManager:close(self.examples_dialog)
        end,
    }
    
    UIManager:show(self.examples_dialog)
end

return CalculatorGraphDialog