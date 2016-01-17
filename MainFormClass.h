//$$---- Form HDR ----
//---------------------------------------------------------------------------
#ifndef MainFormClassH
#define MainFormClassH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Menus.hpp>
#include "CPKeyHook.hpp"
//---------------------------------------------------------------------------
#define WM_TRAYNOTIFY  (WM_USER + 1001)

class TMainForm : public TForm
{
__published:	// IDE-managed Components
	TPopupMenu *PopupMenu1;
	TMenuItem *ExitMenuItem;
	TMenuItem *LaunchMenuItem;
	void __fastcall LaunchMenuItemClick(TObject *Sender);
	void __fastcall ExitMenuItemClick(TObject *Sender);
private:	// User declarations
	TCPKeyHook *kh;
	Graphics::TIcon *TrayIcon;
	void __fastcall WMTrayNotify(TMessage &Msg);
	void __fastcall RemoveIcon();
	void __fastcall AddIcon();
	void __fastcall LaunchTilchi();
	void __fastcall OnKeyPressed(System::TObject* Sender,
	const TKeyStates &AKeyStates, const TKeyNames &AKeyNames);
public:		// User declarations
	__fastcall TMainForm(TComponent* Owner);
	__fastcall ~TMainForm();

BEGIN_MESSAGE_MAP
    MESSAGE_HANDLER(WM_TRAYNOTIFY,TMessage,WMTrayNotify)
END_MESSAGE_MAP(TForm)

};
//---------------------------------------------------------------------------
extern PACKAGE TMainForm *MainForm;
//---------------------------------------------------------------------------
#endif
