object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Incorex Tilchi 1.0'
  ClientHeight = 73
  ClientWidth = 137
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 8
    object LaunchMenuItem: TMenuItem
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' Tilchi'
      OnClick = LaunchMenuItemClick
    end
    object ExitMenuItem: TMenuItem
      Caption = #1047#1072#1074#1077#1088#1096#1080#1090#1100' '#1088#1072#1073#1086#1090#1091' Tilchi'
      OnClick = ExitMenuItemClick
    end
  end
end
