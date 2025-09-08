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
local _ = require("gettext")
local Screen = require("device").screen
local logger = require("logger")

local Parser = require("formulaparser/formulaparser")

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
    
    -- Create the graph area
    self.graph_area = FrameContainer:new{
        background = Blitbuffer.COLOR_WHITE,
        bordersize = 2,
        width = self.graph_width,
        height = self.graph_height,
        padding = 0,
        margin = 0,
    }
    
    -- Draw the graph
    self:drawGraph()
    
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
                        self:drawGraph()
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
                TextWidget:new{
                    text = string.format("f(x) = %s", self.graph_function),
                    face = Font:getFace("cfont", 16),
                },
                VerticalSpan:new{ width = Size.span.vertical_default },
                self.graph_area,
                VerticalSpan:new{ width = Size.span.vertical_default },
                self.button_table,
            }
        }
    }
end

function CalculatorGraphDialog:drawGraph()
    -- Create a simple ASCII-style graph
    local graph_lines = {}
    local step = (self.x_max - self.x_min) / self.plot_points
    
    -- Calculate y values
    local points = {}
    local y_values = {}
    
    for i = 0, self.plot_points do
        local x = self.x_min + i * step
        local expr = self.graph_function:gsub("x", tostring(x))
        local result = Parser:eval(Parser:parse(expr))
        
        if result and type(result) == "number" and math.finite(result) then
            table.insert(points, {x = x, y = result})
            table.insert(y_values, result)
        end
    end
    
    if #points == 0 then
        graph_lines = {"Error: Could not evaluate function"}
    else
        -- Auto-scale y range if needed
        local min_y = math.min(table.unpack(y_values))
        local max_y = math.max(table.unpack(y_values))
        
        if min_y == max_y then
            min_y = min_y - 1
            max_y = max_y + 1
        end
        
        -- Create simple text-based graph representation
        local graph_height_chars = 20
        local graph_width_chars = 60
        
        local graph_matrix = {}
        for y = 1, graph_height_chars do
            graph_matrix[y] = {}
            for x = 1, graph_width_chars do
                graph_matrix[y][x] = " "
            end
        end
        
        -- Plot points
        for _, point in ipairs(points) do
            local screen_x = math.floor((point.x - self.x_min) / (self.x_max - self.x_min) * (graph_width_chars - 1)) + 1
            local screen_y = math.floor((max_y - point.y) / (max_y - min_y) * (graph_height_chars - 1)) + 1
            
            if screen_x >= 1 and screen_x <= graph_width_chars and 
               screen_y >= 1 and screen_y <= graph_height_chars then
                graph_matrix[screen_y][screen_x] = "*"
            end
        end
        
        -- Draw axes if they're in range
        local zero_x = math.floor((0 - self.x_min) / (self.x_max - self.x_min) * (graph_width_chars - 1)) + 1
        local zero_y = math.floor((max_y - 0) / (max_y - min_y) * (graph_height_chars - 1)) + 1
        
        if zero_x >= 1 and zero_x <= graph_width_chars then
            for y = 1, graph_height_chars do
                if graph_matrix[y][zero_x] == " " then
                    graph_matrix[y][zero_x] = "|"
                end
            end
        end
        
        if zero_y >= 1 and zero_y <= graph_height_chars then
            for x = 1, graph_width_chars do
                if graph_matrix[zero_y][x] == " " then
                    graph_matrix[zero_y][x] = "-"
                end
            end
        end
        
        -- Convert matrix to strings
        for y = 1, graph_height_chars do
            table.insert(graph_lines, table.concat(graph_matrix[y]))
        end
        
        -- Add axis labels
        table.insert(graph_lines, string.format("X: %.2f to %.2f, Y: %.2f to %.2f", 
                     self.x_min, self.x_max, min_y, max_y))
    end
    
    -- Update graph area with text representation
    local graph_text = table.concat(graph_lines, "\n")
    self.graph_area[1] = TextWidget:new{
        text = graph_text,
        face = Font:getFace("infont", 12),
        para_direction_rtl = false,
    }
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
                            self:drawGraph()
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
                self:drawGraph()
                UIManager:close(self.examples_dialog)
            end,
        })
        if examples[i+1] then
            table.insert(row, {
                text = examples[i+1],
                callback = function()
                    self.graph_function = examples[i+1]
                    self:drawGraph()
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