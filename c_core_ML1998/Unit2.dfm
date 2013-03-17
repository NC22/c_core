object Form2: TForm2
  Left = 199
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 139
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = init
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 73
    Height = 17
    AutoSize = False
    Caption = 'Java:'
    Color = 13290186
    ParentColor = False
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 73
    Height = 17
    AutoSize = False
    Caption = #1055#1072#1087#1082#1072' '#1080#1075#1088#1099':'
    Color = 13290186
    ParentColor = False
  end
  object Label3: TLabel
    Left = 88
    Top = 16
    Width = 337
    Height = 17
    AutoSize = False
    Caption = 'Label1'
    Color = 13290186
    ParentColor = False
  end
  object Label4: TLabel
    Left = 88
    Top = 48
    Width = 337
    Height = 17
    AutoSize = False
    Caption = 'Label2'
    Color = 13290186
    ParentColor = False
  end
  object Label5: TLabel
    Left = 8
    Top = 80
    Width = 417
    Height = 17
    AutoSize = False
    Caption = #1042#1099#1076#1077#1083#1077#1085#1080#1077' '#1087#1072#1084#1103#1090#1080':'
    Color = 13290186
    ParentColor = False
  end
  object Label6: TLabel
    Left = 8
    Top = 112
    Width = 89
    Height = 17
    AutoSize = False
    Caption = #1052#1080#1085#1080#1084#1091#1084':'
    Color = 13290186
    ParentColor = False
  end
  object Label7: TLabel
    Left = 216
    Top = 112
    Width = 97
    Height = 17
    AutoSize = False
    Caption = #1052#1072#1082#1089#1080#1084#1091#1084':'
    Color = 13290186
    ParentColor = False
  end
  object Button1: TButton
    Left = 448
    Top = 10
    Width = 75
    Height = 25
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 448
    Top = 42
    Width = 75
    Height = 25
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ComboBox1: TComboBox
    Left = 104
    Top = 110
    Width = 105
    Height = 21
    Style = csDropDownList
    BiDiMode = bdRightToLeftReadingOnly
    ItemHeight = 13
    ParentBiDiMode = False
    TabOrder = 2
    OnChange = minSet
    Items.Strings = (
      '128 mb'
      '512 mb'
      '1 gb'
      '2 gb'
      '4 gb')
  end
  object ComboBox2: TComboBox
    Left = 320
    Top = 110
    Width = 105
    Height = 21
    Style = csDropDownList
    BiDiMode = bdRightToLeftReadingOnly
    ItemHeight = 13
    ParentBiDiMode = False
    TabOrder = 3
    OnChange = maxSet
    Items.Strings = (
      '128 mb'
      '512 mb'
      '1 gb'
      '2 gb'
      '4 gb')
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Java Console|java.exe|Java window|javaw.exe'
    Left = 48
    Top = 8
  end
end
