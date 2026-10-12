return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            -- Make breakpoints and the current execution line visible
            vim.fn.sign_define("DapBreakpoint", {
                text = "●",
                texthl = "DiagnosticSignError",
            })

            vim.fn.sign_define("DapStopped", {
                text = "➜",
                texthl = "DiagnosticSignInfo",
                linehl = "Visual",
                numhl = "",
            })

            dap.adapters.coreclr = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
                args = { "--interpreter=vscode" },
            }

            dap.configurations.cs = {
                {
                    type = "coreclr",
                    name = "Launch compiled .NET assembly",
                    request = "launch",
                    program = function()
                        local cwd = vim.fn.getcwd()

                        local result = vim.system({
                            "dotnet",
                            "msbuild",
                            "-getProperty:OutputType",
                            "-getProperty:TargetPath",
                            "-property:Configuration=Debug",
                        }, {
                            cwd = cwd,
                            text = true,
                        }):wait()

                        if result.code ~= 0 then
                            vim.notify(
                                "Could not resolve .NET project in " .. cwd
                                .. "\n" .. (result.stderr or ""),
                                vim.log.levels.ERROR
                            )
                            return nil
                        end

                        local ok, data = pcall(vim.json.decode, result.stdout or "")
                        if not ok or type(data) ~= "table" or type(data.Properties) ~= "table" then
                            vim.notify("Unexpected MSBuild output", vim.log.levels.ERROR)
                            return nil
                        end

                        local props = data.Properties

                        if props.OutputType ~= "Exe" and props.OutputType ~= "WinExe" then
                            vim.notify(
                                "Not a runnable .NET project: " .. cwd,
                                vim.log.levels.ERROR
                            )
                            return nil
                        end

                        local dll = props.TargetPath
                        if type(dll) ~= "string" or vim.fn.filereadable(dll) ~= 1 then
                            vim.notify(
                                "Debug DLL not found. Run dotnet build -c Debug first.",
                                vim.log.levels.ERROR
                            )
                            return nil
                        end

                        return dll
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtEntry = false,
                },
            }

            local map = vim.keymap.set

            map("n", "<F5>", dap.continue, { desc = "Debug: start/continue" })
            map("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
            map("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
            map("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
            map("n", "<S-F11>", dap.step_out, { desc = "Debug: step out" })
            map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
            map("n", "<leader>dr", dap.repl.open, { desc = "Debug: REPL" })
            map("n", "<leader>dt", dap.terminate, { desc = "Debug: terminate" })
        end,
    },
}
