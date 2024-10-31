local Job = require("plenary.job")

local M = {}

function M.fetch(use_cache, config, success_cb, error_cb, set_job)
	if use_cache and vim.fn.filereadable(config.cache_path) == 1 then
		vim.schedule(function()
			success_cb(vim.fn.json_decode(vim.fn.readfile(config.cache_path)))
		end)

		print("Used cache (" .. config.cache_path .. ")")

		return
	end

	local fetch_job = nil

	fetch_job = Job:new({
		command = "curl",
		args = {
			"https://api.imagekit.io/v1/files",
			"-H",
			"Accept: application/json",
			"-u",
			config.api_key .. ":",
		},
		-- TODO: Fix error handling
		-- on_stderr = function(err)
		-- 	vim.schedule(function()
		-- 		error_cb({ "Error:", err })
		-- 	end)
		-- end,
		on_exit = function(self, _, signal)
			if signal == 2 then
				return
			end

			local result = self:result()

			vim.schedule(function()
				success_cb(vim.fn.json_decode(result))
			end)

			vim.schedule(function()
				vim.fn.writefile(result, config.cache_path)
				print("Cache written to (" .. config.cache_path .. ")")
			end)

			fetch_job = nil
			set_job(nil)
		end,
	})

	fetch_job:start()

	set_job(fetch_job)
end

return M
