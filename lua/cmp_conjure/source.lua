local conjure_eval = require("conjure.eval")
local conjure_promise = require("conjure.promise")
local util = require("vim.lsp.util")

local source = {}

---Return this source is available in current context or not. (Optional)
---@return boolean
function source:is_available()
	return true
end

---Return the debug name of this source. (Optional)
---@return string
function source:get_debug_name()
	return "conjure"
end

function source:new()
	local self = setmetatable({}, { __index = source })

	self.timer = nil
	self.promise_id = nil

	return self
end

function source:get_metadata(self)
	return {
		priority = 1000,
		filetypes = vim.g.compe_conjure_fts or { "fennel", "janet", "racket", "clojure" },
		dub = 0,
		menu = "[Conjure]",
	}
end

function source:determine(self, context)
	local offset = vim.regex("[0-9a-zA-Z.!$%&*+/:<=>?#_~\\^\\-\\\\]\\+$"):match_str(context.before_line)
	if not offset then
		return {}
	end

	local trigger

	if vim.fn.index({ "." }, context.before_char) >= 0 or vim.fn.index({ "/" }, context.before_char) >= 0 then
		trigger = context.col
	else
		trigger = -1
	end

	return {
		keyword_pattern_offset = offset + 1,
		trigger_character_offset = trigger,
	}
end

---Invoke completion. (Required)
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	self:abort()
	local input = params.context:get_input(params.keyword_pattern_offset)
	self.promise_id = conjure_eval["completions-promise"](input)
	self.timer = vim.loop.new_timer()
	self.timer:start(
		100,
		100,
		vim.schedule_wrap(function()
			if conjure_promise["done?"](self.promise_id) then
				callback({
					items = conjure_promise.close(self.promise_id),
				})
				self:abort()
			end
		end)
	)
end

-- function source:documentation(params, callback)
-- 	local document = {}
-- 	local content = params.completed_item.info
-- 	-- if content ~= '' then
-- 	--   table.insert(document, '```' .. vim.bo.filetype .. '\n')
-- 	--   for _, v in ipairs(vim.split(content, "\n")) do
-- 	--     table.insert(document, v)
-- 	--   end
-- 	--   table.insert(document, '```')
-- 	--   -- print(vim.inspect(document))
-- 	-- end
-- 	if content ~= "" then
-- 		callback(content)
-- 	else
-- 		self:abort()
-- 	end
-- end

function source:abort()
	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end
	if self.promise_id then
		conjure_promise.close(self.promise_id)
		self.promise_id = nil
	end
end

---Resolve completion item. (Optional)
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
    callback(completion_item)
end

---Execute command after item was accepted.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
    callback(completion_item)
end

return source
