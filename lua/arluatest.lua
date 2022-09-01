--**********************************************--
--                arlua dll test                --
--               for v0.1.2 alpha               --
--**********************************************--

--[[

  'arlua' is a Windows dynamic link library for extending RGP Lua plugin for Finale.
  This library includes a set of useful functions for different purposes.
  Plans to expand and develop for a long period of time.
  This is just a pilot version to demonstrate the capabilities.

  This was made possible by Robert Patterson after he fixed linking and
  using custom dynamic libraries to RGP Lua, which didn't work in JW Lua.

  To use the DLL, you must have the RGP Lua v0.63 plugin installed.
  Copy arlua.dll file to the same folder as a lua script or any directory where RGP Lua can find it
  (look in package.cpath). Alternatively change cpath, e.g:

    > package.cpath = package.cpath..';'..'%YOUR ARLUA.DLL PATH%'

  where %YOUR ARLUA.DLL PATH% is a full directory path with '\?.dll' at the end.
  Finally, call the standard "require" function as you would to load any other lua modules:

    > local arlua = require(arlua)

  Functions are accessed through a dot (not colon!):

    > local list = arlua.MenuItemList(true)

  -----------------------------------------------

  Development language - C (not C++!)
  Supported platform - Windows only
  Developed and tested on Windows 10 Pro x64
  Finale v27.2.0.144
  RGP Lua v0.63

  -----------------------------------------------

  QUICK REFERENCE:

  == PROPERTIES (FIELDS) ========================

  VERSION
    Get current 'arlua' version (Arlua 0.1.2 alpha)


  == MENU COMMANDS ==============================

  -----------------------------------------------
  FindMenuItem(pattern)

    Finding the first match of menu item text with a pattern (iterated from left-top to right-down). If the menu is not visible, it grabs from the resource file (FinRes.dll)
    This function resolves the problem with unsupported menu commands in RGP Lua FCUI::MenuCommand().
    
    Parameters:
      pattern (const char*)
        can include full menu item text or a last part only,
        the search is case insensitive.
        Ampersand (&) and shortcuts are ignored.
        Asterisk (*) means any continuation of the text.
        e.g. 'File|New|Document With Setup Wizard...	Ctrl+N' can be found by follow patterns:
        'file|new|document with setup wizard...'
        'document with setup*'
        'new|doc*'
        'f*|n*|d*'

    Return:
      1) menu item ID number (or 0 on failure)
      2) menu item full path text (from root to command)

  -----------------------------------------------
  CommandId(id)

    Execute the menu command by id.

    Parameters:
      id (integer number)
      It can be obtained from the FindMenuItem function.
      Remember that all Plugins submenu command IDs assigned dynamically,
      so if you add one or more new items (lua scripts) and reboot Finale,
      all menu IDs following them will have shifted.

    Return:
        (boolean) true/false

  -----------------------------------------------
  Command(pattern)
    
    Combines two functions: FindMenuItem and CommandId
    At first, it finds the menu and, if successful, executes it.

    Parameters:
      pattern (const char*)
        (See FindMenuItem above)
    
    Return:
      (See FindMenuItem above)

  -----------------------------------------------
  MenuItemList(simplify)

    Create menu items list including dynamic menu items from resources.

    Parameters:
      simplify (boolean)
        If true, all menu items skip '&' and '\t' characters,
        trim left spaces and ignore shortcuts if they exist.
        Otherwise, the menu retains its original appearance as is.

    Return:
      (string) menu list, one by line.


  == LOG ========================================
  These functions you can use insted of JWLua console 'print'

  -----------------------------------------------
  Log(...)

    Write all args to file.
    This is the same function like lua 'print', but insted of default
    output device it saves text to file.
    Default file path is '%TEMP%\arlua.log',
    in my case it looks like this: 'c:\Users\%USERNAME%\AppData\Local\Temp\arlua.log'
    
    Parameters:
      Arguments can have any type.
      All of them will be converted to space-separated strings.
      The new line char '\n' is appended to the end of the result.
      The function is append a text to existed file or write a new file.

    Return:
      No return value.

  -----------------------------------------------
  Logf(format, ...)

    Write formatted text to file.
    This is the same function like lua 'string.format', but insted of returning string it saves text to file. For additional information about string formatting read the lua documentation. Note that the function is not appends a new line at the end.
    Read 'Log(...)' description about log file path.
    
    Parameters:
      format(const char*)
        The format string follows the same rules as in lua string.format.
      variadic args (read lua docs).

    Return:
      No return value.
    
  -----------------------------------------------
  Logc(void)

    Clears the content of the log file if it exists.
    Use it every time you want to run a new sequence of logs on an empty file.

    Parameters:
      No parameters.

    Return:
      No return value.

  -----------------------------------------------
  GetLog(void)
    
    Return a current log file path. If it has never been setted then the default path is returned.
    e.g. 'c:\Users\%USERNAME%\AppData\Local\Temp\arlua.log'

    Parameters:
      No parameters.

    Return:
      (string) current log file path.

  -----------------------------------------------
  SetLog(filename)

    Set the log file path using filename.
    After that all other log functions will use the new path.
    
    Parameters:
      filename (const char*)
        For now, only the log file name can be specified, not the full path.

    Return:
      1) (boolean) true if successful or false.
      2) Error message on failure.


  == REGISTRY ===================================
  Attention! Use the registry functions only if you really know what you are doing.

  -----------------------------------------------
  GetRegData(key, value)

    Get Windows registry data using key and value.

    Parametres:
      key (const char*)
        Full registry path separated by '\'.
        e.g. 'HKEY_CURRENT_USER\\Software\\MakeMusic\\Finale27\\Finale\\Settings'
        If you skip root key, 'HKEY_CURRENT_USER' will automatically insert at the beginning of the path,
        thus the above example can be written shorter: 'Software\\MakeMusic\\Finale27\\Finale\\Settings'

      value (const char*)
        Name of value (e.g. 'WindowPos')

    Return:
      1) ( type) registri data. The type depends of data.
        Supported types: REG_SZ (a null-terminated string),
                          REG_EXPAND_SZ (a null-terminated string with environment variables, e.g, "%TEMP%"),
                          REG_DWORD (a 32-bit unsigned number, convert it to signed number manually)
                          REG_QWORD (a 64-bit unsigned number)
                          REG_MULTI_SZ (a sequence of null-terminated strings)
                          REG_BINARY (a sequence of bytes)
        The REG_MULTI_SZ data is packed into a lua table, you need to iterate strings with the 'ipairs' function.
        Binary data returns a string, which can include '\0' chars, so use the lua function 'string.bytes' to access the data.
        If an error occurs, nil is returned.
      2) (const char*) type name of source registry data (not returned data type) or error message on failure.

  -----------------------------------------------
  SetRegData(key, value, data)

    Set Windows registry data using key, value and data.

    Parametres:
      key (const char*)
        (Read GetRegData description)

      value (const char*)
        (Read GetRegData description)

      data (variable type)
        All numbers are saved this automatic types.
        You can convert double (float) numbers to string before saving.
        For multistring data use a table (empty strings are not allowed).
        Binary data does not yet support saving.

    Return:
      1) (boolean) true if successful or false.
      2) Error message on failure.

  -----------------------------------------------
  DeleteRegData(key, value)

    Delete registry data.

    Parametres:
      key (const char*)
        (Read GetRegData description)

      value (const char*)
        (Read GetRegData description)

    Return:
      1) (boolean) true if successful or false.
      2) Error message on failure.


  == BENCHMARK ==================================

  -----------------------------------------------
  StartBenchmark(void)

    Start timer. It works together with StopBenchmark function.
    
    Parameters:
      No parameters.

    Return:
      No return value.

  -----------------------------------------------
  StopBenchmark(void)

    Stop timer and return time interval. It works together with StartBenchmark function.
    
    Parameters:
      No parameters.

    Return:
      1) (const char*) time interval since the last start of StartBenchmark in '%.3fs' format (float seconds).
        If StartBenchmark has not been run, then nil is returned.
      2) (integer number) the value of the time interval in processor ticks (in x64 Windows this means milliseconds, 1/1000 sec) or message 'benchmark is not started'.


--]]


function plugindef()
  finaleplugin.MinFinaleVersion = "10027"
  finaleplugin.MinJWLuaVersion = "0.63"
  finaleplugin.Author = "Artem Roschenko"
  finaleplugin.Copyright = "© OrioleMusic, Artem Roschenko"
  finaleplugin.Version = "1.0"
  finaleplugin.Date = "21-07-2022"
  finaleplugin.AuthorEmail = "roschenkoartem@gmail.com"
  finaleplugin.Id = "A5511AB3-7C69-4E34-89A8-E633376FBB21"
  finaleplugin.CategoryTags = "Development"
  return "arlua test", "arlua test", "arlua test"
end

local ui = finenv.UI()

-- break script on Mac
if ui:IsOnMac() then
    ui:AlertError('Arlua is not available on MacOS', 'Error')
    return
end


local arlua = require('arlua')


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- test log
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

arlua.Logc() -- clear log file if exists

local deflogpath = arlua.GetLog()
ui:AlertInfo('Log file path:\n"'..deflogpath..'"', 'arlua.GetLog')

arlua.Log('\ttest log ====================\n')

arlua.Logf('arlua.GetLog() = "%s"\n', deflogpath) -- for new line put '\n' manually
arlua.Log() -- just new line
arlua.Log('Text sample', math.pow(2, 64), 3.1415926, {}, print, finale.FCString(), nil, true)

arlua.Log()
arlua.Log('  arlua.Logf() misc formats:\n')

-- %A %a %E %e %f %G %g %c %s %i %o %u %X %x %q
arlua.Logf('%%s: (%s)(%s)\n', 'text', 123)
arlua.Logf('%%f: %f\n', -1.3)
arlua.Logf('%%.3f: %.3f\n', 1.2455)
arlua.Logf('%%i: %i\n', 60293)
arlua.Logf('%%u: %u\n', 1.3)
arlua.Logf('%%x: %x\n', 65434)
arlua.Logf('%%X: 0x%X\n', math.pow(2, 32) - 1)
arlua.Logf('%q\n', 'a string with "quotes"')

arlua.Log()

local newlogpath = arlua.SetLog('test.txt') -- set new log path
arlua.Log(newlogpath)

arlua.SetLog('arlua.log') -- back to default

arlua.Log('\ttest registry ===============\n')

arlua.Log('  SetRegData\n')


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- test registry
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

arlua.SetRegData('HKEY_CURRENT_USER\\Software\\Test', 'StringValue', 'Some text')
arlua.Log(arlua.SetRegData('HKEY_CURRENT_USER\\Software\\Test', 'Number', 1234567))
arlua.Log(arlua.SetRegData('HKEY_CURRENT_USER\\Software\\Test', 'BigNumber', 9876543210))
arlua.Log(arlua.SetRegData('HKEY_CURRENT_USER\\Software\\Test', 'Double', tostring(-0.2345676556)))
arlua.Log(arlua.SetRegData('HKEY_CURRENT_USER\\Software\\Test', 'MultiString', {'String1', 'String2', 'String3'}))
--arlua.Log(arlua.SetRegData('HKEY_CURRENT_USER\\Software\\Test', 'Binary', TODO...))

arlua.Log(arlua.SetRegData('Software\\Test', 'TestRootKey', 'Default root key'))

arlua.Log()
arlua.Log('  GetRegData\n')

arlua.Log(arlua.GetRegData('HKEY_CURRENT_USER\\Software\\Test', 'Number'))
arlua.Log(arlua.GetRegData('HKEY_CURRENT_USER\\Software\\Test', 'BigNumber'))
arlua.Log(arlua.GetRegData('HKEY_CURRENT_USER\\Software\\Test', 'Double'))
local mstr = arlua.GetRegData('HKEY_CURRENT_USER\\Software\\Test', 'MultiString')
for i, v in ipairs(mstr) do
  arlua.Log(v)
end
arlua.Log(arlua.GetRegData('Software\\Test', 'TestRootKey', 'Default root key'))

arlua.Log()
arlua.Log('  DeleteRegData\n')

arlua.Logf('regData=\'%s\'\nregType=\'%s\'', arlua.GetRegData('Software\\Test', 'Test'))
arlua.Log(arlua.DeleteRegData('Software\\Test', 'Test'))

-- error + message
arlua.Log(arlua.GetRegData('Software\\Test', 'Test'))


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- test menu commands
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

arlua.Log()
arlua.Log('\tmenu commands ===============\n')

-- FindMenuItem
local pattern = 't*|tupl*'
local id, menu = arlua.FindMenuItem(pattern)

arlua.Logf('  arlua.FindMenuItem(\'%s\')\n\n', pattern)
arlua.Logf('pattern = %s\n', pattern)
arlua.Logf('id = %d\n', id)
arlua.Logf('menu = %s\n', menu)

-- CommandId
local result = arlua.CommandId(id)

arlua.Logf('  arlua.CommandId(%i)\n\n', id)

-- Command
local pattern = 'help|about*'
local id, menu = arlua.Command(pattern)

arlua.Logf('  arlua.Command(\'%s\')\n\n', pattern)

-- Command (hidden at the moment)
local pattern = 'respace st*'
local id, menu = arlua.Command(pattern)

arlua.Logf(' (hidden menu) arlua.Command(\'%s\')\n\n', pattern)
arlua.Logf('pattern = %s\n', pattern)
arlua.Logf('id = %d\n', id)
arlua.Logf('menu = %s\n', menu)

-- MenuItemList
local list = arlua.MenuItemList(true) -- simplified

arlua.Log()
arlua.Log()
arlua.Log(' (simplified) arlua.MenuItemList(true)\n')

arlua.Log(list)

local list = arlua.MenuItemList() -- original

arlua.Log()
arlua.Log('\n (original) arlua.MenuItemList()\n')

arlua.Log(list)


--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- test benchmark
--+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

arlua.Log()
arlua.Log('\tbenchmark ====================\n')

arlua.StartBenchmark()

for i = 1, 1000 do
  arlua.SetRegData('Software\\Test', 'Test', 'Default root key')
end

local bm = arlua.StopBenchmark()
arlua.Logf('arlua.SetRegData 1000 times: %s\n', bm)

-- if benchmark is not started

arlua.Log()
arlua.Log('Raise error message if run StopBenchmark without StartBenchmark:\n')
local bm, err = arlua.StopBenchmark()
arlua.Log(bm, err)

arlua.Log('\n\n  done!')

ui:AlertInfo('arlua test is done!', 'arlua')
