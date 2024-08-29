local requests = require('cmp_ai.requests')

LlamaCPP = requests:new(nil)

function LlamaCPP:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.params = vim.tbl_deep_extend('keep', o or {}, {
    base_url = 'http://localhost:8080/completion',
    options = {
      temperature = 0.2,
      n_predict = 8,
    },
  })
  return o
end

function LlamaCPP:complete(lines_before, _lines_after, cb)
  local data = {
    prompt = lines_before,
    n_predict = self.params.options.n_predict,
  }

  -- Adaptar `Get` para usar como POST
  self:Get(self.params.base_url, {}, data, function(answer)
    local new_data = {}
    if answer.error then
      vim.notify('LlamaCPP error: ' .. answer.error.message, vim.log.levels.ERROR)
      return
    end

    if answer.content then
      local result = answer.content
      table.insert(new_data, result)
    end
    cb(new_data)
  end)
end

function LlamaCPP:test()
  self:complete('def factorial(n)\n    if', function(data)
    print(vim.inspect(data))  -- Cambié `dump` a `print(vim.inspect(data))` para que sea más estándar
  end)
end

return LlamaCPP

