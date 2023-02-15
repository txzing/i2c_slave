Attribute VB_Name = "USBIOXDLL"
Option Explicit
' 2004.05.28, 2004.10.20, 2005.01.08, 2005.03.25, 2005.04.28
'****************************************
'**  Copyright  (C)  W.ch  1999-2005   **
'**  Web:  http://www.USB-I2C-SPI.com  **
'****************************************
'**  DLL for USB interface chip USB2I2C**
'**  C, VC6.0                          **
'****************************************
'
Public Enum EEPROM_TYPE   ' EEPROM�ͺŶ���
  ID_24C01 = 0
  ID_24C02 = 1
  ID_24C04 = 2
  ID_24C08 = 3
  ID_24C16 = 4
  ID_24C32 = 5
  ID_24C64 = 6
  ID_24C128 = 7
  ID_24C256 = 8
  ID_24C512 = 9
  ID_24C1024 = 10
  ID_24C2048 = 11
  ID_24C4096 = 12
End Enum

Type mUspValue
        mUspValueLow As Byte                  ' 02H ֵ�������ֽ�
        mUspValueHigh As Byte                 ' 03H ֵ�������ֽ�
End Type
Type mUspIndex
        mUspIndexLow As Byte                  ' 04H �����������ֽ�
        mUspIndexHigh  As Byte                ' 05H �����������ֽ�
End Type
Type USB_SETUP_PKT                            ' USB���ƴ���Ľ����׶ε�����������ṹ
    mUspReqType As Byte                       ' 00H ��������
    mUspRequest As Byte                       ' 01H �������
    mUspValue As mUspValue                    ' 02H-03H ֵ����
    mUspIndex As mUspIndex                    ' 04H-05H ��������
    mLength As Integer                        ' 06H-07H ���ݽ׶ε����ݳ���
End Type

Public Const INVALID_HANDLE_VALUE = -1        '������
Public Const mUSBIO_PACKET_LENGTH = 32           ' USB2I2C֧�ֵ����ݰ��ĳ���
Public Const mUSBIO_PKT_LEN_SHORT = 8               ' USB2I2C֧�ֵĶ����ݰ��ĳ���

Type WIN32_COMMAND                              '����WIN32����ӿڽṹ
   mFunction As Long                            '����ʱָ�����ܴ�����߹ܵ���
                                                '���ʱ���ز���״̬
   mLength As Long                              '��ȡ����,���غ������ݵĳ���
   mBuffer(mUSBIO_PACKET_LENGTH - 1) As Byte    '���ݻ�����,����Ϊ0��255B
End Type
Public mWIN32_COMMAND As WIN32_COMMAND

Public Const FILE_DEVICE_UNKNOWN = &H22
Public Const FILE_ANY_ACCESS = 0
Public Const METHOD_BUFFERED = 0
' WIN32Ӧ�ò�ӿ�����
Public Const IOCTL_USBIO_COMMAND = (FILE_DEVICE_UNKNOWN * (2 ^ 16) + FILE_ANY_ACCESS * 2 ^ 14 + &HF34 * 2 ^ 2 + METHOD_BUFFERED)     ' ר�ýӿ�

Const mWIN32_COMMAND_HEAD = 8         ' WIN32����ӿڵ�ͷ����

Public Const mUSBIO_MAX_NUMBER = 16              ' ���ͬʱ���ӵ�USB2I2C��

Public Const mMAX_BUFFER_LENGTH = &H1000              ' ���ݻ�������󳤶�4096

Public Const mMAX_COMMAND_LENGTH = (mWIN32_COMMAND_HEAD + mMAX_BUFFER_LENGTH)             ' ������ݳ��ȼ�������ṹͷ�ĳ���

Public Const mDEFAULT_BUFFER_LEN = &H400              ' ���ݻ�����Ĭ�ϳ���1024

Public Const mDEFAULT_COMMAND_LEN = (mWIN32_COMMAND_HEAD + mDEFAULT_BUFFER_LEN)       ' Ĭ�����ݳ��ȼ�������ṹͷ�ĳ���


' USB2I2C�˵��ַ
Public Const mUSBIO_ENDP_INTER_UP = &H81              ' USB2I2C���ж������ϴ��˵�ĵ�ַ
Public Const mUSBIO_ENDP_INTER_DOWN = &H1             ' USB2I2C���ж������´��˵�ĵ�ַ
Public Const mUSBIO_ENDP_DATA_UP = &H82              ' USB2I2C�����ݿ��ϴ��˵�ĵ�ַ
Public Const mUSBIO_ENDP_DATA_DOWN = &H2            ' USB2I2C�����ݿ��´��˵�ĵ�ַ

' �豸��ӿ��ṩ�Ĺܵ���������
Public Const mPipeDeviceCtrl = &H4                  ' USB2I2C���ۺϿ��ƹܵ�
Public Const mPipeInterUp = &H5                       ' USB2I2C���ж������ϴ��ܵ�
Public Const mPipeDataUp = &H6                         ' USB2I2C�����ݿ��ϴ��ܵ�
Public Const mPipeDataDown = &H7                     ' USB2I2C�����ݿ��´��ܵ�

' Ӧ�ò�ӿڵĹ��ܴ���
Public Const mFuncNoOperation = &H0                  ' �޲���
Public Const mFuncGetVersion = &H1                    ' ��ȡ��������汾��
Public Const mFuncGetConfig = &H2                   ' ��ȡUSB�豸����������
Public Const mFuncSetTimeout = &H9                    ' ����USBͨѶ��ʱ
Public Const mFuncSetExclusive = &HB                  ' ���ö�ռʹ��
Public Const mFuncResetDevice = &HC                  ' ��λUSB�豸
Public Const mFuncResetPipe = &HD                     ' ��λUSB�ܵ�
Public Const mFuncAbortPipe = &HE                      ' ȡ��USB�ܵ�����������

' USB2I2C����ר�õĹ��ܴ���
Public Const mFuncSetParaMode = &HF                   ' ���ò���ģʽ
Public Const mFuncReadData0 = &H10                   ' �Ӳ��ڶ�ȡ���ݿ�0
Public Const mFuncReadData1 = &H11                   ' �Ӳ��ڶ�ȡ���ݿ�1
Public Const mFuncWriteData0 = &H12                  ' �򲢿�д�����ݿ�0
Public Const mFuncWriteData1 = &H13                  ' �򲢿�д�����ݿ�1
Public Const mFuncWriteRead = &H14                    ' �����������


' USB�豸��׼�������
Public Const mUSB_CLR_FEATURE = &H1
Public Const mUSB_SET_FEATURE = &H3
Public Const mUSB_GET_STATUS = &H0
Public Const mUSB_SET_ADDRESS = &H5
Public Const mUSB_GET_DESCR = &H6
Public Const mUSB_SET_DESCR = &H7
Public Const mUSB_GET_CONFIG = &H8
Public Const mUSB_SET_CONFIG = &H9
Public Const mUSB_GET_INTERF = &HA
Public Const mUSB_SET_INTERF = &HB
Public Const mUSB_SYNC_FRAME = &HC

' USB2I2C���ƴ���ĳ���ר����������
Public Const mUSBIO_VENDOR_READ = &HC0                ' ͨ�����ƴ���ʵ�ֵ�USB2I2C����ר�ö�����
Public Const mUSBIO_VENDOR_WRITE = &H40             ' ͨ�����ƴ���ʵ�ֵ�USB2I2C����ר��д����

' USB2I2C���ƴ���ĳ���ר���������
Public Const mUSBIO_PARA_INIT = &HB1                 ' ��ʼ������
Public Const mUSBIO_I2C_STATUS = &H52                ' ��ȡI2C�ӿڵ�״̬
Public Const mUSBIO_I2C_COMMAND = &H53               ' ����I2C�ӿڵ�����


Public Const mUSBIOA_CMD_I2C_STM_STA = &H74          ' I2C�ӿڵ�������:������ʼλ
Public Const mUSBIOA_CMD_I2C_STM_STO = &H75           ' I2C�ӿڵ�������:����ֹͣλ
Public Const mUSBIOA_CMD_I2C_STM_OUT = &H0           'I2C�ӿڵ�������:�������,λ5-λ0Ϊ����,�����ֽ�Ϊ����,0������ֻ����һ���ֽڲ�����Ӧ��
Public Const mUSBIOA_CMD_I2C_STM_IN = &HC0           ' I2C�ӿڵ�������:��������,λ5-λ0Ϊ����,0������ֻ����һ���ֽڲ�������Ӧ��
Public Const mUSBIOA_CMD_I2C_STM_SET = &H60           ' I2C�ӿڵ�������:���ò���,λ2=SPI��I/O��(0=���뵥��,1=˫��˫��),λ1λ0=I2C�ٶ�(00=����,01=��׼,10=����,11=����)
Public Const mUSBIOA_CMD_I2C_STM_US = &H40           ' I2C�ӿڵ�������:��΢��Ϊ��λ��ʱ,λ3-λ0Ϊ��ʱֵ
Public Const mUSBIOA_CMD_I2C_STM_MS = &H50           ' I2C�ӿڵ�������:������Ϊ��λ��ʱ,λ3-λ0Ϊ��ʱֵ
Public Const mUSBIOA_CMD_I2C_STM_DLY = &HF           ' I2C�ӿڵ�����������������ʱ�����ֵ
Public Const mUSBIOA_CMD_I2C_STM_END = &H0            ' I2C�ӿڵ�������:�������ǰ����


' ֱ�������״̬�źŵ�λ����
Public Const mStateBitERR = &H100                     ' ֻ��,ERR#��������״̬,1:�ߵ�ƽ,0:�͵�ƽ
Public Const mStateBitPEMP = &H200                   ' ֻ��,PEMP��������״̬,1:�ߵ�ƽ,0:�͵�ƽ
Public Const mStateBitINT = &H400                     ' ֻ��,INT#��������״̬,1:�ߵ�ƽ,0:�͵�ƽ
Public Const mStateBitSLCT = &H800                  ' ֻ��,SLCT��������״̬,1:�ߵ�ƽ,0:�͵�ƽ
Public Const mStateBitSDA = &H800000              ' ֻ��,SDA��������״̬,1:�ߵ�ƽ,0:�͵�ƽ




Declare Function USBIO_OpenDevice Lib "USBIOX.DLL" (ByVal iIndex As Long) As Long
' ��USB2I2C�豸,���ؾ��,��������Ч
' iIndex  ָ��USB2I2C�豸���,0��Ӧ��һ���豸

Declare Sub USBIO_CloseDevice Lib "USBIOX.DLL" (ByVal iIndex As Long)
' �ر�USB2I2C�豸
' iIndex    ָ��USB2I2C�豸���

Declare Function USBIO_GetVersion Lib "USBIOX.DLL" () As Long

' ���DLL�汾��,���ذ汾��

Declare Function USBIO_DriverCommand Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef ioCommand As WIN32_COMMAND) As Long
' ֱ�Ӵ����������������,�����򷵻�0,���򷵻����ݳ���
' iIndex,  ' ָ��USB2I2C�豸���,V1.6����DLLҲ�������豸�򿪺�ľ��
' ioCommand   ����ṹ�ĵ�ַ
' �ó����ڵ��ú󷵻����ݳ���,������Ȼ��������ṹ,����Ƕ�����,�����ݷ���������ṹ��,
' ���ص����ݳ����ڲ���ʧ��ʱΪ0,�����ɹ�ʱΪ��������ṹ�ĳ���,�����һ���ֽ�,�򷵻�mWIN32_COMMAND_HEAD+1,
' ����ṹ�ڵ���ǰ,�ֱ��ṩ:�ܵ��Ż�������ܴ���,��ȡ���ݵĳ���(��ѡ),����(��ѡ)
' ����ṹ�ڵ��ú�,�ֱ𷵻�:����״̬����,�������ݵĳ���(��ѡ),
'   ����״̬��������WINDOWS����Ĵ���,���Բο�NTSTATUS.H,
'   �������ݵĳ�����ָ���������ص����ݳ���,���ݴ�������Ļ�������,����д����һ��Ϊ0

Declare Function USBIO_GetDrvVersion Lib "USBIOX.DLL" () As Long

' �����������汾��,���ذ汾��,�����򷵻�0

Declare Function USBIO_ResetDevice Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean

'��λUSB�豸
' iIndex  ָ��USB2I2C�豸���

Declare Function USBIO_GetDeviceDescr Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef oBuffer As Any, ByRef ioLength As Long) As Boolean
' ��ȡ�豸������
' iIndex,   ָ��USB2I2C�豸���
' oBuffer   ָ��һ���㹻��Ļ�����,���ڱ���������
' ioLength   ָ�򳤶ȵ�Ԫ,����ʱΪ׼����ȡ�ĳ���,���غ�Ϊʵ�ʶ�ȡ�ĳ���

Declare Function USBIO_GetConfigDescr Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef oBuffer As Any, ByRef ioLength As Long) As Boolean
' ��ȡ����������
'  iIndex,    ָ��USB2I2C�豸���
'  oBuffer,   ָ��һ���㹻��Ļ�����,���ڱ���������
'  ioLength   ָ�򳤶ȵ�Ԫ,����ʱΪ׼����ȡ�ĳ���,���غ�Ϊʵ�ʶ�ȡ�ĳ���

Declare Function USBIO_SetIntRoutine Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iIntRoutine As Long) As Boolean
'�趨�жϷ������
' ָ��USB2I2C�豸���
'ָ���жϷ������,ΪNULL��ȡ���жϷ���,�������ж�ʱ���øó���


Declare Function USBIO_ReadInter Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef iStatus As Long) As Boolean
' ��ȡ�ж�����
' iIndex,  ָ��USB2I2C�豸���
' iStatus   ָ��һ��˫�ֵ�Ԫ,���ڱ����ȡ���ж�״̬����,������
' λ7-λ0��ӦUSB2I2C��D7-D0����
'  λ8��ӦUSB2I2C��ERR#����, λ9��ӦUSB2I2C��PEMP����, λ10��ӦUSB2I2C��INT#����, λ11��ӦUSB2I2C��SLCT����

Declare Function USBIO_AbortInter Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
' �����ж����ݶ�����
' iIndex   ָ��USB2I2C�豸���

Declare Function USBIO_ReadData0 Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef oBuffer As Any, ByRef ioLength As Long) As Boolean
' ��0#�˿ڶ�ȡ���ݿ�
 ' iIndex     ָ��USB2I2C�豸���
 ' oBuffer   ָ��һ���㹻��Ļ�����,���ڱ����ȡ������
 ' ioLength   ָ�򳤶ȵ�Ԫ,����ʱΪ׼����ȡ�ĳ���,���غ�Ϊʵ�ʶ�ȡ�ĳ���

Declare Function USBIO_ReadData1 Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef oBuffer As Any, ByRef ioLength As Long) As Boolean
' ��1#�˿ڶ�ȡ���ݿ�
' iIndex,  ָ��USB2I2C�豸���
' oBuffer ָ��һ���㹻��Ļ�����,���ڱ����ȡ������
' ioLength   ָ�򳤶ȵ�Ԫ,����ʱΪ׼����ȡ�ĳ���,���غ�Ϊʵ�ʶ�ȡ�ĳ���

Declare Function USBIO_AbortRead Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
' �������ݿ������
' iIndex    ָ��USB2I2C�豸���

Declare Function USBIO_WriteData0 Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef iBuffer As Any, ByRef ioLength As Long) As Boolean
' ��0#�˿�д�����ݿ�
' iIndex,    ָ��USB2I2C�豸���
' iBuffer     ָ��һ��������,����׼��д��������
' ioLength  ָ�򳤶ȵ�Ԫ,����ʱΪ׼��д���ĳ���,���غ�Ϊʵ��д���ĳ���

Declare Function USBIO_WriteData1 Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef iBuffer As Any, ByRef ioLength As Long) As Boolean
' ��1#�˿�д�����ݿ�
' iIndex,    ָ��USB2I2C�豸���
' iBuffer,    ָ��һ��������,����׼��д��������
' ioLength   ָ�򳤶ȵ�Ԫ,����ʱΪ׼��д���ĳ���,���غ�Ϊʵ��д���ĳ���

Declare Function USBIO_AbortWrite Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
' �������ݿ�д����
' iIndex   ָ��USB2I2C�豸���

Declare Function USBIO_GetStatus Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef iStatus As Long) As Boolean
'  ͨ��USB2I2Cֱ���������ݺ�״̬
'  iIndex,   ָ��USB2I2C�豸���
'  iStatus  ָ��һ��˫�ֵ�Ԫ,���ڱ���״̬����,������
'  λ7-λ0��ӦUSB2I2C��D7-D0����
'  λ8��ӦUSB2I2C��ERR#����, λ9��ӦUSB2I2C��PEMP����, λ10��ӦUSB2I2C��INT#����, λ11��ӦUSB2I2C��SLCT����, λ23��ӦUSB2I2C��SDA����
'  λ13��ӦUSB2I2C��BUSY/WAIT#����, λ14��ӦUSB2I2C��AUTOFD#/DATAS#����,λ15��ӦUSB2I2C��SLCTIN#/ADDRS#����

Declare Function USBIO_ReadI2C Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iDevice As Byte, ByVal iAddr As Byte, ByRef oByte As Byte) As Boolean

'  ��I2C�ӿڶ�ȡһ���ֽ�����
'  iIndex,   ָ��USB2I2C�豸���
'  iDevice,    ��7λָ��I2C�豸��ַ
'  iAddr,    ָ�����ݵ�Ԫ�ĵ�ַ
'  oByte    ָ��һ���ֽڵ�Ԫ,���ڱ����ȡ���ֽ�����

Declare Function USBIO_WriteI2C Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iDevice As Byte, ByVal iAddr As Byte, ByVal iByte As Byte) As Boolean

'    ��I2C�ӿ�д��һ���ֽ�����
'    iIndex,   ָ��USB2I2C�豸���
'    iDevice,   ��7λָ��I2C�豸��ַ
'    iAddr,  ָ�����ݵ�Ԫ�ĵ�ַ
'    iByte  ��д����ֽ�����

Declare Function USBIO_SetExclusive Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iExclusive As Long) As Boolean
' ���ö�ռʹ�õ�ǰUSB2I2C�豸
' iIndex,    ָ��USB2I2C�豸���
' iExclusive  Ϊ0���豸���Թ���ʹ��,��0���ռʹ��

Declare Function USBIO_SetTimeout Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iWriteTimeout As Long, ByVal iReadTimeout As Long) As Boolean
'  ����USB���ݶ�д�ĳ�ʱ
'  iIndex,  // ָ��USB2I2C�豸���
'  iWriteTimeout  ָ��USBд�����ݿ�ĳ�ʱʱ��,�Ժ���mSΪ��λ,0xFFFFFFFFָ������ʱ(Ĭ��ֵ)
'  iReadTimeout  ָ��USB��ȡ���ݿ�ĳ�ʱʱ��,�Ժ���mSΪ��λ,0xFFFFFFFFָ������ʱ(Ĭ��ֵ)

Declare Function USBIO_ReadData Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef oBuffer As Any, ByRef ioLength As Long) As Boolean
' ��ȡ���ݿ�
' iIndex,    ָ��USB2I2C�豸���
' oBuffer,    ָ��һ���㹻��Ļ�����,���ڱ����ȡ������
' ioLength      ָ�򳤶ȵ�Ԫ,����ʱΪ׼����ȡ�ĳ���,���غ�Ϊʵ�ʶ�ȡ�ĳ���

Declare Function USBIO_WriteData Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef iBuffer As Any, ByRef ioLength As Long) As Boolean
'  д�����ݿ�
'  iIndex,    ָ��USB2I2C�豸���
'  iBuffer,    ָ��һ��������,����׼��д��������
'  ioLength   ָ�򳤶ȵ�Ԫ,����ʱΪ׼��д���ĳ���,���غ�Ϊʵ��д���ĳ���

Declare Function USBIO_GetDeviceName Lib "USBIOX.DLL" (ByVal iIndex As Long) As Long           ''''
' ����ָ��USB2I2C�豸���ƵĻ�����,�����򷵻�NULL
' iIndex   ָ��USB2I2C�豸���,0��Ӧ��һ���豸

Declare Function USBIO_FlushBuffer Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
' ���USB2I2C�Ļ�����
' iIndex   ָ��USB2I2C�豸���

Declare Function USBIO_WriteRead Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iWriteLength As Long, ByRef iWriteBuffer As Any, ByVal iReadStep As Long, ByVal iReadTimes As Long, ByRef oReadLength As Long, ByRef oReadBuffer As Any) As Boolean
' USBIO_WriteRead   ִ������������,�����������
' iIndex,    ָ��USB2I2C�豸���
' iWriteLength,   д����,׼��д���ĳ���
' iWriteBuffer,    ָ��һ��������,����׼��д��������
' iReadStep,    ׼����ȡ�ĵ�����ĳ���, ׼����ȡ���ܳ���Ϊ(iReadStep*iReadTimes)
' iReadTimes,    ׼����ȡ�Ĵ���
' oReadLength,    ָ�򳤶ȵ�Ԫ,���غ�Ϊʵ�ʶ�ȡ�ĳ���
' oReadBuffer      ָ��һ���㹻��Ļ�����,���ڱ����ȡ������

Declare Function USBIO_SetStream Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iMode As Long) As Boolean
' USBIO_SetStream   ���ô�����ģʽ
' iIndex,    ָ��USB2I2C�豸���
' iMode      ָ��ģʽ,������
' λ1-λ0: I2C�ӿ��ٶ�/SCLƵ��, 00=����/20KHz,01=��׼/100KHz,10=����/400KHz,11=����/750KHz
' λ2:     SPI��I/O��/IO����, 0=���뵥��(D5��/D7��),1=˫��˫��(D5��D4��/D7��D6��)
' λ7:     SPI�ֽ��е�λ˳��, 0=��λ��ǰ, 1=��λ��ǰ
' ��������,����Ϊ0

Declare Function USBIO_SetDelaymS Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iDelay As Long) As Boolean
'  USBIO_SetDelaymS     ����Ӳ���첽��ʱ,���ú�ܿ췵��,������һ��������֮ǰ��ʱָ��������
 ' iIndex,    ָ��USB2I2C�豸���
 ' iDelay      ָ����ʱ�ĺ�����

Declare Function USBIO_StreamI2C Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iWriteLength As Long, ByRef iWriteBuffer As Any, ByVal iReadLength As Long, ByRef oReadBuffer As Any) As Boolean
' USBIO_StreamI2C     ����I2C������,2�߽ӿ�,ʱ����ΪSCL����,������ΪSDA����(׼˫��I/O),�ٶ�Լ56K�ֽ�
' iIndex,    ָ��USB2I2C�豸���
' iWriteLength,    ׼��д���������ֽ���
' iWriteBuffer,    ָ��һ��������,����׼��д��������,���ֽ�ͨ����I2C�豸��ַ����д����λ
' iReadLength,     ׼����ȡ�������ֽ���
' oReadBuffer     ָ��һ��������,���غ��Ƕ��������
Declare Function USBIO_ReadEEPROM Lib "USBIOX.DLL" (ByVal iIndexas As Long, ByVal iEepromID As EEPROM_TYPE, ByVal iAddr As Long, ByVal iLength As Long, ByRef oBuffer As Any) As Boolean
' i    Index  ָ��USB2I2C�豸���
' iEepromID   ָ��EEPROM�ͺ�
' iAddr       ָ�����ݵ�Ԫ�ĵ�ַ
' iLength     ׼����ȡ�������ֽ���
' oBuffer     ָ��һ��������,���غ��Ƕ��������

Declare Function USBIO_WriteEEPROM Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iEepromID As EEPROM_TYPE, ByVal iAddr As Long, ByVal iLength As Long, ByRef iBuffer As Any) As Boolean
' iIndex,    ָ��USB2I2C�豸���
' iEepromID, ָ��EEPROM�ͺ�
' iAddr,     ָ�����ݵ�Ԫ�ĵ�ַ
' iLength,   ׼��д���������ֽ���
' iBuffer    ָ��һ��������,����׼��д��������

Declare Function USBIO_SetBufUpload Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iEnableOrClear As Long) As Boolean  ' Ϊ0���ֹ�ڲ������ϴ�ģʽ,ʹ��ֱ���ϴ�,��0�������ڲ������ϴ�ģʽ������������е���������
' USBIO_SetBufUpload  ' �趨�ڲ������ϴ�ģʽ
' iIndex,          0ָ��USB2I2C�豸���,0��Ӧ��һ���豸
' iEnableOrClear  Ϊ0���ֹ�ڲ������ϴ�ģʽ,ʹ��ֱ���ϴ�,��0�������ڲ������ϴ�ģʽ������������е���������
' ��������ڲ������ϴ�ģʽ,��ôUSB2I2C�������򴴽��߳��Զ�����USB�ϴ����ݵ��ڲ�������,ͬʱ����������е���������,��Ӧ�ó������USBIO_ReadData���������ػ������е���������

Declare Function USBIO_QueryBufUpload Lib "USBIOX.DLL" (ByVal iIndex As Long) As Long
' USBIO_QueryBufUpload   ��ѯ�ڲ��ϴ��������е��������ݰ�����,�ɹ��������ݰ�����,������-1
' iIndex                ָ��USB2I2C�豸���,0��Ӧ��һ���豸

Declare Function USBIO_SetBufDownload Lib "USBIOX.DLL" (ByVal iIndex As Long, ByVal iEnableOrClear As Long) As Boolean
'  USBIO_SetBufDownload  �趨�ڲ������´�ģʽ
'  iIndex,              ָ��USB2I2C�豸���,0��Ӧ��һ���豸
'  iEnableOrClear       Ϊ0���ֹ�ڲ������´�ģʽ,ʹ��ֱ���´�,��0�������ڲ������´�ģʽ������������е���������
'  ��������ڲ������´�ģʽ,��ô��Ӧ�ó������USBIO_WriteData�󽫽����ǽ�USB�´����ݷŵ��ڲ�����������������,����USB2I2C�������򴴽����߳��Զ�����ֱ�����

Declare Function USBIO_QueryBufDownload Lib "USBIOX.DLL" (ByVal iIndex As Long) As Long    ' ָ��USB2I2C�豸���,0��Ӧ��һ���豸
'  USBIO_QueryBufDownload  ��ѯ�ڲ��´��������е�ʣ�����ݰ�����(��δ����),�ɹ��������ݰ�����,������-1
'  iIndex                 ָ��USB2I2C�豸���,0��Ӧ��һ���豸


Declare Function USBIO_ResetInter Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
'  USBIO_ResetInter   ��λ�ж����ݶ�����
'  iIndex            ָ��USB2I2C�豸���

Declare Function USBIO_ResetRead Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
'  USBIO_ResetRead  ��λ���ݿ������
'  iIndex          ָ��USB2I2C�豸���

Declare Function USBIO_ResetWrite Lib "USBIOX.DLL" (ByVal iIndex As Long) As Boolean
'    USBIO_ResetRead    ��λ���ݿ������
'    iIndex            ָ��USB2I2C�豸���

'typedef     VOID    ( CALLBACK  * mUSBIO_NOTIFY_ROUTINE ) (  ' �豸�¼�֪ͨ�ص�����
'    ULONG           iEventStatus );  ' �豸�¼��͵�ǰ״̬(�����ж���): 0=�豸�γ��¼�, 3=�豸�����¼�

Public Const USBIO_DEVICE_ARRIVAL = 3               ' �豸�����¼�,�Ѿ�����
Public Const USBIO_DEVICE_REMOVE_PEND = 1         ' �豸��Ҫ�γ�
Public Const USBIO_DEVICE_REMOVE = 0              ' �豸�γ��¼�,�Ѿ��γ�

Declare Function USBIO_SetDeviceNotify Lib "USBIOX.DLL" (ByVal iIndex As Long, ByRef iDeviceID As String, ByVal iNotifyRoutine As Long) As Boolean
'  USBIO_SetDeviceNotify     �趨�豸�¼�֪ͨ����
'  iIndex,                  ָ��USB2I2C�豸���,0��Ӧ��һ���豸
'  iDeviceID,               ��ѡ����,ָ���ַ���,ָ������ص��豸��ID,�ַ�����\0��ֹ
'  iNotifyRoutine           (������ַ)ָ���豸�¼��ص�����, ΪNULL��ȡ���¼�֪ͨ, �����ڼ�⵽�¼�ʱ���øó���

