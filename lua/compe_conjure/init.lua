local Source = {}
local conjure_eval = require'conjure.eval'
local conjure_promise = require'conjure.promise'
local util = require'vim.lsp.util'

function Source.new()
  local self = setmetatable({}, { __index = Source })
  self.timer = nil
  self.promise_id = nil
  return self
end

function Source.get_metadata(self)
  return {
    priority = 1000;
    filetypes = vim.g.compe_conjure_fts or {"fennel", "janet", "racket", "clojure"};
    dub = 0;
    menu = '[conjure]';
  }
end

function Source.determine(self, context)
  local offset = vim.regex('[0-9a-zA-Z.!$%&*+/:<=>?#_~\\^\\-\\\\]\\+$'):match_str(context.before_line)
  if not offset then return {} end

  local trigger

  if vim.fn.index({'.'}, context.before_char) >= 0 or vim.fn.index({'/'}, context.before_char) >= 0 then
    trigger = context.col
  else
    trigger = -1
  end

  return {
    keyword_pattern_offset = offset + 1,
    trigger_character_offset =  trigger
  }
end

function Source.complete(self, args)
  self:abort()
  local input = args.context:get_input(args.keyword_pattern_offset)
  self.promise_id = conjure_eval['completions-promise'](input)
  self.timer = vim.loop.new_timer()
  self.timer:start(100, 100, vim.schedule_wrap(function()
    if conjure_promise['done?'](self.promise_id) then
      args.callback({
        items = conjure_promise.close(self.promise_id)
      })
      self:abort()
    end
  end))
end

function Source.documentation(self, args)
  local document = {}
  local content = args.completed_item.info
  -- if content ~= '' then
  --   table.insert(document, '```' .. vim.bo.filetype .. '\n')
  --   for _, v in ipairs(vim.split(content, "\n")) do
  --     table.insert(document, v)
  --   end
  --   table.insert(document, '```')
  --   -- print(vim.inspect(document))
  -- end
  if content ~= '' then
    args.callback(content)
  else
    args.abort()
  end
end

function Source.abort(self)
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

return Source.new()

