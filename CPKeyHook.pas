{*****************************************************************************
 * UnitName:  CPKeyHook
 * Version:   1.8 Experimental
 * Created:   23/04/2005
 * Purpose:   Global Keyboard Hook Unit and DLL.
 * Developer: BITLOGIC Software
 * Email:     development@bitlogic.co.uk
 * WebPage:   http://www.bitlogic.co.uk
 *****************************************************************************}

{*****************************************************************************

  23/04/2005 Updated to Version 1.8 Experimental

  Experimental version for keyboards using international dead-key character set.
  New Properties in TKeyState: DeadKey, DoubleKey: Boolean.
  Reverted TKeyNames.KeyChar back to Char Type.

  29/03/2005 Updated to Version 1.7
  
  Changed TKeyNames.KeyChar to WideChar for supporting Unicode characters and
  Foreign Keyboard Layouts that have dead key character keys.

  29/01/2005 Updated to Version 1.6

  Hard-coded DeallocateHwnd within the unit and also updated the DeallocateHwnd
  procedure which I think could be the cause of some AV's when using the Hook
  within a WinNT Service.

  Added function UpdateHook: boolean;

  The Function UpdateHook will notify the Hook of any changes made to the published
  properties (DisableKeyboard). This will allow you to update the settings without
  having to stop and start the Hook. To use this function you simply set the new
  properties then call UpdateHook.

  04/07/2004 Updated to Version 1.5

  The Hook DLL is now loaded dynamically using the LoadLibrary function and
  functions into the DLL are obtained by GetProcAddress. This was implemented
  to prevent error message if DLL could not be found.

  The Hook DLL is now automatically loaded with the Start_KeyHook function and
  unloaded with the Stop_KeyHook function. The loading of the DLL was removed
  from the TCPKeyHook.OnCreate event to prevent problems if the DLL was missing. 

  Added new property (HookLibLoaded: Boolean) to indicate if the DLL and functions
  successfully loaded. The Keyboard Hook will not start if this is False.

  Added new property (LicenceCode: string) for the DLL Licence check. For trial
  use this property can be left blank. Licenced users should set this property
  with your Licence Code for non-trial use.

*****************************************************************************}

unit CPKeyHook;

interface

uses Windows, Messages, Classes, Forms {,SysUtils};

const
  HOOKLIBNAME = 'Tilchi.dll';
  WM_KEYHOOKMSG: DWORD = WM_USER+100;

{type
  PHookParams = ^THookParams;
  THookParams = record
    wParam: WPARAM;
    lParam: LPARAM;
    KBS: TKeyboardState;
    end;}

type
  PMMFData = ^TMMFData;
  TMMFData = record
    NextHook : HHOOK;
    WinHandle : HWND;
    MsgToSend : DWORD;
    BlockKeys : boolean;
    {HookParams: THookParams;}
  end;

type
 { DLL Function Hook_Start }
 TFncHookStart = function(LicenceCode: string; WinHandle : HWND; MsgToSend : DWORD; DisableKeyboard: Boolean): boolean; stdcall;
 { DLL Function Hook_Stop }
 TFncHookStop = function: boolean; stdcall;
 { DLL Function Hook_UpdateHook }
 TFncHookUpdateHook = function(DisableKeyboard: boolean): boolean; stdcall;
  { DLL Function Hook_GetData }
 {TFncHookGetData = function: PHookParams; stdcall;}


type
TKeyStates = packed record
  KeyDown : Boolean;
  ShiftDown: Boolean;
  AltDown: Boolean;
  CtrlDown: Boolean;
  ExtendedKey: Boolean;
  MenuKey: Boolean;
  KeyRepeated: Boolean;
  RepeatCount: integer;
  DeadKey: boolean;
  DoubleKey: boolean;
  end;

TKeyNames = packed record
 KeyChar: Char;
 {KeyChar: WideChar;}
 KeyExtName: array[0..100] of Char;
 end;

type
TKeyHookedEvent = procedure(Sender: TObject; AKeyStates: TKeyStates; AKeyNames: TKeyNames) of object;

type
  TCPKeyHook = class(TComponent)
  private
   FHookLibLoaded: boolean;
   FLicenceCode: string;
   FWindowHandle: HWND;
   FUserHookMsg: DWORD;
   FDisableKeyboard: boolean;
   FEnabled: Boolean;
   FKeyLayout: string;
   FOnKey: TKeyHookedEvent;
   procedure SetEnabled(AValue: boolean);
   procedure SetNoneStr(AValue: string);
   procedure SetLicenceCode(AValue: string);
   procedure SetUserHookMsg(AMsg: DWORD);
   procedure SetDisableKeyboard(AValue: boolean);
   procedure WndProc(var Msg: TMessage);
   function LoadHookLib: boolean;
   function UnloadHookLib: boolean;
  protected
   procedure HookMsg(var msg : TMessage); //message WM_KEYHOOKMSG;
   procedure DeallocateHWnd(Wnd: HWND);
  public
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
   function Start_KeyHook: boolean;
   function Stop_KeyHook: boolean;
   function UpdateHook: boolean;
  published
   property HookLibLoaded: Boolean read FHookLibLoaded;
   property LicenceCode: string read FLicenceCode write SetLicenceCode;
   property WindowHandle: HWND read FWindowHandle;
   property UserHookMsg: DWORD read FUserHookMsg write SetUserHookMsg;
   property DisableKeyboard: boolean read FDisableKeyboard write SetDisableKeyboard;
   property Enabled: boolean read FEnabled write SetEnabled;
   property KeyboardLayout: string read FKeyLayout write SetNoneStr;
   property OnKey: TKeyHookedEvent read FOnKey write FOnKey;
  end;

var
 DllHandle: HModule;
 PFncHookStart: TFncHookStart;
 PFncHookStop: TFncHookStop;
 PFncHookUpdateHook: TFncHookUpdateHook;
 {PFncHookGetData: TFncHookGetData;}
 keyreps: integer;
 klhandle: HKL;

implementation

uses
  Dialogs;

{ Modified version of Classes.DeallocateHwnd }
procedure TCPKeyHook.DeallocateHWnd(Wnd: HWND);
var
  Instance: Pointer;
begin
  Instance := Pointer(GetWindowLong(Wnd, GWL_WNDPROC));
  if Instance <> @DefWindowProc then SetWindowLong(Wnd, GWL_WNDPROC, Longint(@DefWindowProc));
  FreeObjectInstance(Instance);
  DestroyWindow(Wnd);
end;

procedure TCPKeyHook.SetNoneStr(AValue: string);begin;end;
procedure TCPKeyHook.SetEnabled(AValue: boolean);begin;end;

procedure TCPKeyHook.SetLicenceCode(AValue: string);
begin
if AValue = FLicenceCode then exit;
FLicenceCode := AValue;
end;

procedure TCPKeyHook.SetUserHookMsg(AMsg: DWORD);
begin
if AMsg = FUserHookMsg then exit;
FUserHookMsg := AMsg;
end;

procedure TCPKeyHook.SetDisableKeyboard(AValue: boolean);
begin
if AValue = FDisableKeyboard then exit;
FDisableKeyboard := AValue;
end;

constructor TCPKeyHook.Create(AOwner: TComponent);
var
KLayout : array[0..KL_NAMELENGTH] of char;
begin
 inherited Create(AOwner);
 {if not (csDesigning in ComponentState) then}
FHookLibLoaded := False;
FWindowHandle := Classes.AllocateHWnd(WndProc);
FEnabled := False;
FUserHookMsg := WM_KEYHOOKMSG;
FDisableKeyboard := False;
keyreps := 0;
GetKeyboardLayoutName(@KLayout);
klhandle := GetKeyboardLayout(0);
FKeyLayout := KLayout;
end;

destructor TCPKeyHook.Destroy;
begin
TRY
if (FHookLibLoaded and FEnabled) then PFncHookStop;
FINALLY
UnloadHookLib;
DeallocateHWnd(FWindowHandle);
END;
inherited Destroy;
end;

procedure TCPKeyHook.WndProc(var Msg: TMessage);
begin
if Msg.Msg = FUserHookMsg then
     try
     HookMsg(Msg);
     except
     Application.HandleException(Self);
     end
  else Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TCPKeyHook.HookMsg(var msg : TMessage);
var
FKeyState: TKeyStates;
FKeyNames: TKeyNames;
VKeyName : array[0..100] of Char;
VCharBuf : array[0..2] of Char;
VWideCharBuf : array[1..127] of WideChar;
KBS: TKeyboardState;
retcode: Integer;
vkcode,scancode,charcode: integer;
KLayoutHandle: HKL;
{HookParams: PHookParams;}
begin
  {HookParams := PFncHookGetData;}

  vkcode := Msg.WParam; //Virtual KeyCode
  scancode := Msg.LParam; //Keyboard ScanCode
  GetKeyboardState(KBS);

  //WriteToLog('c:\temp\keyhook.log','Ascii: '+Char(Msg.WParam)+' wParam: '+inttostr(Msg.WParam)+' lParam: '+inttostr(Msg.LParam));

  fillchar(VCharBuf,SizeOf(VCharBuf),#0);
  fillchar(VWideCharBuf,SizeOf(VCharBuf),#0);
  fillchar(VKeyName,SizeOf(VKeyName),#0);
  fillchar(FKeyNames.KeyChar,SizeOf(FKeyNames.KeyChar), #0);
  FKeyNames.KeyChar := #0;

  FKeyState.KeyDown := (scancode AND (1 shl 31)) = 0;
  FKeyState.KeyRepeated := (scancode AND (1 shl 30)) <> 0;
  FKeyState.AltDown := (scancode AND (1 shl 29)) <> 0;
  FKeyState.MenuKey := (scancode AND (1 shl 28)) <> 0;
  FKeyState.ExtendedKey := (scancode AND (1 shl 24)) <> 0;
  FKeyState.CtrlDown := (GetKeyState(VK_CONTROL) AND (1 shl 15)) <> 0;
  FKeyState.ShiftDown  := (GetKeyState(VK_SHIFT) AND (1 shl 15)) <> 0;
  if (FKeyState.KeyRepeated and FKeyState.KeyDown) then inc(keyreps)
  else keyreps := 0;
  FKeyState.RepeatCount := keyreps;
  GetKeyNameText(scancode,@VKeyName,SizeOf(VKeyName));
  move(VKeyName,FKeyNames.KeyExtName,SizeOf(VKeyName));

  //GetKeyboardLayoutName(@KLayout);
  //klh := LoadKeyboardLayout(@KLayout,KLF_ACTIVATE);
  //if klh = 0 then raise exception.Create('LoadKeyboardLAyout: '+inttostr(klh));

  KLayoutHandle := GetKeyboardLayout(0);
  charcode := MapVirtualKeyEx(vkcode,2,KLayoutHandle);
  FKeyState.DeadKey := (charcode AND (1 shl 31) <> 0);

  {Not sure which functions are best to call here for obtaining Ascii Character ??
   Calling ToAscii or ToAsciiEx seem to have strange effects on dead-key characters.
   Not sure if this is caused by a Bug in the function calls as these functions
   alter the state and actual key being pressed.}
  if FKeyState.DeadKey then retcode := ToASCIIEx(vkcode, scancode, KBS, @VCharBuf, 0, KLayoutHandle);
  retcode := ToASCIIEx(vkcode, scancode, KBS, @VCharBuf, 0, KLayoutHandle);
  //retcode := ToAscii(vkcode, scancode, KBS, @VCharBuf, 0);
  //retcode := ToUnicodeEx(vkcode, scancode, @KBS, @VWideCharBuf, SizeOf(VWideCharBuf), 0, KLayoutHandle);

  //WriteToLog('c:\temp\keyhook.log','charcode = '+inttostr(CharCode)+' retcode = '+inttostr(retcode));

  case retcode of
       0: FKeyNames.KeyChar := #0; //no Ascii character for given keycode
       1: FKeyNames.KeyChar := Char(VCharBuf[0]); //one character in buffer
       2: begin
          //MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,@VWideCharBuf,SizeOf(VWideCharBuf),@VCharBuf,SizeOf(VCharBuf));
          FKeyNames.KeyChar := Char(VCharBuf[0]); //two characters in buffer, 1 is deadkey
          end;
       else begin
            //SendNotifyMessage(GetActiveWindow,WM_DEADCHAR,vkcode,scancode);
            FKeyNames.KeyChar := Char(VCharBuf[0]); //deadkey in character buffer
            end;
       end;
  FKeyState.DeadKey := (retcode <= -1);
  FKeyState.DoubleKey := (retcode = 2);
  Msg.Result := 1;
  if Assigned(FOnKey) then FOnKey(self,FKeyState,FKeyNames);
end;

function TCPKeyHook.Start_KeyHook: Boolean;
begin
Result := False;
if FEnabled then exit;
if Not LoadHookLib then exit;
if PFncHookStart(FLicenceCode,FWindowHandle,FUserHookMsg, FDisableKeyboard) then begin
   FEnabled := True;
   Result := True;
   end;
end;

function TCPKeyHook.Stop_KeyHook: Boolean;
begin
Result := False;
Try
if FEnabled then Result := PFncHookStop;
FEnabled := False;
Finally
UnloadHookLib;
End;
end;

function TCPKeyHook.UpdateHook: boolean;
begin
Result := False;
if FEnabled then Result := PFncHookUpdateHook(FDisableKeyboard);
end;

function TCPKeyHook.LoadHookLib: boolean;
begin
result := false;
if FHookLibLoaded then exit;
DllHandle := LoadLibrary(PChar(HOOKLIBNAME));
if DllHandle <> 0 then
   begin
   { Get pointers to DLL Hook Functions }
   PFncHookStart := GetProcAddress(DllHandle, 'KeyboardHook_Start');
   PFncHookStop := GetProcAddress(DllHandle, 'KeyboardHook_Stop');
   PFncHookUpdateHook := GetProcAddress(DllHandle, 'KeyboardHook_UpdateHook');
   {PFncHookGetData := GetProcAddress(DllHandle, 'KeyboardHook_GetData');}
   if Assigned(PFncHookStart) and Assigned(PFncHookStop) and Assigned(PFncHookUpdateHook) {and Assigned(PFncHookGetData)} then
      begin
      FHookLibLoaded := True;
      result := true;
      end else FreeLibrary(DllHandle);
   end;
end;

function TCPKeyHook.UnloadHookLib: boolean;
begin
result := false;
if DllHandle <> 0 then
   begin
   FreeLibrary(DllHandle);
   FHookLibLoaded := false;
   result := true;
   end;
End;

initialization

finalization
 if DllHandle <> 0 then FreeLibrary(DllHandle);

end.
