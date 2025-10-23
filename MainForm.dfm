object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Delphi KeyScan Logger - Windows 10/11'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object memoLog: TMemo
    Left = 0
    Top = 41
    Width = 900
    Height = 540
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    TabOrder = 1
    object btnStart: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1057#1090#1072#1088#1090
      TabOrder = 0
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #1057#1090#1086#1087
      Enabled = False
      TabOrder = 1
      OnClick = btnStopClick
    end
    object btnClear: TButton
      Left = 170
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 2
      OnClick = btnClearClick
    end
    object chkLogToFile: TCheckBox
      Left = 251
      Top = 12
      Width = 150
      Height = 17
      Caption = #1047#1072#1087#1080#1089#1099#1074#1072#1090#1100' '#1074' '#1092#1072#1081#1083
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 581
    Width = 900
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 432
    Top = 280
  end
end
