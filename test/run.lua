#!/usr/bin/env texlua
-- Test runner for runtexshebang.lua.  Run with:  texlua test/run.lua
-- No dependencies beyond texlua itself (lfs is built into LuaTeX).

local script_dir = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local function abspath(p)
  if p:match("^/") or p:match("^%a:[/\\]") then return p end
  return lfs.currentdir() .. "/" .. p
end
local SCRIPT = abspath(script_dir .. "/../runtexshebang.lua")
local TMP = abspath(script_dir .. "/tmp")
local is_windows = os.type == "windows"

lfs.mkdir(TMP)
assert(lfs.chdir(TMP), "cannot chdir to " .. TMP)

-- ---------------------------------------------------------------- helpers
local function q(s) return '"' .. s .. '"' end

-- Run runtexshebang.lua with the given argument list.
-- Returns { out = stdout, err = stderr, code = exit status }.
local function run(args)
  local errfile = "stderr.txt"
  local parts = { "texlua", q(SCRIPT) }
  for _, a in ipairs(args) do parts[#parts + 1] = q(a) end
  local cmdline = table.concat(parts, " ") .. " 2>" .. errfile
  local p = assert(io.popen(cmdline, "r"))
  local out = p:read("a")
  local ok, how, code = p:close()
  if ok == true then code = 0 end
  local ef = io.open(errfile, "rb")
  local err = ef and ef:read("a") or ""
  if ef then ef:close() end
  os.remove(errfile)
  return { out = out, err = err, code = code }
end

local created = {}
local function write_file(name, content)
  local f = assert(io.open(name, "wb"))
  f:write(content)
  f:close()
  created[#created + 1] = name
  return name
end

local failures, total, current = {}, 0, ""
local function fail(label, msg)
  failures[#failures + 1] = string.format("[%s] %s: %s", current, label, msg)
end
local function show(s) return (string.format("%q", tostring(s)):gsub("\\\n", "\\n")) end
local function eq(got, want, label)
  if got ~= want then fail(label, "expected " .. show(want) .. ", got " .. show(got)) end
end
local function contains(s, sub, label)
  if not string.find(s, sub, 1, true) then fail(label, "expected to contain " .. show(sub) .. " in " .. show(s)) end
end
local function not_contains(s, sub, label)
  if string.find(s, sub, 1, true) then fail(label, "must not contain " .. show(sub) .. " in " .. show(s)) end
end

local cases = {}
local function case(name, fn) cases[#cases + 1] = { name = name, fn = fn } end

-- ------------------------------------------------------------------ cases
local banner = run({ "--version" }).out:gsub("%s+$", "")
assert(banner:match("^runtexshebang "), "cannot get version banner: " .. banner)

local lines20 = {}
for i = 1, 20 do lines20[i] = "%%" .. i end
local twenty = table.concat(lines20, "\n") .. "\n"

case("option_help", function()
  for _, opt in ipairs({ "--help", "-help", "-h" }) do
    local r = run({ opt })
    eq(r.code, 0, opt .. " exit")
    contains(r.out, banner .. "\n\nUsage:", opt .. " stdout")
  end
  local r = run({})
  eq(r.code, 0, "no args exit")
  contains(r.out, "Usage:", "no args prints help")
end)

case("option_version", function()
  for _, opt in ipairs({ "--version", "-version", "-v" }) do
    local r = run({ opt })
    eq(r.code, 0, opt .. " exit")
    eq(r.out, banner .. "\n", opt .. " stdout")
  end
end)

case("option_dryrun", function()
  for _, opt in ipairs({ "--dry-run", "-dry-run" }) do
    local r = run({ opt })
    eq(r.code, 1, opt .. " without file: exit")
    contains(r.err, "No filename argument given", opt .. " without file: stderr")
  end
  write_file("dryrun.tex", "%#!texlua\n")
  local r = run({ "--dry-run", "dryrun.tex" })
  eq(r.code, 0, "dry-run exit")
  eq(r.out, banner .. "\ntexlua\n", "dry-run stdout has no trailing blank line")
  eq(r.err, "", "dry-run stderr is empty")
end)

case("shebang_matched", function()
  write_file("m1.tex", "%#!echo This is a TeX-style shebang line.\n")
  local r = run({ "m1.tex" })
  eq(r.code, 0, "exit")
  eq(r.out, banner .. "\nThis is a TeX-style shebang line.\n", "stdout")

  write_file("m2.tex", "% #!echo TeX-style shebang: line 1\n%#!echo TeX-style shebang: line 2\n")
  r = run({ "m2.tex" })
  eq(r.code, 0, "second line exit")
  eq(r.out, banner .. "\nTeX-style shebang: line 2\n", "disabled first line is skipped")

  -- "%#!texlua" runs texlua without a script; whatever it prints and
  -- returns must be passed through unchanged.
  local p = io.popen("texlua 2>&1", "r")
  local texlua_out = p:read("a")
  local ok, _, texlua_code = p:close()
  if ok == true then texlua_code = 0 end
  write_file("m3.tex", "%#!texlua\n")
  r = run({ "m3.tex" })
  eq(r.code, texlua_code, "texlua exit status passed through")
  contains(r.out .. r.err, texlua_out:gsub("%s+$", ""), "texlua message passed through")
end)

case("shebang_not_found", function()
  write_file("nf1.tex", "%%1\n%%2\n%%3\n")
  local r = run({ "nf1.tex" })
  eq(r.code, 2, "no shebang: exit")
  contains(r.err, "TeX-style shebang not found", "no shebang: stderr")

  write_file("nf2.tex", twenty .. "%#!echo too late\n")
  r = run({ "nf2.tex" })
  eq(r.code, 2, "line 21: exit")
  not_contains(r.out, "too late", "line 21 is not executed")

  write_file("nf3.tex", "")
  r = run({ "nf3.tex" })
  eq(r.code, 2, "empty file: exit")
end)

case("exit_status", function()
  write_file("e3.tex", "%#!exit 3\n")
  local r = run({ "e3.tex" })
  eq(r.code, 3, "exit 3 is propagated")
  contains(r.err, "exited with status 3", "failure is reported on stderr")

  write_file("e0.tex", "%#!exit 0\n")
  r = run({ "e0.tex" })
  eq(r.code, 0, "exit 0")
  not_contains(r.err, "exited with status", "no failure report on success")
end)

case("shebang_crlf", function()
  write_file("crlf.tex", "%#!echo CRLF ok\r\n\\documentclass{article}\r\n")
  local r = run({ "crlf.tex" })
  eq(r.code, 0, "exit")
  eq(r.out, banner .. "\nCRLF ok\n", "trailing CR is stripped from the command")
end)

case("shebang_bom", function()
  write_file("bom.tex", "\239\187\191%#!echo BOM ok\n")
  local r = run({ "bom.tex" })
  eq(r.code, 0, "exit")
  eq(r.out, banner .. "\nBOM ok\n", "UTF-8 BOM before %#! is ignored")
end)

case("shebang_prefix_once", function()
  write_file("once.tex", "%#!echo a%#!b\n")
  local r = run({ "once.tex" })
  eq(r.code, 0, "exit")
  eq(r.out, banner .. "\na%#!b\n", "only the leading %#! is removed")

  write_file("ws.tex", "%#!   echo padded   \n")
  r = run({ "--dry-run", "ws.tex" })
  eq(r.out, banner .. "\necho padded\n", "surrounding whitespace is trimmed")
end)

case("shebang_empty", function()
  for _, body in ipairs({ "%#!\n", "%#!   \n", "%#!\t\r\n" }) do
    write_file("empty.tex", body)
    local r = run({ "empty.tex" })
    eq(r.code, 2, "empty shebang " .. show(body) .. ": exit")
    contains(r.err, "empty", "empty shebang " .. show(body) .. ": stderr")
  end
end)

case("shebang_strict_column", function()
  for _, body in ipairs({ " %#!echo x\n", "% #!echo x\n", "\t%#!echo x\n" }) do
    write_file("col.tex", body)
    local r = run({ "col.tex" })
    eq(r.code, 2, "not column 1 " .. show(body) .. ": exit")
    not_contains(r.out, "x\n", "not column 1 " .. show(body) .. ": not executed")
  end
end)

case("file_errors", function()
  local r = run({ "no-such-file.tex" })
  eq(r.code, 1, "missing file: exit")
  contains(r.err, "cannot read", "missing file: stderr")
  not_contains(r.err, "stack traceback", "missing file: no Lua traceback")

  r = run({ "." })
  eq(r.code, 1, "directory: exit")
  contains(r.err, "cannot read", "directory: stderr")
  not_contains(r.err, "stack traceback", "directory: no Lua traceback")
end)

case("option_unknown", function()
  local r = run({ "--bogus" })
  eq(r.code, 1, "unknown option: exit")
  contains(r.err, "unknown option", "unknown option: stderr")
  not_contains(r.err, "stack traceback", "unknown option: no Lua traceback")

  write_file("--odd.tex", "%#!echo odd ok\n")
  r = run({ "--odd.tex" })
  eq(r.code, 1, "--odd.tex without -- is an unknown option")
  r = run({ "--", "--odd.tex" })
  eq(r.code, 0, "-- ends option parsing: exit")
  eq(r.out, banner .. "\nodd ok\n", "-- ends option parsing: stdout")

  write_file("a.tex", "%#!echo a\n")
  write_file("b.tex", "%#!echo b\n")
  r = run({ "a.tex", "b.tex" })
  eq(r.code, 1, "two filenames: exit")
  contains(r.err, "only one input file", "two filenames: stderr")
  not_contains(r.out, "echo", "two filenames: nothing executed")
end)

case("transparency", function()
  write_file("hi.tex", "%#!echo hi\n")
  local r = run({ "hi.tex" })
  eq(r.code, 0, "exit")
  eq(r.out, banner .. "\nhi\n", "stdout")
  local first = r.err:match("^([^\n]*)")
  eq(first, "runtexshebang: running: echo hi", "command is announced on stderr before running")
end)

case("no_require", function()
  local f = assert(io.open(SCRIPT, "rb"))
  local src = f:read("a")
  f:close()
  for _, pat in ipairs({ "require%s*[%(%'\"]", "dofile%s*%(", "loadfile%s*%(", "loadstring%s*%(",
                         "%f[%w_]load%s*%(", "kpse%.", "package%." }) do
    if src:find(pat) then fail("no code loading", "script matches " .. show(pat)) end
  end
end)

-- -------------------------------------------------------------------- run
for _, c in ipairs(cases) do
  current = c.name
  total = total + 1
  local before = #failures
  local ok, e = pcall(c.fn)
  if not ok then fail("runner", tostring(e)) end
  for _, name in ipairs(created) do os.remove(name) end
  created = {}
  io.write(string.format("%-24s %s\n", c.name, #failures == before and "ok" or "FAIL"))
end
lfs.chdir("..")
lfs.rmdir(TMP)

if #failures > 0 then
  io.write("\n")
  for _, f in ipairs(failures) do io.write(f, "\n") end
  io.write(string.format("\nFAIL %d failure(s) in %d test(s)\n", #failures, total))
  os.exit(1)
end
io.write(string.format("\nOK %d tests\n", total))
