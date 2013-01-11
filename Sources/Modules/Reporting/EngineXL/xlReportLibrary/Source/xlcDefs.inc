{ Get compiler version }

{$IFDEF BCB} { C++Builder }
  {$DEFINE XLR_BCB}
  {$ObjExportAll On}
{$ENDIF}

{$IFDEF VER120} { Delphi 4.0 }
  {$DEFINE XLR_VCL4}
{$ENDIF VER120}

{$IFDEF VER125} { C++Builder 4.0 }
  {$DEFINE XLR_VCL4}
{$ENDIF VER125}

{$IFDEF VER130} { Delphi 5.0 or C++Builder 5.0 }
  {$DEFINE XLR_VCL5}
{$ENDIF VER130}

{$IFDEF VER140} { Delphi 6.0 or C++Builder 6.0 }
  {$DEFINE XLR_VCL6}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

{$IFDEF VER150} { Delphi 7.0 }
  {$DEFINE XLR_VCL7}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN UNIT_DEPRECATED OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

{$IFDEF VER220} { Delphi 15.0 }
  {$DEFINE XLR_VCL7}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN UNIT_DEPRECATED OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

{$IFDEF VER230} { Delphi 16.0 } // Rad Studio XE 2
  {$DEFINE XLR_VCL7}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN UNIT_DEPRECATED OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

{ Compiler defines }

//                                   DEBUG options - comment before release
// {$DEFINE XLR_DEBUG}

{ Product defines }

//                                    XL Report.VCL
{$DEFINE XLR_VCL}
//                                    Active XL Report
// {$DEFINE XLR_AX}
//                                    XL Report - MS Project Edition
// {$DEFINE XLR_MSP}
//                                    XL Report.NET
// {$DEFINE XLR_NET}

{ Licence defines }

//                                    Trial
// {$DEFINE XLR_TRIAL}
//                                    Standard (without source)
// {$DEFINE XLR_STD}
//                                    Developer (with source)
{$DEFINE XLR_DEV}
//                                    Professional
// {$DEFINE XLR_PRO}

//                                    ASProtect
// XL Report.AX
{$IFDEF XLR_AX}
  {$IFNDEF XLR_DEV}
    {$DEFINE ASPROTECT}
  {$ENDIF}
{$ENDIF}
// XL Report.NET
{$IFDEF XLR_NET}
  {$IFNDEF XLR_DEV}
    {$DEFINE ASPROTECT}
  {$ENDIF}
{$ENDIF}
// XL Report.MSP
{$IFDEF XLR_MSP}
  {$IFNDEF XLR_DEV}
    {$DEFINE ASPROTECT}
  {$ENDIF}
{$ENDIF}

{ Compiler directives }

{$B-} {- Complete Boolean Evaluation }
{$R-} {- Range-Checking }
{$V-} {- Var-String Checking }
{$T-} {- Typed @ operator }
{$X+} {- Extended syntax }
{$P+} {- Open string params }
{$J+} {- Writeable structured consts }
{$H+} {- Use long strings by default }

