Attribute VB_Name = "Module1"
Option Explicit

Type arrRBuffer
    buf(mMAX_BUFFER_LENGTH - 1) As Byte
End Type

Public Const WM_KEYUP = &H101
Public Const BN_CLICK = &H101
Public eepromid As EEPROM_TYPE  'eeprom型号
Public Declare Function PostMessage Lib "user32" Alias "PostMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

Public mIndex  As Long
Public mOpen As Boolean


Public Function mCharToBcd(ByVal iChar As String) As Byte ' 输入的ASCII字符
    Dim mBCD As Byte
    If iChar >= "0" And iChar <= "9" Then
        mBCD = iChar - "0"
    ElseIf iChar >= "A" And iChar <= "F" Then
        mBCD = Asc(iChar) - Asc("A") + &HA
    ElseIf iChar >= "a" And iChar <= "f" Then
        mBCD = Asc(iChar) - Asc("a") + &HA
    Else
        mBCD = &HFF
    End If
    mCharToBcd = mBCD
End Function

Sub mStrtoVal(str As String, ByRef strOut As arrRBuffer, strleng As Long)
   Dim i, j As Long
   Dim mLen As Long
   Dim strRev(mMAX_BUFFER_LENGTH - 1) As Byte
   mLen = strleng * 2
   j = 0
   For i = 0 To mLen - 1 Step 2
       If (mCharToBcd(Mid(str, i + 1, 1)) = &HFF Or mCharToBcd(Mid(str, i + 2, 1)) = &HFF) Then
            GoTo con
        End If
    '   strRev(j) = mCharToBcd(Mid(str, i + 1, 1)) * 16 + mCharToBcd(Mid(str, i + 2, 1))
       strRev(j) = mCharToBcd(Mid(str, i + 1, 1)) * 16 + mCharToBcd(Mid(str, i + 2, 1))
       Debug.Print Hex(strRev(j))
       j = j + 1
con:   Next
   j = 0
   While (j < strleng)
       strOut.buf(j) = strRev(j)
       j = j + 1
    Wend
End Sub

Function Hex2bit(var As Byte) As String
If var < 16 Then
   Hex2bit = "0" & Hex(var)
 Else
   Hex2bit = Hex(var)
End If
End Function
Function HexToBcd(str As String) As Long                 '将文本框中输入的十六进制值转换成BCD码
Dim Length As Integer
Dim X As String
Dim i As Long
str = Trim(str)
Length = Len(str)
For i = 0 To Length - 1
X = Mid(str, Length - i, 1)
Select Case X
       Case "a", "A"
         HexToBcd = HexToBcd + 10 * (16 ^ i)
       Case "b", "B"
         HexToBcd = HexToBcd + 11 * (16 ^ i)
       Case "c", "C"
         HexToBcd = HexToBcd + 12 * (16 ^ i)
       Case "d", "D"
         HexToBcd = HexToBcd + 13 * (16 ^ i)
       Case "e", "E"
         HexToBcd = HexToBcd + 14 * (16 ^ i)
       Case "f", "F"
         HexToBcd = HexToBcd + 15 * (16 ^ i)
       Case "0" To "9"
         HexToBcd = HexToBcd + Val(X) * 16 ^ i
       Case Else
       'MsgBox "非十六进制数", vbCritical, "信息提示"
       HexToBcd = 0
End Select
Next i
End Function
Public Sub mUSBIO_NOTIFY_ROUTINE(ByVal iEventStatus As Long)
   PostMessage frmMain.USBIO_NOTIFY_ROUTINE.hwnd, WM_KEYUP, iEventStatus, 0  '将接收到的插拔事件值发到插拔处理程序中
End Sub




