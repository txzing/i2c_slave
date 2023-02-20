VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmMain 
   Caption         =   "USB2ISP DEMO    WWW.USB-I2C-SPI.COM"
   ClientHeight    =   7230
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7515
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   7230
   ScaleWidth      =   7515
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton USBIO_NOTIFY_ROUTINE 
      Caption         =   "ģ�⴦���豸ͦ���ж��¼�"
      Enabled         =   0   'False
      Height          =   330
      Left            =   2535
      TabIndex        =   48
      Top             =   6660
      Visible         =   0   'False
      Width           =   3255
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   6915
      Left            =   105
      TabIndex        =   0
      Top             =   90
      Width           =   7305
      _ExtentX        =   12885
      _ExtentY        =   12197
      _Version        =   393216
      Tabs            =   6
      Tab             =   5
      TabsPerRow      =   6
      TabHeight       =   520
      MouseIcon       =   "frmMain.frx":030A
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "����"
         Size            =   9.75
         Charset         =   134
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      TabCaption(0)   =   "EPP����"
      TabPicture(0)   =   "frmMain.frx":0624
      Tab(0).ControlEnabled=   0   'False
      Tab(0).ControlCount=   0
      TabCaption(1)   =   "MEM����"
      TabPicture(1)   =   "frmMain.frx":0640
      Tab(1).ControlEnabled=   0   'False
      Tab(1).ControlCount=   0
      TabCaption(2)   =   "I2C�ӿ�"
      TabPicture(2)   =   "frmMain.frx":065C
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "Frame5"
      Tab(2).ControlCount=   1
      TabCaption(3)   =   "EEPROM��д"
      TabPicture(3)   =   "frmMain.frx":0678
      Tab(3).ControlEnabled=   0   'False
      Tab(3).Control(0)=   "Frame10"
      Tab(3).Control(1)=   "Frame9"
      Tab(3).Control(2)=   "Frame8"
      Tab(3).ControlCount=   3
      TabCaption(4)   =   "����I/O"
      TabPicture(4)   =   "frmMain.frx":0694
      Tab(4).ControlEnabled=   0   'False
      Tab(4).Control(0)=   "Frame11"
      Tab(4).ControlCount=   1
      TabCaption(5)   =   "SPI�ӿ�"
      TabPicture(5)   =   "frmMain.frx":06B0
      Tab(5).ControlEnabled=   -1  'True
      Tab(5).ControlCount=   0
      Begin VB.Frame Frame5 
         Caption         =   "����ģʽ��д����I2C������ͬ�����ڣ�API=USBIO_StreamI2C"
         Height          =   6435
         Left            =   -74835
         TabIndex        =   34
         Top             =   450
         Width           =   6975
         Begin VB.Frame Frame17 
            Caption         =   "����I2C/IIC���ߵĶ�д�ٶ�"
            Height          =   735
            Left            =   480
            TabIndex        =   49
            Top             =   5400
            Width           =   6135
            Begin VB.OptionButton I2CM 
               Caption         =   "750KHz"
               Height          =   255
               Index           =   3
               Left            =   4920
               TabIndex        =   53
               Top             =   360
               Width           =   975
            End
            Begin VB.OptionButton I2CM 
               Caption         =   "400KHz"
               Height          =   255
               Index           =   2
               Left            =   3480
               TabIndex        =   52
               Top             =   360
               Width           =   975
            End
            Begin VB.OptionButton I2CM 
               Caption         =   "100KHz"
               Height          =   255
               Index           =   1
               Left            =   2160
               TabIndex        =   51
               Top             =   360
               Value           =   -1  'True
               Width           =   975
            End
            Begin VB.OptionButton I2CM 
               Caption         =   "20KHz"
               Height          =   255
               Index           =   0
               Left            =   840
               TabIndex        =   50
               Top             =   360
               Width           =   855
            End
         End
         Begin VB.Frame Frame7 
            Caption         =   "д������"
            Height          =   2505
            Left            =   450
            TabIndex        =   41
            Top             =   240
            Width           =   6120
            Begin VB.CommandButton StreamICRW 
               Caption         =   "Write\Read"
               Height          =   375
               Left            =   4575
               TabIndex        =   47
               Top             =   330
               Width           =   1185
            End
            Begin VB.TextBox I2CWRBuf 
               Height          =   1530
               Left            =   1125
               MultiLine       =   -1  'True
               ScrollBars      =   2  'Vertical
               TabIndex        =   43
               Top             =   840
               Width           =   4695
            End
            Begin VB.TextBox I2CWRLen 
               BeginProperty DataFormat 
                  Type            =   0
                  Format          =   "0"
                  HaveTrueFalseNull=   0
                  FirstDayOfWeek  =   0
                  FirstWeekOfYear =   0
                  LCID            =   2052
                  SubFormatType   =   0
               EndProperty
               Height          =   375
               Left            =   1140
               TabIndex        =   42
               Top             =   330
               Width           =   2415
            End
            Begin VB.Label Label17 
               Caption         =   "����"
               Height          =   255
               Left            =   300
               TabIndex        =   46
               Top             =   840
               Width           =   615
            End
            Begin VB.Label Label24 
               Caption         =   "����"
               Height          =   255
               Left            =   300
               TabIndex        =   45
               Top             =   390
               Width           =   495
            End
            Begin VB.Label Label25 
               Caption         =   "(<400H)"
               Height          =   180
               Left            =   3630
               TabIndex        =   44
               Top             =   427
               Width           =   855
            End
         End
         Begin VB.Frame Frame6 
            Caption         =   "��ȡ����"
            Height          =   2505
            Left            =   480
            TabIndex        =   35
            Top             =   2760
            Width           =   6120
            Begin VB.TextBox I2CRDLen 
               BeginProperty DataFormat 
                  Type            =   0
                  Format          =   "0"
                  HaveTrueFalseNull=   0
                  FirstDayOfWeek  =   0
                  FirstWeekOfYear =   0
                  LCID            =   2052
                  SubFormatType   =   0
               EndProperty
               Height          =   375
               Left            =   1050
               TabIndex        =   37
               Top             =   315
               Width           =   2415
            End
            Begin VB.TextBox I2CRDBuf 
               Height          =   1530
               Left            =   1050
               MultiLine       =   -1  'True
               ScrollBars      =   2  'Vertical
               TabIndex        =   36
               Top             =   825
               Width           =   4695
            End
            Begin VB.Label Label26 
               Caption         =   "����"
               Height          =   255
               Left            =   330
               TabIndex        =   40
               Top             =   375
               Width           =   495
            End
            Begin VB.Label Label27 
               Caption         =   "����"
               Height          =   255
               Left            =   330
               TabIndex        =   39
               Top             =   825
               Width           =   615
            End
            Begin VB.Label Label30 
               Caption         =   "(<400H)"
               Height          =   180
               Left            =   3555
               TabIndex        =   38
               Top             =   412
               Width           =   855
            End
         End
      End
      Begin VB.Frame Frame11 
         Height          =   6015
         Left            =   -74925
         TabIndex        =   33
         Top             =   600
         Width           =   7140
      End
      Begin VB.Frame Frame8 
         Caption         =   "д�����ݣ�API=USBIO_WriteEEPROM"
         Height          =   3180
         Left            =   -73215
         TabIndex        =   24
         Top             =   420
         Width           =   5415
         Begin VB.TextBox WrDataLen 
            BeginProperty DataFormat 
               Type            =   0
               Format          =   "0"
               HaveTrueFalseNull=   0
               FirstDayOfWeek  =   0
               FirstWeekOfYear =   0
               LCID            =   2052
               SubFormatType   =   0
            EndProperty
            Height          =   375
            Left            =   345
            TabIndex        =   28
            Text            =   "0"
            Top             =   1305
            Width           =   2415
         End
         Begin VB.TextBox WrDataBuf 
            Height          =   1025
            Left            =   345
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   27
            Top             =   1995
            Width           =   4695
         End
         Begin VB.TextBox WrDataAddr 
            BeginProperty DataFormat 
               Type            =   0
               Format          =   "0"
               HaveTrueFalseNull=   0
               FirstDayOfWeek  =   0
               FirstWeekOfYear =   0
               LCID            =   2052
               SubFormatType   =   0
            EndProperty
            Height          =   375
            Left            =   330
            TabIndex        =   26
            Text            =   "0"
            Top             =   570
            Width           =   2415
         End
         Begin VB.CommandButton eepromWrDate 
            Caption         =   "Write"
            Height          =   375
            Left            =   4035
            TabIndex        =   25
            Top             =   1230
            Width           =   975
         End
         Begin VB.Label Label38 
            Caption         =   "д�볤��"
            Height          =   255
            Left            =   330
            TabIndex        =   32
            Top             =   1020
            Width           =   810
         End
         Begin VB.Label Label37 
            Caption         =   "(<400H)"
            Height          =   255
            Left            =   1125
            TabIndex        =   31
            Top             =   1020
            Width           =   765
         End
         Begin VB.Label Label36 
            Caption         =   "������ݣ�16���ƣ����ַ�һ�飩"
            Height          =   225
            Left            =   330
            TabIndex        =   30
            Top             =   1725
            Width           =   3075
         End
         Begin VB.Label Label33 
            Caption         =   "���ݵ�Ԫ��ʼ��ַ"
            Height          =   255
            Left            =   315
            TabIndex        =   29
            Top             =   270
            Width           =   1650
         End
      End
      Begin VB.Frame Frame9 
         Caption         =   "�������ݣ�API=USBIO_ReadEEPROM"
         Height          =   3180
         Left            =   -73230
         TabIndex        =   15
         Top             =   3645
         Width           =   5415
         Begin VB.CommandButton eepromRdDate 
            Caption         =   "Read"
            Height          =   375
            Left            =   4035
            TabIndex        =   19
            Top             =   1245
            Width           =   975
         End
         Begin VB.TextBox RdDataAddr 
            BeginProperty DataFormat 
               Type            =   0
               Format          =   "0"
               HaveTrueFalseNull=   0
               FirstDayOfWeek  =   0
               FirstWeekOfYear =   0
               LCID            =   2052
               SubFormatType   =   0
            EndProperty
            Height          =   375
            Left            =   315
            TabIndex        =   18
            Text            =   "0"
            Top             =   540
            Width           =   2415
         End
         Begin VB.TextBox RdDataBuf 
            Height          =   1025
            Left            =   315
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   17
            Top             =   1995
            Width           =   4695
         End
         Begin VB.TextBox RdDataLen 
            BeginProperty DataFormat 
               Type            =   0
               Format          =   "0"
               HaveTrueFalseNull=   0
               FirstDayOfWeek  =   0
               FirstWeekOfYear =   0
               LCID            =   2052
               SubFormatType   =   0
            EndProperty
            Height          =   375
            Left            =   315
            TabIndex        =   16
            Text            =   "0"
            Top             =   1305
            Width           =   2415
         End
         Begin VB.Label Label39 
            Caption         =   "���ݵ�Ԫ��ʼ��ַ"
            Height          =   255
            Left            =   315
            TabIndex        =   23
            Top             =   270
            Width           =   1650
         End
         Begin VB.Label Label35 
            Caption         =   "������ݣ�16���ƣ����ַ�һ�飩"
            Height          =   225
            Left            =   330
            TabIndex        =   22
            Top             =   1725
            Width           =   3075
         End
         Begin VB.Label Label34 
            Caption         =   "(<400H)"
            Height          =   255
            Left            =   1125
            TabIndex        =   21
            Top             =   1020
            Width           =   765
         End
         Begin VB.Label Label32 
            Caption         =   "��ȡ����"
            Height          =   255
            Left            =   330
            TabIndex        =   20
            Top             =   1020
            Width           =   795
         End
      End
      Begin VB.Frame Frame10 
         Caption         =   "EEPROM�ͺ�"
         Height          =   6405
         Left            =   -74895
         TabIndex        =   1
         Top             =   420
         Width           =   1620
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C4096"
            Height          =   255
            Index           =   12
            Left            =   180
            TabIndex        =   14
            Top             =   5190
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C2048"
            Height          =   255
            Index           =   11
            Left            =   180
            TabIndex        =   13
            Top             =   4777
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C1024"
            Height          =   255
            Index           =   10
            Left            =   180
            TabIndex        =   12
            Top             =   4370
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C512"
            Height          =   255
            Index           =   9
            Left            =   180
            TabIndex        =   11
            Top             =   3963
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C256"
            Height          =   255
            Index           =   8
            Left            =   180
            TabIndex        =   10
            Top             =   3556
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C128"
            Height          =   255
            Index           =   7
            Left            =   180
            TabIndex        =   9
            Top             =   3149
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C64"
            Height          =   255
            Index           =   6
            Left            =   180
            TabIndex        =   8
            Top             =   2742
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C32"
            Height          =   255
            Index           =   5
            Left            =   180
            TabIndex        =   7
            Top             =   2335
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C16"
            Height          =   255
            Index           =   4
            Left            =   180
            TabIndex        =   6
            Top             =   1928
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C08"
            Height          =   255
            Index           =   3
            Left            =   180
            TabIndex        =   5
            Top             =   1521
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C04"
            Height          =   255
            Index           =   2
            Left            =   180
            TabIndex        =   4
            Top             =   1114
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C02"
            Height          =   255
            Index           =   1
            Left            =   165
            TabIndex        =   3
            Top             =   707
            Width           =   1320
         End
         Begin VB.OptionButton eppromtype 
            Caption         =   "24C01"
            Height          =   255
            Index           =   0
            Left            =   180
            TabIndex        =   2
            Top             =   300
            Value           =   -1  'True
            Width           =   1320
         End
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim hopen As Long

Private Sub eepromRdDate_Click()
 Dim mDataAddr As Long
 Dim mLen As Long
 Dim buffer As arrRBuffer
 Dim bu() As Byte
 mLen = HexToBcd(RdDataLen)
 
 If (RdDataAddr.Text = "") Then
   MsgBox "���������ݵ�Ԫ��ʼ��ַ��", vbExclamation, "USB2I2C DEMO"
   Exit Sub
 End If
 If (mLen <= 0) Then
   MsgBox "�������ȡ���ȣ�", vbExclamation, "USB2I2C DEMO"
   Exit Sub
 End If
 mDataAddr = HexToBcd(RdDataAddr)
 If (mOpen = True) Then
    If (USBIO_ReadEEPROM(mIndex, eepromid, mDataAddr, mLen, buffer)) Then
      Dim buff As String
      Dim i As Long
      For i = 0 To mLen - 1
         buff = buff & Hex2bit(buffer.buf(i)) & " "
      Next i
      RdDataBuf.Text = buff
    Else
      MsgBox "��E2PROM����ʧ�ܣ�", vbExclamation, "USB2I2C DEMO"
    End If
    RdDataLen.Text = Hex(mLen)
 Else
    MsgBox "�豸δ�򿪣�", vbExclamation, "USB2I2C DEMO"
 End If
End Sub

Private Sub eepromWrDate_Click()
 Dim mData As Byte
 Dim mDataAddr As Long
 Dim mLen As Long
 Dim buffer As arrRBuffer
 
 mLen = HexToBcd(WrDataLen.Text)
  If (WrDataAddr.Text = "") Then
   MsgBox "���������ݵ�Ԫ��ʼ��ַ��", vbExclamation, "USB2I2C DEMO"
   Exit Sub
 End If
 If (mLen <= 0 Or WrDataBuf.Text = "") Then
   MsgBox "������Ҫд�������,���ȣ�", vbExclamation, "USB2I2C DEMO"
   Exit Sub
 End If
  
  If (mLen > (Len(WrDataBuf) \ 2)) Then '�����볤�Ⱥ����ݳ�����ȡСֵ
    mLen = Len(WrDataBuf) \ 2
  End If
  
  mDataAddr = HexToBcd(WrDataAddr.Text)
  Call mStrtoVal(WrDataBuf.Text, buffer, mLen)  '�������ʮ�����Ƹ�ʽ�ַ�����ת����ֵ����

  If (mOpen = True) Then
     If (USBIO_WriteEEPROM(mIndex, eepromid, mDataAddr, mLen, buffer) = False) Then
        MsgBox "��E2PROM����ʧ�ܣ�", vbExclamation, "USB2I2C DEMO"
     End If
     WrDataLen.Text = Hex(mLen)
  Else
    MsgBox "�豸δ�򿪣�", vbExclamation, "USB2I2C DEMO"
  End If
End Sub

Private Sub eppromtype_Click(Index As Integer)
Select Case Index
      Case 0
         eepromid = ID_24C01
      Case 1
         eepromid = ID_24C02
      Case 2
         eepromid = ID_24C04
      Case 3
         eepromid = ID_24C08
      Case 4
         eepromid = ID_24C16
      Case 5
         eepromid = ID_24C32
      Case 6
         eepromid = ID_24C64
      Case 7
         eepromid = ID_24C128
      Case 8
         eepromid = ID_24C256
      Case 9
         eepromid = ID_24C512
      Case 10
         eepromid = ID_24C1024
      Case 11
         eepromid = ID_24C2048
      Case 12
         eepromid = ID_24C4096
  End Select
End Sub


Private Sub Form_Load()
mIndex = 0
    SSTab1.TabVisible(0) = False
    SSTab1.TabVisible(1) = False
    'SSTab1.TabVisible(2) = False
    'SSTab1.TabVisible(3) = False
    SSTab1.TabVisible(4) = False
    SSTab1.TabVisible(5) = False
    
hopen = USBIO_OpenDevice(mIndex)
If (hopen = INVALID_HANDLE_VALUE) Then
    mOpen = False
Else
    mOpen = True
End If
'�����豸���֪ͨ
If USBIO_SetDeviceNotify(mIndex, vbNullString, AddressOf mUSBIO_NOTIFY_ROUTINE) = False Then
    MsgBox "�����豸���֪ͨʧ��", vbExclamation, "USB2I2C DEMO"
End If
enablebtn (mOpen)
End Sub

Private Sub Form_Unload(Cancel As Integer)
USBIO_SetDeviceNotify mIndex, vbNullString, 0&
If (mOpen = True) Then
    USBIO_CloseDevice (mIndex)

End If
End Sub


Private Sub Label43_Click()

End Sub

'Private Sub SSTab1_Click(PreviousTab As Integer)

'If (mOpen = True) And (SSTab1.Tab = 4) Then
'   Call evtbtrefresh_Click
'   Call Led_Click(0)
'End If

'End Sub

Private Sub StreamICRW_Click()
Dim mWRLen As Long
Dim mRdLen As Long
Dim iBuff As arrRBuffer
Dim buffer As arrRBuffer

mWRLen = HexToBcd(I2CWRLen.Text)
mRdLen = HexToBcd(I2CRDLen.Text)

'----------------------------------------
If (I2CM(0).Value = True) Then
    If (USBIO_SetStream(mIndex, &H80) = False) Then
       MsgBox "����I2Cʱ�� = 20KHzʧ�ܣ� ", vbExclamation, "USB2I2C DEMO"
       Exit Sub
    End If
ElseIf (I2CM(1).Value = True) Then
    If (USBIO_SetStream(mIndex, &H81) = False) Then
       MsgBox "����I2Cʱ�� = 100KHzʧ�ܣ� ", vbExclamation, "USB2I2C DEMO"
       Exit Sub
    End If
ElseIf (I2CM(2).Value = True) Then
    If (USBIO_SetStream(mIndex, &H82) = False) Then
       MsgBox "����I2Cʱ�� = 400KHzʧ�ܣ� ", vbExclamation, "USB2I2C DEMO"
       Exit Sub
    End If
ElseIf (I2CM(3).Value = True) Then
    If (USBIO_SetStream(mIndex, &H83) = False) Then
       MsgBox "����I2Cʱ�� = 750KHzʧ�ܣ� ", vbExclamation, "USB2I2C DEMO"
       Exit Sub
    End If
End If
'----------------------------------------

If (mWRLen > 0 And I2CWRBuf.Text = "") Then
  MsgBox "������Ҫд������,���ȣ�", vbExclamation, "USB2I2C DEMO"
  Exit Sub
End If
If ((mWRLen = 0) And (mRdLen = 0)) Then
  MsgBox "���������������ĳ��ȣ�", vbExclamation, "USB2I2C DEMO"
  Exit Sub
End If
If (mWRLen > Len(Trim(I2CWRBuf.Text)) \ 2) Then
   mWRLen = Len(Trim(I2CWRBuf.Text)) \ 2
End If

Call mStrtoVal(I2CWRBuf.Text, buffer, mWRLen)       '�������ʮ�����Ƹ�ʽ�ַ�����ת����ֵ����

If (mOpen = True) Then
  If (USBIO_StreamI2C(mIndex, mWRLen, buffer, mRdLen, iBuff) = False) Then
     MsgBox "I2C��ģʽ��д����ʧ�ܣ�", vbExclamation, "USB2I2C DEMO"
  Else
    If (mRdLen > 0) Then   '�����ݷ���
       Dim buff As String
       Dim i As Long
       For i = 0 To mRdLen - 1
         buff = buff & Hex2bit(iBuff.buf(i)) + " "
       Next
       I2CRDBuf.Text = buff
    End If
  End If
  I2CWRLen.Text = Hex(mWRLen)
  I2CRDLen.Text = Hex(mRdLen)
Else
  MsgBox "�豸δ�򿪣�", vbExclamation, "USB2I2C DEMO"
End If
End Sub


Private Sub USBIO_NOTIFY_ROUTINE_KeyUp(KeyCode As Integer, Shift As Integer)  '�豸���֪ͨ�������
    Dim iEventStatus As Long
    iEventStatus = KeyCode '����¼�
    If (iEventStatus = USBIO_DEVICE_ARRIVAL) Then ' �豸�����¼�,�Ѿ�����
        If (USBIO_OpenDevice(mIndex) = INVALID_HANDLE_VALUE) Then
            MsgBox "���豸ʧ��!", vbOK, "USB2I2C DEMO"
            mOpen = False
        Else
            mOpen = True  '�򿪳ɹ�
        End If
    ElseIf (iEventStatus = USBIO_DEVICE_REMOVE) Then ' �豸�γ��¼�,�Ѿ��γ�
        USBIO_CloseDevice (mIndex)
        mOpen = False
    End If
    enablebtn (mOpen) '�豸��,��ť����,�豸û��,��ť����
End Sub

Public Sub enablebtn(ByVal bEnable As Boolean)  'bEnable=true :�����尴ť���� ;=false:enable:�����尴ť����
  With frmMain
  
    '.eppRead0.Enabled = bEnable
    '.eppWrite0.Enabled = bEnable
    '.eppRead1.Enabled = bEnable
    '.eppWrite1.Enabled = bEnable
    
    '.memRead0.Enabled = bEnable
    '.memWrite0.Enabled = bEnable
    '.memRead1.Enabled = bEnable
   ' .memWrite1.Enabled = bEnable
    
    .StreamICRW.Enabled = bEnable
    
    '.StreamSPIRW.Enabled = bEnable
    
    .eepromRdDate.Enabled = bEnable
    .eepromWrDate.Enabled = bEnable
    
    '.evtbtrefresh.Enabled = bEnable
    '.Led(0).Enabled = bEnable
    '.Led(1).Enabled = bEnable
    '.Led(2).Enabled = bEnable
    '.Led(3).Enabled = bEnable
    '.Led(4).Enabled = bEnable
    '.Led(5).Enabled = bEnable
    '.Led(6).Enabled = bEnable
    '.Led(7).Enabled = bEnable
    
    If (bEnable = True) Then '���������ʾ
        frmMain.Caption = "USB2I2C **�豸�Ѳ���"

    Else
        frmMain.Caption = "USB2I2C **�豸�Ѱγ�"

    End If
  End With
    
   
End Sub
