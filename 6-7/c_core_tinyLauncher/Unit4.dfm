object Form4: TForm4
  Left = 617
  Top = 492
  AutoScroll = False
  BorderIcons = []
  Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
  ClientHeight = 102
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = RefVersion
  PixelsPerInch = 96
  TextHeight = 13
  object Register: TbsSkinLinkLabel
    Left = 16
    Top = 64
    Width = 137
    Height = 17
    Cursor = crHandPoint
    GlowEffect = False
    GlowSize = 7
    UseUnderLine = True
    UseSkinFont = True
    DefaultActiveFontColor = clBlue
    DefaultFont.Charset = DEFAULT_CHARSET
    DefaultFont.Color = clWindowText
    DefaultFont.Height = 14
    DefaultFont.Name = 'Arial'
    DefaultFont.Style = [fsUnderline]
    SkinData = Form1.bsSkinData1
    SkinDataName = 'stdlabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = [fsUnderline]
    Caption = 'Author'#39's Official Web Site'
    ParentFont = False
    OnClick = RegisterClick
  end
  object bsSkinButton1: TbsSkinButton
    Left = 184
    Top = 64
    Width = 75
    Height = 25
    HintImageIndex = 0
    TabOrder = 0
    SkinData = Form1.bsSkinData1
    SkinDataName = 'button'
    DefaultFont.Charset = DEFAULT_CHARSET
    DefaultFont.Color = clWindowText
    DefaultFont.Height = 14
    DefaultFont.Name = 'Arial'
    DefaultFont.Style = []
    DefaultWidth = 0
    DefaultHeight = 0
    UseSkinFont = True
    CheckedMode = False
    ImageIndex = -1
    AlwaysShowLayeredFrame = False
    UseSkinSize = True
    UseSkinFontColor = True
    RepeatMode = False
    RepeatInterval = 100
    AllowAllUp = False
    TabStop = True
    CanFocused = True
    Down = False
    GroupIndex = 0
    Caption = #1047#1072#1082#1088#1099#1090#1100
    NumGlyphs = 1
    Spacing = 1
    OnClick = bsSkinButton1Click
  end
  object ProgName: TbsSkinLabel
    Left = 8
    Top = 8
    Width = 121
    Height = 21
    HintImageIndex = 0
    TabOrder = 1
    SkinData = Form1.bsSkinData1
    SkinDataName = 'label'
    DefaultFont.Charset = DEFAULT_CHARSET
    DefaultFont.Color = clWindowText
    DefaultFont.Height = 14
    DefaultFont.Name = 'Arial'
    DefaultFont.Style = []
    DefaultWidth = 0
    DefaultHeight = 0
    UseSkinFont = True
    ShadowEffect = False
    ShadowColor = clBlack
    ShadowOffset = 0
    ShadowSize = 3
    ReflectionEffect = False
    ReflectionOffset = -5
    EllipsType = bsetNoneEllips
    UseSkinSize = True
    UseSkinFontColor = True
    BorderStyle = bvFrame
    AutoSize = False
  end
  object Version: TbsSkinLabel
    Left = 136
    Top = 8
    Width = 121
    Height = 21
    HintImageIndex = 0
    TabOrder = 2
    SkinData = Form1.bsSkinData1
    SkinDataName = 'label'
    DefaultFont.Charset = DEFAULT_CHARSET
    DefaultFont.Color = clWindowText
    DefaultFont.Height = 14
    DefaultFont.Name = 'Arial'
    DefaultFont.Style = []
    DefaultWidth = 0
    DefaultHeight = 0
    UseSkinFont = True
    ShadowEffect = False
    ShadowColor = clBlack
    ShadowOffset = 0
    ShadowSize = 3
    ReflectionEffect = False
    ReflectionOffset = -5
    EllipsType = bsetNoneEllips
    UseSkinSize = True
    UseSkinFontColor = True
    BorderStyle = bvFrame
    AutoSize = False
  end
  object bsSkinLabel1: TbsSkinLabel
    Left = 8
    Top = 40
    Width = 249
    Height = 21
    HintImageIndex = 0
    TabOrder = 3
    SkinData = Form1.bsSkinData1
    SkinDataName = 'label'
    DefaultFont.Charset = DEFAULT_CHARSET
    DefaultFont.Color = clWindowText
    DefaultFont.Height = 14
    DefaultFont.Name = 'Arial'
    DefaultFont.Style = []
    DefaultWidth = 0
    DefaultHeight = 0
    UseSkinFont = True
    ShadowEffect = False
    ShadowColor = clBlack
    ShadowOffset = 0
    ShadowSize = 3
    ReflectionEffect = False
    ReflectionOffset = -5
    EllipsType = bsetNoneEllips
    UseSkinSize = True
    UseSkinFontColor = True
    BorderStyle = bvFrame
    Caption = #169' NC22 , 2012 Mozilla Public License'
    AutoSize = False
  end
  object bsBusinessSkinForm1: TbsBusinessSkinForm
    WindowState = wsNormal
    QuickButtons = <>
    QuickButtonsShowHint = False
    QuickButtonsShowDivider = True
    ClientInActiveEffect = False
    ClientInActiveEffectType = bsieSemiTransparent
    DisableSystemMenu = False
    AlwaysResize = False
    PositionInMonitor = bspDefault
    UseFormCursorInNCArea = False
    MaxMenuItemsInWindow = 0
    ClientWidth = 0
    ClientHeight = 0
    HideCaptionButtons = False
    AlwaysShowInTray = False
    LogoBitMapTransparent = False
    AlwaysMinimizeToTray = False
    UseSkinFontInMenu = True
    ShowIcon = False
    MaximizeOnFullScreen = False
    AlphaBlend = False
    AlphaBlendAnimation = False
    AlphaBlendValue = 200
    ShowObjectHint = False
    MenusAlphaBlend = False
    MenusAlphaBlendAnimation = False
    MenusAlphaBlendValue = 200
    DefCaptionFont.Charset = DEFAULT_CHARSET
    DefCaptionFont.Color = clBtnText
    DefCaptionFont.Height = 14
    DefCaptionFont.Name = 'Arial'
    DefCaptionFont.Style = [fsBold]
    DefInActiveCaptionFont.Charset = DEFAULT_CHARSET
    DefInActiveCaptionFont.Color = clBtnShadow
    DefInActiveCaptionFont.Height = 14
    DefInActiveCaptionFont.Name = 'Arial'
    DefInActiveCaptionFont.Style = [fsBold]
    DefMenuItemHeight = 20
    DefMenuItemFont.Charset = DEFAULT_CHARSET
    DefMenuItemFont.Color = clWindowText
    DefMenuItemFont.Height = 14
    DefMenuItemFont.Name = 'Arial'
    DefMenuItemFont.Style = []
    UseDefaultSysMenu = True
    SkinData = Form1.bsSkinData1
    MinHeight = 0
    MinWidth = 0
    MaxHeight = 0
    MaxWidth = 0
    Magnetic = False
    MagneticSize = 5
    BorderIcons = [biRollUp]
    Left = 144
    Top = 64
  end
end