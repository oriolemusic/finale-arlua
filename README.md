# finale-arlua

**```arlua```** is a Windows dynamic link library for extending **RGP Lua** plugin for Finale.

This library includes a set of useful functions for various purposes.

### Functions

  #### Menu command
    
  - **```FindMenuItem (pattern)```** _find Finale menu item using pattern (e.g. 'exp*|audio*')_
  - **```CommandId (id)```** _execute Finale menu command by ID number_
  - **```Command (pattern)```** _find and execute Finale menu item using pattern_
  - **```MenuItemList (simplify)```** _create full list of all Finale menu items_

  #### Log
  
  - **```Log (...)```** _write arguments to log file_
  - **```Logf (format, ...)```** _write formatted arguments to log file_
  - **```Logc (void)```** _clear log file_
  - **```GetLog (void)```** _get current log file path_
  - **```SetLog (filename)```** _set log file name_

  #### Registry
  
  - **```GetRegValue (key, value)```** _read registry data by key and value name_
  - **```SetRegValue (key, value, data)```** _write registry data_
  - **```DeleteRegValue (key, value)```** _delete registry data_

 #### Benchmark
 
  - **```StartBenchmark (void)```** _start benchmark (save time point internally)_
  - **```StopBenchmark (void)```** _stop benchmark and get time interval_


### Properties

  - **```VERSION```** _Arlua 0.1.0 alpha_
    
