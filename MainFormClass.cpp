//$$---- Form CPP ----
//---------------------------------------------------------------------------
#include <vcl.h>
#include <shellapi.h>
#pragma hdrstop
#include "DataFile.hpp"
#include "MainFormClass.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TMainForm *MainForm;
const int IDC_TRAY1      = 1005;
const char *HINT_MESSAGE = "Incorex Tilchi 1.0";
//---------------------------------------------------------------------------
__fastcall TMainForm::TMainForm(TComponent* Owner) : TForm(Owner)
{
     // Load the icon from the EXE's resources
    TrayIcon = new Graphics::TIcon;
	TrayIcon->Handle = LoadImage(HInstance,"MAINICON",IMAGE_ICON,0,0,0);

    // Add the icon to the taskbar
	AddIcon();

	kh = new TCPKeyHook(this);
	kh->LicenceCode = "680BB1FB-1167-44E5-A37F-962568EAD023";
	kh->UserHookMsg = RegisterWindowMessage("Tilchi_Message");
	kh->OnKey = OnKeyPressed;
	kh->DisableKeyboard = false;
 	kh->Start_KeyHook();
}
//---------------------------------------------------------------------------
__fastcall TMainForm::~TMainForm()
{
	// Remove the icon from the tray, and delete
	// the TIcon pointer that we initially created.
    RemoveIcon();
	delete kh;
	delete TrayIcon;
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::WMTrayNotify(TMessage &Msg)
{
    // The LPARAM of the message identifies the type of mouse message.
    // When they right click, show the popup menu. When they double
    // click with the left mouse, show the form.
    switch(Msg.LParam)
    {
        case WM_RBUTTONUP:
            POINT WinPoint;           // find the mouse cursor
            GetCursorPos(&WinPoint);  // using api function, store
            SetForegroundWindow(Handle);
            PopupMenu1->Popup(WinPoint.x,WinPoint.y);
            PostMessage(Handle, WM_NULL, 0,0);
            break;
        case WM_LBUTTONDBLCLK:
            LaunchTilchi();
            break;
    }
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::AddIcon()
{
    // Use the Shell_NotifyIcon API function to
    // add the icon to the tray.
    NOTIFYICONDATA IconData;
    IconData.cbSize = sizeof(NOTIFYICONDATA);
    IconData.uID    = IDC_TRAY1;
    IconData.hWnd   = Handle;
    IconData.uFlags = NIF_MESSAGE|NIF_ICON|NIF_TIP;
    IconData.uCallbackMessage = WM_TRAYNOTIFY;
    lstrcpy(IconData.szTip, HINT_MESSAGE);
    IconData.hIcon  = TrayIcon->Handle;

    Shell_NotifyIcon(NIM_ADD,&IconData);
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::RemoveIcon()
{
    NOTIFYICONDATA IconData;
    IconData.cbSize = sizeof(NOTIFYICONDATA);
    IconData.uID    = IDC_TRAY1;
    IconData.hWnd   = Handle;
    IconData.hIcon  = TrayIcon->Handle;

    Shell_NotifyIcon(NIM_DELETE,&IconData);
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::LaunchTilchi()
{
	// Launchi Tilchi
	ShellExecute(Handle, "open", "Tilchi.exe", 0, 0, SW_SHOW);
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::LaunchMenuItemClick(TObject *Sender)
{
 	LaunchTilchi();
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::ExitMenuItemClick(TObject *Sender)
{
	Application->Terminate();
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::OnKeyPressed(System::TObject* Sender,
	const TKeyStates &AKeyStates, const TKeyNames &AKeyNames)
{
  TDataFile *Settings = new TDataFile("Tilchi.dat");

  // Ctrl+Shift+T HotKey
  if (AKeyStates.CtrlDown)
	  if ((AKeyStates.ShiftDown && !AKeyStates.AltDown))
		  if (AKeyStates.KeyDown && AnsiString(AKeyNames.KeyExtName) == "T")
				if (Settings->ReadBoolean("Settings","ShiftHotKey",true))
					LaunchTilchi();

  // Ctrl+Alt+T HotKey
  if (AKeyStates.CtrlDown)
	  if ((AKeyStates.AltDown && !AKeyStates.ShiftDown))
		  if (AKeyStates.KeyDown && AnsiString(AKeyNames.KeyExtName) == "T")
				if (Settings->ReadBoolean("Settings","AltHotKey",true))
					LaunchTilchi();
  
  delete Settings;
}
//---------------------------------------------------------------------------
