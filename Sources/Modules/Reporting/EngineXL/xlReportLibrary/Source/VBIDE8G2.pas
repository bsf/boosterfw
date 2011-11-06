{*******************************************************************}
{                                                                   }
{       AfalinaSoft Visual Component Library                        }
{       XL Report 4.0 with XLOptionPack  Technology                 }
{                                                                   }
{       Copyright (C) 1998, 2002 Afalina Co., Ltd.                  }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF AFALINA CO.,LTD. THE REGISTERED DEVELOPER IS         }
{   LICENSED TO DISTRIBUTE THE XL REPORT AND ALL ACCOMPANYING VCL   }
{   COMPONENTS AS PART OF AN EXECUTABLE PROGRAM ONLY.               }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT WRITTEN CONSENT          }
{   AND PERMISSION FROM AFALINA CO., LTD.                           }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit VBIDE8G2;

// ************************************************************************ //
// WARNING                                                                  //
// -------                                                                  //
// The types declared in this file were generated from data read from a     //
// Type Library. If this type library is explicitly or indirectly (via      //
// another type library referring to this type library) re-imported, or the //
// 'Refresh' command of the Type Library Editor activated while editing the //
// Type Library, the contents of this file will be regenerated and all      //
// manual modifications will be lost.                                       //
// ************************************************************************ //

// PASTLWTR : $Revision:   1.11.1.63  $
// File generated on 8/4/98 10:34:40 PM from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\PROGRAM FILES\COMMON FILES\MICROSOFT SHARED\VBA\VBEEXT1.OLB
// IID\LCID: {0002E157-0000-0000-C000-000000000046}\0
// Helpfile: C:\PROGRAM FILES\COMMON FILES\MICROSOFT SHARED\VBA\VEENOB3.HLP
// HelpString: Microsoft Visual Basic for Applications Extensibility
// Version:    5.0
// ************************************************************************ //

{$I xlcDefs.inc}

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, Office8G2;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:      //
//   Type Libraries     : LIBID_xxxx                                    //
//   CoClasses          : CLASS_xxxx                                    //
//   DISPInterfaces     : DIID_xxxx                                     //
//   Non-DISP interfaces: IID_xxxx                                      //
// *********************************************************************//
const
  LIBID_VBIDE: TGUID = '{0002E157-0000-0000-C000-000000000046}';
  IID_Application_: TGUID = '{0002E158-0000-0000-C000-000000000046}';
  IID_VBE: TGUID = '{0002E166-0000-0000-C000-000000000046}';
  IID_Window_: TGUID = '{0002E16B-0000-0000-C000-000000000046}';
  IID__Windows_: TGUID = '{0002E16A-0000-0000-C000-000000000046}';
  CLASS_Windows: TGUID = '{0002E185-0000-0000-C000-000000000046}';
  IID__LinkedWindows: TGUID = '{0002E16C-0000-0000-C000-000000000046}';
  CLASS_LinkedWindows: TGUID = '{0002E187-0000-0000-C000-000000000046}';
  IID_Events: TGUID = '{0002E167-0000-0000-C000-000000000046}';
  IID__VBProjectsEvents: TGUID = '{0002E113-0000-0000-C000-000000000046}';
  DIID__dispVBProjectsEvents: TGUID = '{0002E103-0000-0000-C000-000000000046}';
  IID__VBComponentsEvents: TGUID = '{0002E115-0000-0000-C000-000000000046}';
  DIID__dispVBComponentsEvents: TGUID = '{0002E116-0000-0000-C000-000000000046}';
  IID__ReferencesEvents: TGUID = '{0002E11A-0000-0000-C000-000000000046}';
  DIID__dispReferencesEvents: TGUID = '{0002E118-0000-0000-C000-000000000046}';
  CLASS_ReferencesEvents: TGUID = '{0002E119-0000-0000-C000-000000000046}';
  IID__CommandBarControlEvents: TGUID = '{0002E130-0000-0000-C000-000000000046}';
  DIID__dispCommandBarControlEvents: TGUID = '{0002E131-0000-0000-C000-000000000046}';
  CLASS_CommandBarEvents: TGUID = '{0002E132-0000-0000-C000-000000000046}';
  IID__ProjectTemplate: TGUID = '{0002E159-0000-0000-C000-000000000046}';
  CLASS_ProjectTemplate: TGUID = '{32CDF9E0-1602-11CE-BFDC-08002B2B8CDA}';
  IID__VBProject: TGUID = '{0002E160-0000-0000-C000-000000000046}';
  CLASS_VBProject: TGUID = '{0002E169-0000-0000-C000-000000000046}';
  IID__VBProjects: TGUID = '{0002E165-0000-0000-C000-000000000046}';
  CLASS_VBProjects: TGUID = '{0002E101-0000-0000-C000-000000000046}';
  IID_SelectedComponents: TGUID = '{BE39F3D4-1B13-11D0-887F-00A0C90F2744}';
  IID__Components: TGUID = '{0002E161-0000-0000-C000-000000000046}';
  CLASS_Components: TGUID = '{BE39F3D6-1B13-11D0-887F-00A0C90F2744}';
  IID__VBComponents: TGUID = '{0002E162-0000-0000-C000-000000000046}';
  CLASS_VBComponents: TGUID = '{BE39F3D7-1B13-11D0-887F-00A0C90F2744}';
  IID__Component: TGUID = '{0002E163-0000-0000-C000-000000000046}';
  CLASS_Component: TGUID = '{BE39F3D8-1B13-11D0-887F-00A0C90F2744}';
  IID__VBComponent: TGUID = '{0002E164-0000-0000-C000-000000000046}';
  CLASS_VBComponent: TGUID = '{BE39F3DA-1B13-11D0-887F-00A0C90F2744}';
  IID_Property_: TGUID = '{0002E18C-0000-0000-C000-000000000046}';
  IID__Properties: TGUID = '{0002E188-0000-0000-C000-000000000046}';
  CLASS_Properties: TGUID = '{0002E18B-0000-0000-C000-000000000046}';
  IID__CodeModule: TGUID = '{0002E16E-0000-0000-C000-000000000046}';
  CLASS_CodeModule: TGUID = '{0002E170-0000-0000-C000-000000000046}';
  IID__CodePanes: TGUID = '{0002E172-0000-0000-C000-000000000046}';
  CLASS_CodePanes: TGUID = '{0002E174-0000-0000-C000-000000000046}';
  IID__CodePane: TGUID = '{0002E176-0000-0000-C000-000000000046}';
  CLASS_CodePane: TGUID = '{0002E178-0000-0000-C000-000000000046}';
  IID__References: TGUID = '{0002E17A-0000-0000-C000-000000000046}';
  IID_Reference: TGUID = '{0002E17E-0000-0000-C000-000000000046}';
  DIID__dispReferences_Events: TGUID = '{CDDE3804-2064-11CF-867F-00AA005FF34A}';
  CLASS_References: TGUID = '{0002E17C-0000-0000-C000-000000000046}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                  //
// *********************************************************************//
// vbextFileTypes constants
type
  vbextFileTypes = TOleEnum;
const
  vbextFileTypeForm = $00000000;
  vbextFileTypeModule = $00000001;
  vbextFileTypeClass = $00000002;
  vbextFileTypeProject = $00000003;
  vbextFileTypeExe = $00000004;
  vbextFileTypeFrx = $00000005;
  vbextFileTypeRes = $00000006;
  vbextFileTypeUserControl = $00000007;
  vbextFileTypePropertyPage = $00000008;
  vbextFileTypeDocObject = $00000009;
  vbextFileTypeBinary = $0000000A;
  vbextFileTypeGroupProject = $0000000B;
  vbextFileTypeDesigners = $0000000C;

// vbext_WindowType constants
type
  vbext_WindowType = TOleEnum;
const
  vbext_wt_CodeWindow = $00000000;
  vbext_wt_Designer = $00000001;
  vbext_wt_Browser = $00000002;
  vbext_wt_Watch = $00000003;
  vbext_wt_Locals = $00000004;
  vbext_wt_Immediate = $00000005;
  vbext_wt_ProjectWindow = $00000006;
  vbext_wt_PropertyWindow = $00000007;
  vbext_wt_Find = $00000008;
  vbext_wt_FindReplace = $00000009;
  vbext_wt_LinkedWindowFrame = $0000000B;
  vbext_wt_MainWindow = $0000000C;
  vbext_wt_ToolWindow = $0000000F;

// vbext_WindowState constants
type
  vbext_WindowState = TOleEnum;
const
  vbext_ws_Normal = $00000000;
  vbext_ws_Minimize = $00000001;
  vbext_ws_Maximize = $00000002;

// vbext_ProjectProtection constants
type
  vbext_ProjectProtection = TOleEnum;
const
  vbext_pp_none = $00000000;
  vbext_pp_locked = $00000001;

// vbext_VBAMode constants
type
  vbext_VBAMode = TOleEnum;
const
  vbext_vm_Run = $00000000;
  vbext_vm_Break = $00000001;
  vbext_vm_Design = $00000002;

// vbext_ComponentType constants
type
  vbext_ComponentType = TOleEnum;
const
  vbext_ct_StdModule = $00000001;
  vbext_ct_ClassModule = $00000002;
  vbext_ct_MSForm = $00000003;
  vbext_ct_Document = $00000064;

// vbext_ProcKind constants
type
  vbext_ProcKind = TOleEnum;
const
  vbext_pk_Proc = $00000000;
  vbext_pk_Let = $00000001;
  vbext_pk_Set = $00000002;
  vbext_pk_Get = $00000003;

// vbext_CodePaneview constants
type
  vbext_CodePaneview = TOleEnum;
const
  vbext_cv_ProcedureView = $00000000;
  vbext_cv_FullModuleView = $00000001;

// vbext_RefKind constants
type
  vbext_RefKind = TOleEnum;
const
  vbext_rk_TypeLib = $00000000;
  vbext_rk_Project = $00000001;

{$IFNDEF XLR_BCB}

type

// *********************************************************************//
// Forward declaration of interfaces defined in Type Library            //
// *********************************************************************//
  Application_ = interface;
  VBE = interface;
  Window_ = interface;
  _Windows_ = interface;
  _LinkedWindows = interface;
  Events = interface;
  _VBProjectsEvents = interface;
  _VBComponentsEvents = interface;
  _ReferencesEvents = interface;
  _CommandBarControlEvents = interface;
  _ProjectTemplate = interface;
  _VBProject = interface;
  _VBProjects = interface;
  SelectedComponents = interface;
  _Components = interface;
  _VBComponents = interface;
  _Component = interface;
  _VBComponent = interface;
  Property_ = interface;
  _Properties = interface;
  _CodeModule = interface;
  _CodePanes = interface;
  _CodePane = interface;
  _References = interface;
  Reference = interface;

  Application_Disp = dispinterface;
  VBEDisp = dispinterface;
  Window_Disp = dispinterface;
  _Windows_Disp = dispinterface;
  _LinkedWindowsDisp = dispinterface;
  EventsDisp = dispinterface;
  _dispVBProjectsEvents = dispinterface;
  _dispVBComponentsEvents = dispinterface;
  _dispReferencesEvents = dispinterface;
  _dispCommandBarControlEvents = dispinterface;
  _ProjectTemplateDisp = dispinterface;
  _VBProjectDisp = dispinterface;
  _VBProjectsDisp = dispinterface;
  SelectedComponentsDisp = dispinterface;
  _ComponentsDisp = dispinterface;
  _VBComponentsDisp = dispinterface;
  _ComponentDisp = dispinterface;
  _VBComponentDisp = dispinterface;
  Property_Disp = dispinterface;
  _PropertiesDisp = dispinterface;
  _CodeModuleDisp = dispinterface;
  _CodePanesDisp = dispinterface;
  _CodePaneDisp = dispinterface;
  _ReferencesDisp = dispinterface;
  ReferenceDisp = dispinterface;
  _dispReferences_Events = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                     //
// (NOTE: Here we map each CoClass to its Default Interface)            //
// *********************************************************************//
  Windows = _Windows_;
  LinkedWindows = _LinkedWindows;
  ReferencesEvents = _ReferencesEvents;
  CommandBarEvents = _CommandBarControlEvents;
  ProjectTemplate = _ProjectTemplate;
  VBProject = _VBProject;
  VBProjects = _VBProjects;
  Components = _Components;
  VBComponents = _VBComponents;
  Component = _Component;
  VBComponent = _VBComponent;
  Properties = _Properties;
  CodeModule = _CodeModule;
  CodePanes = _CodePanes;
  CodePane = _CodePane;
  References = _References;


// *********************************************************************//
// Declaration of structures, unions and aliases.                       //
// *********************************************************************//
  PWordBool1 = ^WordBool; {*}


// *********************************************************************//
// Interface: Application_
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E158-0000-0000-C000-000000000046}
// *********************************************************************//
  Application_ = interface(IDispatch)
    ['{0002E158-0000-0000-C000-000000000046}']
    function Get_Version: WideString; safecall;
    property Version: WideString read Get_Version;
  end;

// *********************************************************************//
// Interface: VBE
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E166-0000-0000-C000-000000000046}
// *********************************************************************//
  VBE = interface(Application_)
    ['{0002E166-0000-0000-C000-000000000046}']
    function Get_VBProjects: VBProjects; safecall;
    function Get_CommandBars: CommandBars; safecall;
    function Get_CodePanes: CodePanes; safecall;
    function Get_Windows: Windows; safecall;
    function Get_Events: Events; safecall;
    function Get_ActiveVBProject: VBProject; safecall;
    procedure Set_ActiveVBProject(const lppptReturn: VBProject); safecall;
    function Get_SelectedVBComponent: VBComponent; safecall;
    function Get_MainWindow: Window_; safecall;
    function Get_ActiveWindow: Window_; safecall;
    function Get_ActiveCodePane: CodePane; safecall;
    procedure Set_ActiveCodePane(const ppCodePane: CodePane); safecall;
    property VBProjects: VBProjects read Get_VBProjects;
    property CommandBars: CommandBars read Get_CommandBars;
    property CodePanes: CodePanes read Get_CodePanes;
    property Windows: Windows read Get_Windows;
    property Events: Events read Get_Events;
    property ActiveVBProject: VBProject read Get_ActiveVBProject write Set_ActiveVBProject;
    property SelectedVBComponent: VBComponent read Get_SelectedVBComponent;
    property MainWindow: Window_ read Get_MainWindow;
    property ActiveWindow: Window_ read Get_ActiveWindow;
    property ActiveCodePane: CodePane read Get_ActiveCodePane write Set_ActiveCodePane;
  end;

// *********************************************************************//
// Interface: Window_
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E16B-0000-0000-C000-000000000046}
// *********************************************************************//
  Window_ = interface(IDispatch)
    ['{0002E16B-0000-0000-C000-000000000046}']
    function Get_VBE: VBE; safecall;
    function Get_Collection: Windows; safecall;
    procedure Close; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(pfVisible: WordBool); safecall;
    function Get_Left: Integer; safecall;
    procedure Set_Left(plLeft: Integer); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(plTop: Integer); safecall;
    function Get_Width: Integer; safecall;
    procedure Set_Width(plWidth: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(plHeight: Integer); safecall;
    function Get_WindowState: vbext_WindowState; safecall;
    procedure Set_WindowState(plWindowState: vbext_WindowState); safecall;
    procedure SetFocus; safecall;
    function Get_Type_: vbext_WindowType; safecall;
    procedure SetKind(eKind: vbext_WindowType); safecall;
    function Get_LinkedWindows: LinkedWindows; safecall;
    function Get_LinkedWindowFrame: Window_; safecall;
    procedure Detach; safecall;
    procedure Attach(lWindowHandle: Integer); safecall;
    function Get_HWnd: Integer; safecall;
    property VBE: VBE read Get_VBE;
    property Collection: Windows read Get_Collection;
    property Caption: WideString read Get_Caption;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property WindowState: vbext_WindowState read Get_WindowState write Set_WindowState;
    property Type_: vbext_WindowType read Get_Type_;
    property LinkedWindows: LinkedWindows read Get_LinkedWindows;
    property LinkedWindowFrame: Window_ read Get_LinkedWindowFrame;
    property HWnd: Integer read Get_HWnd;
  end;

// *********************************************************************//
// Interface: _Windows_
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E16A-0000-0000-C000-000000000046}
// *********************************************************************//
  _Windows_ = interface(IDispatch)
    ['{0002E16A-0000-0000-C000-000000000046}']
    function Get_VBE: VBE; safecall;
    function Get_Parent: Application_; safecall;
    function Item(index: OleVariant): Window_; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    property VBE: VBE read Get_VBE;
    property Parent: Application_ read Get_Parent;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// Interface: _LinkedWindows
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E16C-0000-0000-C000-000000000046}
// *********************************************************************//
  _LinkedWindows = interface(IDispatch)
    ['{0002E16C-0000-0000-C000-000000000046}']
    function Get_VBE: VBE; safecall;
    function Get_Parent: Window_; safecall;
    function Item(index: OleVariant): Window_; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Remove(const Window_: Window_); safecall;
    procedure Add(const Window_: Window_); safecall;
    property VBE: VBE read Get_VBE;
    property Parent: Window_ read Get_Parent;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// Interface: Events
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E167-0000-0000-C000-000000000046}
// *********************************************************************//
  Events = interface(IDispatch)
    ['{0002E167-0000-0000-C000-000000000046}']
    function Get_ReferencesEvents(const VBProject: VBProject): ReferencesEvents; safecall;
    function Get_CommandBarEvents(const CommandBarControl: IDispatch): CommandBarEvents; safecall;
    property ReferencesEvents[const VBProject: VBProject]: ReferencesEvents read Get_ReferencesEvents;
    property CommandBarEvents[const CommandBarControl: IDispatch]: CommandBarEvents read Get_CommandBarEvents;
  end;

// *********************************************************************//
// Interface: _VBProjectsEvents
// Flags:     (256) OleAutomation
// GUID:      {0002E113-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBProjectsEvents = interface(IUnknown)
    ['{0002E113-0000-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: _VBComponentsEvents
// Flags:     (256) OleAutomation
// GUID:      {0002E115-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBComponentsEvents = interface(IUnknown)
    ['{0002E115-0000-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: _ReferencesEvents
// Flags:     (256) OleAutomation
// GUID:      {0002E11A-0000-0000-C000-000000000046}
// *********************************************************************//
  _ReferencesEvents = interface(IUnknown)
    ['{0002E11A-0000-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: _CommandBarControlEvents
// Flags:     (256) OleAutomation
// GUID:      {0002E130-0000-0000-C000-000000000046}
// *********************************************************************//
  _CommandBarControlEvents = interface(IUnknown)
    ['{0002E130-0000-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: _ProjectTemplate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E159-0000-0000-C000-000000000046}
// *********************************************************************//
  _ProjectTemplate = interface(IDispatch)
    ['{0002E159-0000-0000-C000-000000000046}']
    function Get_Application_: Application_; safecall;
    function Get_Parent: Application_; safecall;
    property Application_: Application_ read Get_Application_;
    property Parent: Application_ read Get_Parent;
  end;

// *********************************************************************//
// Interface: _VBProject
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E160-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBProject = interface(_ProjectTemplate)
    ['{0002E160-0000-0000-C000-000000000046}']
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const lpbstrHelpFile: WideString); safecall;
    function Get_HelpContextID: Integer; safecall;
    procedure Set_HelpContextID(lpdwContextID: Integer); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const lpbstrDescription: WideString); safecall;
    function Get_Mode: vbext_VBAMode; safecall;
    function Get_References: References; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const lpbstrName: WideString); safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: VBProjects; safecall;
    function Get_Protection: vbext_ProjectProtection; safecall;
    function Get_Saved: WordBool; safecall;
    function Get_VBComponents: VBComponents; safecall;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property HelpContextID: Integer read Get_HelpContextID write Set_HelpContextID;
    property Description: WideString read Get_Description write Set_Description;
    property Mode: vbext_VBAMode read Get_Mode;
    property References: References read Get_References;
    property Name: WideString read Get_Name write Set_Name;
    property VBE: VBE read Get_VBE;
    property Collection: VBProjects read Get_Collection;
    property Protection: vbext_ProjectProtection read Get_Protection;
    property Saved: WordBool read Get_Saved;
    property VBComponents: VBComponents read Get_VBComponents;
  end;

// *********************************************************************//
// Interface: _VBProjects
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E165-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBProjects = interface(IDispatch)
    ['{0002E165-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBProject; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Parent: VBE; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    property VBE: VBE read Get_VBE;
    property Parent: VBE read Get_Parent;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// Interface: SelectedComponents
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {BE39F3D4-1B13-11D0-887F-00A0C90F2744}
// *********************************************************************//
  SelectedComponents = interface(IDispatch)
    ['{BE39F3D4-1B13-11D0-887F-00A0C90F2744}']
    function Item(index: SYSINT): Component; safecall;
    function Get_Application_: Application_; safecall;
    function Get_Parent: VBProject; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    property Application_: Application_ read Get_Application_;
    property Parent: VBProject read Get_Parent;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// Interface: _Components
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E161-0000-0000-C000-000000000046}
// *********************************************************************//
  _Components = interface(IDispatch)
    ['{0002E161-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Component; safecall;
    function Get_Application_: Application_; safecall;
    function Get_Parent: VBProject; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Remove(const Component: Component); safecall;
    function Add(ComponentType: vbext_ComponentType): Component; safecall;
    function Import(const FileName: WideString): Component; safecall;
    function Get_VBE: VBE; safecall;
    property Application_: Application_ read Get_Application_;
    property Parent: VBProject read Get_Parent;
    property Count: Integer read Get_Count;
    property VBE: VBE read Get_VBE;
  end;

// *********************************************************************//
// Interface: _VBComponents
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E162-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBComponents = interface(IDispatch)
    ['{0002E162-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBComponent; safecall;
    function Get_Parent: VBProject; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Remove(const VBComponent: VBComponent); safecall;
    function Add(ComponentType: vbext_ComponentType): VBComponent; safecall;
    function Import(const FileName: WideString): VBComponent; safecall;
    function Get_VBE: VBE; safecall;
    property Parent: VBProject read Get_Parent;
    property Count: Integer read Get_Count;
    property VBE: VBE read Get_VBE;
  end;

// *********************************************************************//
// Interface: _Component
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E163-0000-0000-C000-000000000046}
// *********************************************************************//
  _Component = interface(IDispatch)
    ['{0002E163-0000-0000-C000-000000000046}']
    function Get_Application_: Application_; safecall;
    function Get_Parent: Components; safecall;
    function Get_IsDirty: WordBool; safecall;
    procedure Set_IsDirty(lpfReturn: WordBool); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pbstrReturn: WideString); safecall;
    property Application_: Application_ read Get_Application_;
    property Parent: Components read Get_Parent;
    property IsDirty: WordBool read Get_IsDirty write Set_IsDirty;
    property Name: WideString read Get_Name write Set_Name;
  end;

// *********************************************************************//
// Interface: _VBComponent
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E164-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBComponent = interface(IDispatch)
    ['{0002E164-0000-0000-C000-000000000046}']
    function Get_Saved: WordBool; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pbstrReturn: WideString); safecall;
    function Get_Designer: IDispatch; safecall;
    function Get_CodeModule: CodeModule; safecall;
    function Get_Type_: vbext_ComponentType; safecall;
    procedure Export(const FileName: WideString); safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: VBComponents; safecall;
    function Get_HasOpenDesigner: WordBool; safecall;
    function Get_Properties: Properties; safecall;
    function DesignerWindow: Window_; safecall;
    procedure Activate; safecall;
    property Saved: WordBool read Get_Saved;
    property Name: WideString read Get_Name write Set_Name;
    property Designer: IDispatch read Get_Designer;
    property CodeModule: CodeModule read Get_CodeModule;
    property Type_: vbext_ComponentType read Get_Type_;
    property VBE: VBE read Get_VBE;
    property Collection: VBComponents read Get_Collection;
    property HasOpenDesigner: WordBool read Get_HasOpenDesigner;
    property Properties: Properties read Get_Properties;
  end;

// *********************************************************************//
// Interface: Property_
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E18C-0000-0000-C000-000000000046}
// *********************************************************************//
  Property_ = interface(IDispatch)
    ['{0002E18C-0000-0000-C000-000000000046}']
    function Get_Value: OleVariant; safecall;
    procedure Set_Value(lppvReturn: OleVariant); safecall;
    function Get_IndexedValue(Index1: OleVariant; Index2: OleVariant; Index3: OleVariant; 
                              Index4: OleVariant): OleVariant; safecall;
    procedure Set_IndexedValue(Index1: OleVariant; Index2: OleVariant; Index3: OleVariant; 
                               Index4: OleVariant; lppvReturn: OleVariant); safecall;
    function Get_NumIndices: Smallint; safecall;
    function Get_Application_: Application_; safecall;
    function Get_Parent: Properties; safecall;
    function Get_Name: WideString; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: Properties; safecall;
    function Get_Object_: IUnknown; safecall;
    procedure Set_Object_(const lppunk: IUnknown); safecall;
    property Value: OleVariant read Get_Value write Set_Value;
    property IndexedValue[Index1: OleVariant; Index2: OleVariant; Index3: OleVariant; 
                          Index4: OleVariant]: OleVariant read Get_IndexedValue write Set_IndexedValue;
    property NumIndices: Smallint read Get_NumIndices;
    property Application_: Application_ read Get_Application_;
    property Parent: Properties read Get_Parent;
    property Name: WideString read Get_Name;
    property VBE: VBE read Get_VBE;
    property Collection: Properties read Get_Collection;
    property Object_: IUnknown read Get_Object_ write Set_Object_;
  end;

// *********************************************************************//
// Interface: _Properties
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E188-0000-0000-C000-000000000046}
// *********************************************************************//
  _Properties = interface(IDispatch)
    ['{0002E188-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Property_; safecall;
    function Get_Application_: Application_; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    function Get_VBE: VBE; safecall;
    property Application_: Application_ read Get_Application_;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property VBE: VBE read Get_VBE;
  end;

// *********************************************************************//
// Interface: _CodeModule
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E16E-0000-0000-C000-000000000046}
// *********************************************************************//
  _CodeModule = interface(IDispatch)
    ['{0002E16E-0000-0000-C000-000000000046}']
    function Get_Parent: VBComponent; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pbstrName: WideString); safecall;
    procedure AddFromString(const String_: WideString); safecall;
    procedure AddFromFile(const FileName: WideString); safecall;
    function Get_Lines(StartLine: Integer; Count: Integer): WideString; safecall;
    function Get_CountOfLines: Integer; safecall;
    procedure InsertLines(Line: Integer; const String_: WideString); safecall;
    procedure DeleteLines(StartLine: Integer; Count: Integer); safecall;
    procedure ReplaceLine(Line: Integer; const String_: WideString); safecall;
    function Get_ProcStartLine(const ProcName: WideString; ProcKind: vbext_ProcKind): Integer; safecall;
    function Get_ProcCountLines(const ProcName: WideString; ProcKind: vbext_ProcKind): Integer; safecall;
    function Get_ProcBodyLine(const ProcName: WideString; ProcKind: vbext_ProcKind): Integer; safecall;
    function Get_ProcOfLine(Line: Integer; out ProcKind: vbext_ProcKind): WideString; safecall;
    function Get_CountOfDeclarationLines: Integer; safecall;
    function CreateEventProc(const EventName: WideString; const ObjectName: WideString): Integer; safecall;
    function Find(const Target: WideString; var StartLine: Integer; var StartColumn: Integer; 
                  var EndLine: Integer; var EndColumn: Integer; WholeWord: WordBool; 
                  MatchCase: WordBool; PatternSearch: WordBool): WordBool; safecall;
    function Get_CodePane: CodePane; safecall;
    property Parent: VBComponent read Get_Parent;
    property VBE: VBE read Get_VBE;
    property Name: WideString read Get_Name write Set_Name;
    property Lines[StartLine: Integer; Count: Integer]: WideString read Get_Lines;
    property CountOfLines: Integer read Get_CountOfLines;
    property ProcStartLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer read Get_ProcStartLine;
    property ProcCountLines[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer read Get_ProcCountLines;
    property ProcBodyLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer read Get_ProcBodyLine;
    property ProcOfLine[Line: Integer; out ProcKind: vbext_ProcKind]: WideString read Get_ProcOfLine;
    property CountOfDeclarationLines: Integer read Get_CountOfDeclarationLines;
    property CodePane: CodePane read Get_CodePane;
  end;

// *********************************************************************//
// Interface: _CodePanes
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E172-0000-0000-C000-000000000046}
// *********************************************************************//
  _CodePanes = interface(IDispatch)
    ['{0002E172-0000-0000-C000-000000000046}']
    function Get_Parent: VBE; safecall;
    function Get_VBE: VBE; safecall;
    function Item(index: OleVariant): CodePane; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    function Get_Current: CodePane; safecall;
    procedure Set_Current(const CodePane: CodePane); safecall;
    property Parent: VBE read Get_Parent;
    property VBE: VBE read Get_VBE;
    property Count: Integer read Get_Count;
    property Current: CodePane read Get_Current write Set_Current;
  end;

// *********************************************************************//
// Interface: _CodePane
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E176-0000-0000-C000-000000000046}
// *********************************************************************//
  _CodePane = interface(IDispatch)
    ['{0002E176-0000-0000-C000-000000000046}']
    function Get_Collection: CodePanes; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Window_: Window_; safecall;
    procedure GetSelection(out StartLine: Integer; out StartColumn: Integer; out EndLine: Integer; 
                           out EndColumn: Integer); safecall;
    procedure SetSelection(StartLine: Integer; StartColumn: Integer; EndLine: Integer; 
                           EndColumn: Integer); safecall;
    function Get_TopLine: Integer; safecall;
    procedure Set_TopLine(TopLine: Integer); safecall;
    function Get_CountOfVisibleLines: Integer; safecall;
    function Get_CodeModule: CodeModule; safecall;
    procedure Show; safecall;
    function Get_CodePaneView: vbext_CodePaneview; safecall;
    property Collection: CodePanes read Get_Collection;
    property VBE: VBE read Get_VBE;
    property Window_: Window_ read Get_Window_;
    property TopLine: Integer read Get_TopLine write Set_TopLine;
    property CountOfVisibleLines: Integer read Get_CountOfVisibleLines;
    property CodeModule: CodeModule read Get_CodeModule;
    property CodePaneView: vbext_CodePaneview read Get_CodePaneView;
  end;

// *********************************************************************//
// Interface: _References
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E17A-0000-0000-C000-000000000046}
// *********************************************************************//
  _References = interface(IDispatch)
    ['{0002E17A-0000-0000-C000-000000000046}']
    function Get_Parent: VBProject; safecall;
    function Get_VBE: VBE; safecall;
    function Item(index: OleVariant): Reference; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    function AddFromGuid(const Guid: WideString; Major: Integer; Minor: Integer): Reference; safecall;
    function AddFromFile(const FileName: WideString): Reference; safecall;
    procedure Remove(const Reference: Reference); safecall;
    property Parent: VBProject read Get_Parent;
    property VBE: VBE read Get_VBE;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// Interface: Reference
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E17E-0000-0000-C000-000000000046}
// *********************************************************************//
  Reference = interface(IDispatch)
    ['{0002E17E-0000-0000-C000-000000000046}']
    function Get_Collection: References; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Name: WideString; safecall;
    function Get_Guid: WideString; safecall;
    function Get_Major: Integer; safecall;
    function Get_Minor: Integer; safecall;
    function Get_FullPath: WideString; safecall;
    function Get_BuiltIn: WordBool; safecall;
    function Get_IsBroken: WordBool; safecall;
    function Get_Type_: vbext_RefKind; safecall;
    function Get_Description: WideString; safecall;
    property Collection: References read Get_Collection;
    property VBE: VBE read Get_VBE;
    property Name: WideString read Get_Name;
    property Guid: WideString read Get_Guid;
    property Major: Integer read Get_Major;
    property Minor: Integer read Get_Minor;
    property FullPath: WideString read Get_FullPath;
    property BuiltIn: WordBool read Get_BuiltIn;
    property IsBroken: WordBool read Get_IsBroken;
    property Type_: vbext_RefKind read Get_Type_;
    property Description: WideString read Get_Description;
  end;

// *********************************************************************//
// DispIntf:  Application_Disp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E158-0000-0000-C000-000000000046}
// *********************************************************************//
  Application_Disp = dispinterface
    ['{0002E158-0000-0000-C000-000000000046}']
    property Version: WideString readonly dispid 100;
  end;

// *********************************************************************//
// DispIntf:  VBEDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E166-0000-0000-C000-000000000046}
// *********************************************************************//
  VBEDisp = dispinterface
    ['{0002E166-0000-0000-C000-000000000046}']
    property VBProjects: VBProjects readonly dispid 107;
    property CommandBars: CommandBars readonly dispid 108;
    property CodePanes: CodePanes readonly dispid 109;
    property Windows: Windows readonly dispid 110;
    property Events: Events readonly dispid 111;
    property ActiveVBProject: VBProject dispid 201;
    property SelectedVBComponent: VBComponent readonly dispid 202;
    property MainWindow: Window_ readonly dispid 204;
    property ActiveWindow: Window_ readonly dispid 205;
    property ActiveCodePane: CodePane dispid 206;
    property Version: WideString readonly dispid 100;
  end;

// *********************************************************************//
// DispIntf:  Window_Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E16B-0000-0000-C000-000000000046}
// *********************************************************************//
  Window_Disp = dispinterface
    ['{0002E16B-0000-0000-C000-000000000046}']
    property VBE: VBE readonly dispid 1;
    property Collection: Windows readonly dispid 2;
    procedure Close; dispid 99;
    property Caption: WideString readonly dispid 100;
    property Visible: WordBool dispid 106;
    property Left: Integer dispid 101;
    property Top: Integer dispid 103;
    property Width: Integer dispid 105;
    property Height: Integer dispid 107;
    property WindowState: vbext_WindowState dispid 109;
    procedure SetFocus; dispid 111;
    property Type_: vbext_WindowType readonly dispid 112;
    procedure SetKind(eKind: vbext_WindowType); dispid 113;
    property LinkedWindows: LinkedWindows readonly dispid 116;
    property LinkedWindowFrame: Window_ readonly dispid 117;
    procedure Detach; dispid 118;
    procedure Attach(lWindowHandle: Integer); dispid 119;
    property HWnd: Integer readonly dispid 120;
  end;

// *********************************************************************//
// DispIntf:  _Windows_Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E16A-0000-0000-C000-000000000046}
// *********************************************************************//
  _Windows_Disp = dispinterface
    ['{0002E16A-0000-0000-C000-000000000046}']
    property VBE: VBE readonly dispid 1;
    property Parent: Application_ readonly dispid 2;
    function Item(index: OleVariant): Window_; dispid 0;
    property Count: Integer readonly dispid 201;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  _LinkedWindowsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E16C-0000-0000-C000-000000000046}
// *********************************************************************//
  _LinkedWindowsDisp = dispinterface
    ['{0002E16C-0000-0000-C000-000000000046}']
    property VBE: VBE readonly dispid 1;
    property Parent: Window_ readonly dispid 2;
    function Item(index: OleVariant): Window_; dispid 0;
    property Count: Integer readonly dispid 201;
    function _NewEnum: IUnknown; dispid -4;
    procedure Remove(const Window_: Window_); dispid 202;
    procedure Add(const Window_: Window_); dispid 203;
  end;

// *********************************************************************//
// DispIntf:  EventsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E167-0000-0000-C000-000000000046}
// *********************************************************************//
  EventsDisp = dispinterface
    ['{0002E167-0000-0000-C000-000000000046}']
    property ReferencesEvents[const VBProject: VBProject]: ReferencesEvents readonly dispid 202;
    property CommandBarEvents[const CommandBarControl: IDispatch]: CommandBarEvents readonly dispid 205;
  end;

// *********************************************************************//
// DispIntf:  _dispVBProjectsEvents
// Flags:     (4096) Dispatchable
// GUID:      {0002E103-0000-0000-C000-000000000046}
// *********************************************************************//
  _dispVBProjectsEvents = dispinterface
    ['{0002E103-0000-0000-C000-000000000046}']
    procedure ItemAdded(const VBProject: VBProject); dispid 1;
    procedure ItemRemoved(const VBProject: VBProject); dispid 2;
    procedure ItemRenamed(const VBProject: VBProject; const OldName: WideString); dispid 3;
    procedure ItemActivated(const VBProject: VBProject); dispid 4;
  end;

// *********************************************************************//
// DispIntf:  _dispVBComponentsEvents
// Flags:     (4096) Dispatchable
// GUID:      {0002E116-0000-0000-C000-000000000046}
// *********************************************************************//
  _dispVBComponentsEvents = dispinterface
    ['{0002E116-0000-0000-C000-000000000046}']
    procedure ItemAdded(const VBComponent: VBComponent); dispid 1;
    procedure ItemRemoved(const VBComponent: VBComponent); dispid 2;
    procedure ItemRenamed(const VBComponent: VBComponent; const OldName: WideString); dispid 3;
    procedure ItemSelected(const VBComponent: VBComponent); dispid 4;
    procedure ItemActivated(const VBComponent: VBComponent); dispid 5;
    procedure ItemReloaded(const VBComponent: VBComponent); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  _dispReferencesEvents
// Flags:     (4096) Dispatchable
// GUID:      {0002E118-0000-0000-C000-000000000046}
// *********************************************************************//
  _dispReferencesEvents = dispinterface
    ['{0002E118-0000-0000-C000-000000000046}']
    procedure ItemAdded(const Reference: Reference); dispid 1;
    procedure ItemRemoved(const Reference: Reference); dispid 2;
  end;

// *********************************************************************//
// DispIntf:  _dispCommandBarControlEvents
// Flags:     (4096) Dispatchable
// GUID:      {0002E131-0000-0000-C000-000000000046}
// *********************************************************************//
  _dispCommandBarControlEvents = dispinterface
    ['{0002E131-0000-0000-C000-000000000046}']
    procedure Click(const CommandBarControl: IDispatch; var handled: WordBool;
                    var CancelDefault: WordBool); dispid 1;
  end;

// *********************************************************************//
// DispIntf:  _ProjectTemplateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E159-0000-0000-C000-000000000046}
// *********************************************************************//
  _ProjectTemplateDisp = dispinterface
    ['{0002E159-0000-0000-C000-000000000046}']
    property Application_: Application_ readonly dispid 1;
    property Parent: Application_ readonly dispid 2;
  end;

// *********************************************************************//
// DispIntf:  _VBProjectDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E160-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBProjectDisp = dispinterface
    ['{0002E160-0000-0000-C000-000000000046}']
    property HelpFile: WideString dispid 116;
    property HelpContextID: Integer dispid 117;
    property Description: WideString dispid 118;
    property Mode: vbext_VBAMode readonly dispid 119;
    property References: References readonly dispid 120;
    property Name: WideString dispid 121;
    property VBE: VBE readonly dispid 122;
    property Collection: VBProjects readonly dispid 123;
    property Protection: vbext_ProjectProtection readonly dispid 131;
    property Saved: WordBool readonly dispid 133;
    property VBComponents: VBComponents readonly dispid 135;
    property Application_: Application_ readonly dispid 1;
    property Parent: Application_ readonly dispid 2;
  end;

// *********************************************************************//
// DispIntf:  _VBProjectsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E165-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBProjectsDisp = dispinterface
    ['{0002E165-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBProject; dispid 0;
    property VBE: VBE readonly dispid 20;
    property Parent: VBE readonly dispid 2;
    property Count: Integer readonly dispid 10;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  SelectedComponentsDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {BE39F3D4-1B13-11D0-887F-00A0C90F2744}
// *********************************************************************//
  SelectedComponentsDisp = dispinterface
    ['{BE39F3D4-1B13-11D0-887F-00A0C90F2744}']
    function Item(index: SYSINT): Component; dispid 0;
    property Application_: Application_ readonly dispid 1;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  _ComponentsDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E161-0000-0000-C000-000000000046}
// *********************************************************************//
  _ComponentsDisp = dispinterface
    ['{0002E161-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Component; dispid 0;
    property Application_: Application_ readonly dispid 1;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
    function _NewEnum: IUnknown; dispid -4;
    procedure Remove(const Component: Component); dispid 11;
    function Add(ComponentType: vbext_ComponentType): Component; dispid 12;
    function Import(const FileName: WideString): Component; dispid 13;
    property VBE: VBE readonly dispid 20;
  end;

// *********************************************************************//
// DispIntf:  _VBComponentsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E162-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBComponentsDisp = dispinterface
    ['{0002E162-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBComponent; dispid 0;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
    function _NewEnum: IUnknown; dispid -4;
    procedure Remove(const VBComponent: VBComponent); dispid 11;
    function Add(ComponentType: vbext_ComponentType): VBComponent; dispid 12;
    function Import(const FileName: WideString): VBComponent; dispid 13;
    property VBE: VBE readonly dispid 20;
  end;

// *********************************************************************//
// DispIntf:  _ComponentDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0002E163-0000-0000-C000-000000000046}
// *********************************************************************//
  _ComponentDisp = dispinterface
    ['{0002E163-0000-0000-C000-000000000046}']
    property Application_: Application_ readonly dispid 1;
    property Parent: Components readonly dispid 2;
    property IsDirty: WordBool dispid 10;
    property Name: WideString dispid 48;
  end;

// *********************************************************************//
// DispIntf:  _VBComponentDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E164-0000-0000-C000-000000000046}
// *********************************************************************//
  _VBComponentDisp = dispinterface
    ['{0002E164-0000-0000-C000-000000000046}']
    property Saved: WordBool readonly dispid 10;
    property Name: WideString dispid 48;
    property Designer: IDispatch readonly dispid 49;
    property CodeModule: CodeModule readonly dispid 50;
    property Type_: vbext_ComponentType readonly dispid 51;
    procedure Export(const FileName: WideString); dispid 52;
    property VBE: VBE readonly dispid 53;
    property Collection: VBComponents readonly dispid 54;
    property HasOpenDesigner: WordBool readonly dispid 55;
    property Properties: Properties readonly dispid 56;
    function DesignerWindow: Window_; dispid 57;
    procedure Activate; dispid 60;
  end;

// *********************************************************************//
// DispIntf:  Property_Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E18C-0000-0000-C000-000000000046}
// *********************************************************************//
  Property_Disp = dispinterface
    ['{0002E18C-0000-0000-C000-000000000046}']
    property Value: OleVariant dispid 0;
    property IndexedValue[Index1: OleVariant; Index2: OleVariant; Index3: OleVariant;
                          Index4: OleVariant]: OleVariant dispid 3;
    property NumIndices: Smallint readonly dispid 4;
    property Application_: Application_ readonly dispid 1;
    property Parent: Properties readonly dispid 2;
    property Name: WideString readonly dispid 40;
    property VBE: VBE readonly dispid 41;
    property Collection: Properties readonly dispid 42;
    property Object_: IUnknown dispid 45;
  end;

// *********************************************************************//
// DispIntf:  _PropertiesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0002E188-0000-0000-C000-000000000046}
// *********************************************************************//
  _PropertiesDisp = dispinterface
    ['{0002E188-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Property_; dispid 0;
    property Application_: Application_ readonly dispid 1;
    property Parent: IDispatch readonly dispid 2;
    property Count: Integer readonly dispid 40;
    function _NewEnum: IUnknown; dispid -4;
    property VBE: VBE readonly dispid 10;
  end;

// *********************************************************************//
// DispIntf:  _CodeModuleDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E16E-0000-0000-C000-000000000046}
// *********************************************************************//
  _CodeModuleDisp = dispinterface
    ['{0002E16E-0000-0000-C000-000000000046}']
    property Parent: VBComponent readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    property Name: WideString dispid 0;
    procedure AddFromString(const String_: WideString); dispid 1610743812;
    procedure AddFromFile(const FileName: WideString); dispid 1610743813;
    property Lines[StartLine: Integer; Count: Integer]: WideString readonly dispid 1610743814;
    property CountOfLines: Integer readonly dispid 1610743815;
    procedure InsertLines(Line: Integer; const String_: WideString); dispid 1610743816;
    procedure DeleteLines(StartLine: Integer; Count: Integer); dispid 1610743817;
    procedure ReplaceLine(Line: Integer; const String_: WideString); dispid 1610743818;
    property ProcStartLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer readonly dispid 1610743819;
    property ProcCountLines[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer readonly dispid 1610743820;
    property ProcBodyLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer readonly dispid 1610743821;
    property ProcOfLine[Line: Integer; out ProcKind: vbext_ProcKind]: WideString readonly dispid 1610743822;
    property CountOfDeclarationLines: Integer readonly dispid 1610743823;
    function CreateEventProc(const EventName: WideString; const ObjectName: WideString): Integer; dispid 1610743824;
    function Find(const Target: WideString; var StartLine: Integer; var StartColumn: Integer; 
                  var EndLine: Integer; var EndColumn: Integer; WholeWord: WordBool; 
                  MatchCase: WordBool; PatternSearch: WordBool): WordBool; dispid 1610743825;
    property CodePane: CodePane readonly dispid 1610743826;
  end;

// *********************************************************************//
// DispIntf:  _CodePanesDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E172-0000-0000-C000-000000000046}
// *********************************************************************//
  _CodePanesDisp = dispinterface
    ['{0002E172-0000-0000-C000-000000000046}']
    property Parent: VBE readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    function Item(index: OleVariant): CodePane; dispid 0;
    property Count: Integer readonly dispid 1610743811;
    function _NewEnum: IUnknown; dispid -4;
    property Current: CodePane dispid 1610743813;
  end;

// *********************************************************************//
// DispIntf:  _CodePaneDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E176-0000-0000-C000-000000000046}
// *********************************************************************//
  _CodePaneDisp = dispinterface
    ['{0002E176-0000-0000-C000-000000000046}']
    property Collection: CodePanes readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    property Window_: Window_ readonly dispid 1610743810;
    procedure GetSelection(out StartLine: Integer; out StartColumn: Integer; out EndLine: Integer;
                           out EndColumn: Integer); dispid 1610743811;
    procedure SetSelection(StartLine: Integer; StartColumn: Integer; EndLine: Integer;
                           EndColumn: Integer); dispid 1610743812;
    property TopLine: Integer dispid 1610743813;
    property CountOfVisibleLines: Integer readonly dispid 1610743815;
    property CodeModule: CodeModule readonly dispid 1610743816;
    procedure Show; dispid 1610743817;
    property CodePaneView: vbext_CodePaneview readonly dispid 1610743818;
  end;

// *********************************************************************//
// DispIntf:  _ReferencesDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E17A-0000-0000-C000-000000000046}
// *********************************************************************//
  _ReferencesDisp = dispinterface
    ['{0002E17A-0000-0000-C000-000000000046}']
    property Parent: VBProject readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    function Item(index: OleVariant): Reference; dispid 0;
    property Count: Integer readonly dispid 1610743811;
    function _NewEnum: IUnknown; dispid -4;
    function AddFromGuid(const Guid: WideString; Major: Integer; Minor: Integer): Reference; dispid 1610743813;
    function AddFromFile(const FileName: WideString): Reference; dispid 1610743814;
    procedure Remove(const Reference: Reference); dispid 1610743815;
  end;

// *********************************************************************//
// DispIntf:  ReferenceDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0002E17E-0000-0000-C000-000000000046}
// *********************************************************************//
  ReferenceDisp = dispinterface
    ['{0002E17E-0000-0000-C000-000000000046}']
    property Collection: References readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    property Name: WideString readonly dispid 1610743810;
    property Guid: WideString readonly dispid 1610743811;
    property Major: Integer readonly dispid 1610743812;
    property Minor: Integer readonly dispid 1610743813;
    property FullPath: WideString readonly dispid 1610743814;
    property BuiltIn: WordBool readonly dispid 1610743815;
    property IsBroken: WordBool readonly dispid 1610743816;
    property Type_: vbext_RefKind readonly dispid 1610743817;
    property Description: WideString readonly dispid 1610743818;
  end;

// *********************************************************************//
// DispIntf:  _dispReferences_Events
// Flags:     (4240) Hidden NonExtensible Dispatchable
// GUID:      {CDDE3804-2064-11CF-867F-00AA005FF34A}
// *********************************************************************//
  _dispReferences_Events = dispinterface
    ['{CDDE3804-2064-11CF-867F-00AA005FF34A}']
    procedure ItemAdded(const Reference: Reference); dispid 0;
    procedure ItemRemoved(const Reference: Reference); dispid 1;
  end;

{$ENDIF}

implementation

uses ComObj;

end.

