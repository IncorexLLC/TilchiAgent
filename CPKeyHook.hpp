// Borland C++ Builder
// Copyright (c) 1995, 2005 by Borland Software Corporation
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Cpkeyhook.pas' rev: 10.00

#ifndef CpkeyhookHPP
#define CpkeyhookHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Cpkeyhook
{
//-- type declarations -------------------------------------------------------
struct TMMFData;
typedef TMMFData *PMMFData;

struct TMMFData
{
	
public:
	HHOOK NextHook;
	HWND WinHandle;
	unsigned MsgToSend;
	bool BlockKeys;
} ;

typedef bool __stdcall (*TFncHookStart)(AnsiString LicenceCode, HWND WinHandle, unsigned MsgToSend, bool DisableKeyboard);

typedef bool __stdcall (*TFncHookStop)(void);

typedef bool __stdcall (*TFncHookUpdateHook)(bool DisableKeyboard);

#pragma pack(push,1)
struct TKeyStates
{
	
public:
	bool KeyDown;
	bool ShiftDown;
	bool AltDown;
	bool CtrlDown;
	bool ExtendedKey;
	bool MenuKey;
	bool KeyRepeated;
	int RepeatCount;
	bool DeadKey;
	bool DoubleKey;
} ;
#pragma pack(pop)

#pragma pack(push,1)
struct TKeyNames
{
	
public:
	char KeyChar;
	char KeyExtName[101];
} ;
#pragma pack(pop)

typedef void __fastcall (__closure *TKeyHookedEvent)(System::TObject* Sender, const TKeyStates &AKeyStates, const TKeyNames &AKeyNames);

class DELPHICLASS TCPKeyHook;
class PASCALIMPLEMENTATION TCPKeyHook : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	bool FHookLibLoaded;
	AnsiString FLicenceCode;
	HWND FWindowHandle;
	unsigned FUserHookMsg;
	bool FDisableKeyboard;
	bool FEnabled;
	AnsiString FKeyLayout;
	TKeyHookedEvent FOnKey;
	void __fastcall SetEnabled(bool AValue);
	void __fastcall SetNoneStr(AnsiString AValue);
	void __fastcall SetLicenceCode(AnsiString AValue);
	void __fastcall SetUserHookMsg(unsigned AMsg);
	void __fastcall SetDisableKeyboard(bool AValue);
	void __fastcall WndProc(Messages::TMessage &Msg);
	bool __fastcall LoadHookLib(void);
	bool __fastcall UnloadHookLib(void);
	
protected:
	void __fastcall HookMsg(Messages::TMessage &msg);
	void __fastcall DeallocateHWnd(HWND Wnd);
	
public:
	__fastcall virtual TCPKeyHook(Classes::TComponent* AOwner);
	__fastcall virtual ~TCPKeyHook(void);
	bool __fastcall Start_KeyHook(void);
	bool __fastcall Stop_KeyHook(void);
	bool __fastcall UpdateHook(void);
	
__published:
	__property bool HookLibLoaded = {read=FHookLibLoaded, nodefault};
	__property AnsiString LicenceCode = {read=FLicenceCode, write=SetLicenceCode};
//	__property HWND WindowHandle = {read=FWindowHandle, nodefault};
	__property unsigned UserHookMsg = {read=FUserHookMsg, write=SetUserHookMsg, nodefault};
	__property bool DisableKeyboard = {read=FDisableKeyboard, write=SetDisableKeyboard, nodefault};
	__property bool Enabled = {read=FEnabled, write=SetEnabled, nodefault};
	__property AnsiString KeyboardLayout = {read=FKeyLayout, write=SetNoneStr};
	__property TKeyHookedEvent OnKey = {read=FOnKey, write=FOnKey};
};


//-- var, const, procedure ---------------------------------------------------
#define HOOKLIBNAME "Tilchi.dll"
extern PACKAGE unsigned WM_KEYHOOKMSG;
extern PACKAGE unsigned DllHandle;
extern PACKAGE TFncHookStart PFncHookStart;
extern PACKAGE TFncHookStop PFncHookStop;
extern PACKAGE TFncHookUpdateHook PFncHookUpdateHook;
extern PACKAGE int keyreps;
extern PACKAGE HKL klhandle;

}	/* namespace Cpkeyhook */
using namespace Cpkeyhook;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Cpkeyhook
