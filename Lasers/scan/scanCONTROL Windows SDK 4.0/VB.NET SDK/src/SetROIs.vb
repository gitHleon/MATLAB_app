﻿Imports System
Imports System.Runtime.InteropServices
Imports System.Text
Imports System.Threading


Namespace VB

    Public Class VBscanCNONTROLSample

        ' Global variables
        Const MAX_INTERFACE_COUNT As Integer = 5
        Const Max_RESOLUTIONS As Integer = 6

        Public Shared uiResolution As UInteger = 0
        Public Shared hLLT As UInteger = 0
        Public Shared tscanCONTROLType As CLLTI.TScannerType

        Public Shared abyProfileBuffer As Byte()

        Public Shared bProfileReceived As UInteger = 0
        Public Shared uiNeededProfileCount As UInteger = 10
        Public Shared uiProfileDataSize As UInteger = 0
        Public Shared raster_x As Double = 0
        Public Shared raster_z As Double = 0



        ' Define an array with two AutoResetEvent WaitHandles.
        Shared hProfileEvent As AutoResetEvent = New AutoResetEvent(False)

        'TOCHECK: STATTHREAD
        Shared Sub Main()
            scanCONTROL_Sample()
        End Sub

        Shared Sub scanCONTROL_Sample()
            Dim auiInterfaces(MAX_INTERFACE_COUNT - 1) As UInteger
            Dim auiResolutions(Max_RESOLUTIONS - 1) As UInteger

            Dim sbDevName As StringBuilder = New StringBuilder(100)
            Dim sbVenName As StringBuilder = New StringBuilder(100)

            Dim uiBufferCount As UInteger = 20
            Dim uiMainReflection As UInteger = 0
            Dim uiPacketSize As UInteger = 1024

            Dim iInterfaceCount As Integer = 0
            Dim uiShutterTime As UInteger = 100
            Dim uiIdleTime As UInteger = 900
            Dim iRetValue As Integer
            Dim bOK As Boolean = True
            Dim bConnected As Boolean = False
            Dim cki As ConsoleKeyInfo

            Console.WriteLine("----- Connect to scanCONTROL -----" & Environment.NewLine)

            ' Create an Ethernet Device -> returns handle to LLT device
            hLLT = CLLTI.CreateLLTDevice(CLLTI.TInterfaceType.INTF_TYPE_ETHERNET)
            If (hLLT <> 0) Then
                Console.WriteLine("CreateLLTDevice OK")
            Else
                Console.WriteLine("Error during CreateLLTDevice" & Environment.NewLine)
            End If

            Console.WriteLine("----- Connect to scanCONTROL -----" & Environment.NewLine)

            ' Gets the available interfaces from the scanCONTROL handle
            iInterfaceCount = CLLTI.GetDeviceInterfacesFast(hLLT, auiInterfaces, auiInterfaces.GetLength(0))
            If (iInterfaceCount <= 0) Then
                Console.WriteLine("FAST: There is no scanCONTROL connected")
            ElseIf (iInterfaceCount = 1) Then
                Console.WriteLine("FAST: There is 1 scanCONTROL connected ")
            Else
                Console.WriteLine("FAST: There are " & iInterfaceCount & " scanCONTROL's connected")
            End If

            If (iInterfaceCount >= 1) Then
                Dim target4 As UInteger = auiInterfaces(0) And &HFF
                Dim target3 As UInteger = (auiInterfaces(0) And &HFF00) >> 8
                Dim target2 As UInteger = (auiInterfaces(0) And &HFF0000) >> 16
                Dim target1 As UInteger = (auiInterfaces(0) And &HFF000000) >> 24

                ' Set the first IP address detected by GetDeviceInterfacesFast to handle
                Console.WriteLine("Select the device interface: " & target1 & "." & target2 & "." & target3 & "." & target4)
                iRetValue = CLLTI.SetDeviceInterface(hLLT, auiInterfaces(0), 0)
                If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                    OnError("Error during SetDeviceInterface", iRetValue)
                    bOK = False
                End If

                If (bOK) Then
                    ' Connect to sensor with the device interface set before
                    Console.WriteLine("Connecting to scanCONTROL")
                    iRetValue = CLLTI.Connect(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then

                        OnError("Error during Connect", iRetValue)
                        bOK = False

                    Else
                        bConnected = True
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Get scanCONTROL Info -----" & Environment.NewLine)
                    ' Read the device name and vendor from scanner
                    Console.WriteLine("Get Device Name")
                    iRetValue = CLLTI.GetDeviceName(hLLT, sbDevName, sbDevName.Capacity, sbVenName, sbVenName.Capacity)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetDevName", iRetValue)
                        bOK = False
                    Else
                        Console.WriteLine(" - Devname: " & sbDevName.ToString & Environment.NewLine & " - Venname: " & sbVenName.ToString)
                    End If
                End If

                If (bOK) Then

                    ' Get the scanCONTROL type and check if it is valid
                    Console.WriteLine("Get scanCONTROL type")
                    iRetValue = CLLTI.GetLLTType(hLLT, tscanCONTROLType)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetLLTType", iRetValue)
                        bOK = False
                    End If

                    If (iRetValue = CLLTI.GENERAL_FUNCTION_DEVICE_NAME_NOT_SUPPORTED) Then
                        Console.WriteLine(" - Can't decode scanCONTROL type. Please contact Micro-Epsilon for a newer version of the LLT.dll.")
                    End If

                    If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL27xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL27xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL27xx")
                        raster_x = 1.25
                        raster_z = 100.0 / 480.0
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL25xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL25xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL25xx")
                        raster_x = 2.5
                        raster_z = 100.0 / 1024.0
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL26xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL26xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL26xx")
                        raster_x = 1.25
                        raster_z = 100.0 / 480.0
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL29xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL29xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL29xx")
                        raster_x = 2.5
                        raster_z = 100.0 / 1024.0
                    ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then
                        Console.WriteLine(" - The scanCONTROL is a scanCONTROL30xx")
                        raster_x = 1.5625
                        raster_z = 200.0 / 1088.0
                    Else
                        Console.WriteLine(" - The scanCONTROL is a undefined type!" & Environment.NewLine & "Please contact Micro-Epsilon for a newer SDK!")
                    End If

                    ' Get all possible resolutions for connected sensor and save them in array 
                    Console.WriteLine("Get all possible resolutions")
                    iRetValue = CLLTI.GetResolutions(hLLT, auiResolutions, auiResolutions.GetLength(0))
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during GetResolutions", iRetValue)
                        bOK = False
                    End If

                    ' Set the max. possible resolution
                    uiResolution = auiResolutions(0)
                End If

                ' Set scanner settings to valid parameters for this example                
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Set scanCONTROL Parameters -----" & Environment.NewLine)
                    Console.WriteLine("Set resolution to " & uiResolution)
                    iRetValue = CLLTI.SetResolution(hLLT, uiResolution)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetResolution", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set BufferCount to " & uiBufferCount)
                    iRetValue = CLLTI.SetBufferCount(hLLT, uiBufferCount)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetBufferCount", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set MainReflection to " & uiMainReflection)
                    iRetValue = CLLTI.SetMainReflection(hLLT, uiMainReflection)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetMainReflection", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Packetsize to " & uiPacketSize)
                    iRetValue = CLLTI.SetPacketSize(hLLT, uiPacketSize)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetPacketSize", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set Profile config to PROFILE")
                    iRetValue = CLLTI.SetProfileConfig(hLLT, CLLTI.TProfileConfig.PROFILE)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetProfileConfig", iRetValue)
                        bOK = False
                    End If
                End If



                If (bOK) Then
                    Console.WriteLine("Set trigger to internal")
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_TRIGGER, CLLTI.TRIG_INTERNAL)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_TRIGGER)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set shutter time to " & uiShutterTime)
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXPOSURE_TIME, uiShutterTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_SHUTTERTIME)", iRetValue)
                        bOK = False
                    End If
                End If

                If (bOK) Then
                    Console.WriteLine("Set idle time to " & uiIdleTime & Environment.NewLine)
                    iRetValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IDLETIME, uiIdleTime)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during SetFeature(FEATURE_FUNCTION_IDLETIME)", iRetValue)
                        bOK = False
                    End If
                End If


                ' Main tasks in this example
                If (bOK) Then
                    SetROI1()
                End If

                If (bOK) Then
                    SetROI2()
                End If

                If (bOK) Then
                    SetRONI()
                End If

                If (bOK) Then
                    SetROIAutoExposure()
                End If

                'Setup Callback
                If (bOK) Then
                    Console.WriteLine(Environment.NewLine & "----- Setup Callback function and event -----" & Environment.NewLine)

                    Console.WriteLine("Register the callback")
                    ' Set the callback function
                    Dim gch As GCHandle = GCHandle.Alloc(New CLLTI.ProfileReceiveMethod(AddressOf ProfileEvent))

                    ' Register the callback
                    iRetValue = CLLTI.RegisterCallback(hLLT, CLLTI.TCallbackType.STD_CALL, DirectCast(gch.Target, CLLTI.ProfileReceiveMethod), hLLT)
                    'gch.Free()
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during RegisterCallback", iRetValue)
                        bOK = False
                    End If

                    Console.WriteLine(Environment.NewLine & "----- Get profiles with Callback from scanCONTROL -----" & Environment.NewLine)
                    GetProfiles_Callback()
                End If

                Console.WriteLine(Environment.NewLine & "----- Disconnect from scanCONTROL -----" & Environment.NewLine)

                If (bConnected) Then
                    ' Disconnect from the sensor
                    Console.WriteLine("Disconnect the scanCONTROL")
                    iRetValue = CLLTI.Disconnect(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during Disconnect", iRetValue)
                    End If
                End If

                If (bConnected) Then
                    ' Free ressources
                    Console.WriteLine("Delete the scanCONTROL instance")
                    iRetValue = CLLTI.DelDevice(hLLT)
                    If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                        OnError("Error during Delete", iRetValue)
                    End If
                End If
            End If

            'Wait for a keyboard hit
            While (True)
                cki = Console.ReadKey()
                If (cki.KeyChar <> "0") Then
                    Exit While
                End If
            End While

        End Sub

        Shared Sub SetROI1()

            Dim iretValue As Integer
            Dim col_start As UShort
            Dim col_size As UShort
            Dim row_start As UShort
            Dim row_size As UShort

            'Percentage X/Z of ROI
            Dim start_z As Double = 10.0
            Dim end_z As Double = 90.0
            Dim start_x As Double = 10.0
            Dim end_x As Double = 45.0

            Console.WriteLine("ROI1 Start Z (%): " & start_z)
            Console.WriteLine("ROI1 End Z (%): " & end_z)
            Console.WriteLine("ROI1 Start X (%): " & start_x)
            Console.WriteLine("ROI1 End X (%): " & end_x)

            If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL26xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL26xx_xxx) Then

                col_start = (65535 - ((Math.Round(end_x / raster_x) * raster_x) / 100 * 65535))
                col_size = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
                row_start = (Math.Round(start_z / raster_z) * raster_z / 100 * 65536)
                row_size = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL25xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL25xx_xxx) Then

                col_start = (65535 - ((Math.Round(end_x / raster_x) * raster_x) / 100 * 65535))
                col_size = ((Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535))
                row_start = ((65535 - ((Math.Round(end_z / raster_z) * raster_z) / 100 * 65535)))
                row_size = ((Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535))


            ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL27xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL27xx_xxx) Then

                col_start = (65535 - ((Math.Round(end_x / raster_x) * raster_x) / 100 * 65535))
                col_size = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
                row_start = (65535 - ((Math.Round(end_z / raster_z) * raster_z) / 100 * 65535))
                row_size = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL29xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL29xx_xxx) Then

                col_start = (65535 - ((Math.Round(end_x / raster_x) * raster_x) / 100 * 65535))
                col_size = ((Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535))
                row_start = ((65535 - ((Math.Round(end_z / raster_z) * raster_z) / 100 * 65535)))
                row_size = ((Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535))


            ElseIf (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then

                col_start = (Math.Round(start_x / raster_x) * raster_x / 100 * 65536)
                col_size = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
                row_start = (Math.Round(start_z / raster_z) * raster_z / 100 * 65536)
                row_size = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            Else

                Console.WriteLine("The scanCONTROL is a undefined type\nPlease contact Micro-Epsilon for a newer SDK" & Environment.NewLine)
                Return

            End If

            Console.WriteLine("Enable ROI1 free region")
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI1_PRESET, 1 << 11)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI1_PRESET)", iretValue)
            End If

            Console.WriteLine("Set ROI1_Position parameter")
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI1_POSITION, (CUInt(col_start) << 16) + col_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI1_POSITION)", iretValue)
            End If

            Console.WriteLine("Set ROI1_Distance parameter")
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI1_DISTANCE, (CUInt(row_start) << 16) + row_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI1_DISTANCE)", iretValue)
            End If

            Console.WriteLine("Activate ROI1 free region" & Environment.NewLine)
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EXTRA_PARAMETER, 0)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_EXTRA_PARAMETER)", iretValue)
            End If
        End Sub

        Shared Sub SetROI2()

            Dim iretValue As Integer
            Dim col_start As UShort
            Dim col_size As UShort
            Dim row_start As UShort
            Dim row_size As UShort
            Dim tmp As UInt32 = 0

            'Percentage X/Z of ROI
            Dim start_z As Double = 10.0
            Dim end_z As Double = 90.0
            Dim start_x As Double = 55.0
            Dim end_x As Double = 90.0

            Console.WriteLine("ROI2 Start Z (%): " & start_z)
            Console.WriteLine("ROI2 End Z (%): " & end_z)
            Console.WriteLine("ROI2 Start X (%): " & start_x)
            Console.WriteLine("ROI2 End X (%): " & end_x)

            If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then

                col_start = (Math.Round(start_x / raster_x) * raster_x / 100 * 65536)
                col_size = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
                row_start = (Math.Round(start_z / raster_z) * raster_z / 100 * 65536)
                row_size = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            Else

                Console.WriteLine("The scanCONTROL is a undefined type\nPlease contact Micro-Epsilon for a newer SDK" & Environment.NewLine)
                Return
            End If

            Console.WriteLine("Enable ROI2 free region")
            iretValue = CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iretValue)
            End If

            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp Or &H1UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iretValue)
            End If

            Console.WriteLine("Set ROI2_Position parameter")
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI2_POSITION, (CUInt(col_start) << 16) + col_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI2_POSITION)", iretValue)
            End If

            Console.WriteLine("Set ROI2_Distance parameter" & Environment.NewLine)
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_ROI2_DISTANCE, (CUInt(row_start) << 16) + row_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_ROI2_DISTANCE)", iretValue)
            End If

        End Sub

        Shared Sub SetRONI()

            Dim iretValue As Integer
            Dim col_start As UShort
            Dim col_size As UShort
            Dim row_start As UShort
            Dim row_size As UShort
            Dim tmp As UInt32 = 0

            'Percentage X/Z of ROI
            Dim start_z As Double = 35.0
            Dim end_z As Double = 55.0
            Dim start_x As Double = 30.0
            Dim end_x As Double = 70.0

            Console.WriteLine("RONI Start Z (%): " & start_z)
            Console.WriteLine("RONI End Z (%): " & end_z)
            Console.WriteLine("RONI Start X (%): " & start_x)
            Console.WriteLine("RONI End X (%): " & end_x)


            If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then

                col_start = (Math.Round(start_x / raster_x) * raster_x / 100 * 65536)
                col_size = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
                row_start = (Math.Round(start_z / raster_z) * raster_z / 100 * 65536)
                row_size = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            Else

                Console.WriteLine("The scanCONTROL is a undefined type\nPlease contact Micro-Epsilon for a newer SDK" & Environment.NewLine)
                Return
            End If

            Console.WriteLine("Enable RONI free region")
            iretValue = CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iretValue)
            End If

            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp Or &H2UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iretValue)
            End If

            Console.WriteLine("Set RONI_Position parameter")
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_RONI_POSITION, (CUInt(col_start) << 16) + col_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_RONI_POSITION)", iretValue)
            End If

            Console.WriteLine("Set RONI_Distance parameter" & Environment.NewLine)
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_RONI_DISTANCE, (CUInt(row_start) << 16) + row_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_RONI_DISTANCE)", iretValue)
            End If

        End Sub

        Shared Sub SetROIAutoExposure()

            Dim iretValue As Integer
            Dim col_start As UShort
            Dim col_size As UShort
            Dim row_start As UShort
            Dim row_size As UShort
            Dim tmp As UInt32 = 0

            'Percentage X/Z of ROI
            Dim start_z As Double = 5.0
            Dim end_z As Double = 95.0
            Dim start_x As Double = 5.0
            Dim end_x As Double = 95.0

            Console.WriteLine("ROI auto exposure Start Z (%): " & start_z)
            Console.WriteLine("ROI auto exposure End Z (%): " & end_z)
            Console.WriteLine("ROI auto exposure Start X (%): " & start_x)
            Console.WriteLine("ROI auto exposure End X (%): " & end_x)

            If (tscanCONTROLType >= CLLTI.TScannerType.scanCONTROL30xx_25 And tscanCONTROLType <= CLLTI.TScannerType.scanCONTROL30xx_xxx) Then

                col_start = (Math.Round(start_x / raster_x) * raster_x / 100 * 65536)
                col_size = (Math.Round((end_x - start_x) / raster_x) * raster_x / 100 * 65535)
                row_start = (Math.Round(start_z / raster_z) * raster_z / 100 * 65536)
                row_size = (Math.Round((end_z - start_z) / raster_z) * raster_z / 100 * 65535)

            Else

                Console.WriteLine("The scanCONTROL is a undefined type\nPlease contact Micro-Epsilon for a newer SDK" & Environment.NewLine)
                Return
            End If

            Console.WriteLine("Enable auto exposure region")
            iretValue = CLLTI.GetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during GetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iretValue)
            End If

            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_IMAGE_FEATURES, tmp Or &H4UI)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_IMAGE_FEATURES)", iretValue)
            End If

            Console.WriteLine("Set ROI auto exposure Position parameter")
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EA_REFERENCE_REGION_POSITION, (CUInt(col_start) << 16) + col_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_RONI_POSITION)", iretValue)
            End If

            Console.WriteLine("Set ROI auto exposure Distance parameter" & Environment.NewLine)
            iretValue = CLLTI.SetFeature(hLLT, CLLTI.FEATURE_FUNCTION_EA_REFERENCE_REGION_DISTANCE, (CUInt(row_start) << 16) + row_size)
            If (iretValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during SetFeature(FEATURE_FUNCTION_RONI_DISTANCE)", iretValue)
            End If

        End Sub

        ' Evalute received profiles via callback function
        Shared Sub GetProfiles_Callback()

            Dim iRetValue As Integer
            Dim adValueX(uiResolution) As Double
            Dim adValueZ(uiResolution) As Double

            ' Allocate the profile buffer to the maximal profile size times the profile count
            ReDim abyProfileBuffer(uiResolution * 64 * uiNeededProfileCount)
            Dim abyTimestamp(16) As Byte

            ' Start continous profile transmission
            Console.WriteLine("Enable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 1)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If


            ' Wait for profile event (or timeout)
            Console.WriteLine("Wait for needed profiles")
            If (hProfileEvent.WaitOne(2000) <> True) Then
                Console.WriteLine("No profile received")
                Return
            End If

            ' Test the size of profile
            If (uiProfileDataSize = uiResolution * 64) Then
                Console.WriteLine("Profile size is OK")
            Else
                Console.WriteLine("Profile size is wrong")
                Return
            End If
            ' Convert partial profile to x and z values
            Console.WriteLine("Converting of profile data from the first reflection")
            iRetValue = CLLTI.ConvertProfile2Values(hLLT, abyProfileBuffer, uiResolution, CLLTI.TProfileConfig.PROFILE, tscanCONTROLType,
                0, 1, Nothing, Nothing, Nothing, adValueX, adValueZ, Nothing, Nothing)
            If (((iRetValue & CLLTI.CONVERT_X) = 0) Or ((iRetValue & CLLTI.CONVERT_Z) = 0)) Then
                OnError("Error during Converting of profile data", iRetValue)
                Return
            End If

            'Display x And z values
            DisplayProfile(adValueX, adValueZ, uiResolution)

            ' Extract the 16-byte timestamp from the profile buffer into timestamp buffer and display it for each profile
            For iNeededProfile As Integer = 0 To uiNeededProfileCount - 1
                Buffer.BlockCopy(abyProfileBuffer, 64 * uiResolution * (iNeededProfile + 1) - 16, abyTimestamp, 0, 16)
                DisplayTimestamp(abyTimestamp)
            Next


            ' Stop continous profile transmission
            Console.WriteLine("Disable the measurement")
            iRetValue = CLLTI.TransferProfiles(hLLT, CLLTI.TTransferProfileType.NORMAL_TRANSFER, 0)
            If (iRetValue < CLLTI.GENERAL_FUNCTION_OK) Then
                OnError("Error during TransferProfiles", iRetValue)
                Return
            End If

        End Sub


        ' Callback function which copies the received data into the buffer and sets an event after the specified profiles
        Shared Sub ProfileEvent(ByVal data As IntPtr, uiSize As UInteger, uiUserData As UInteger)

            If (uiSize > 0) Then
                If (bProfileReceived < uiNeededProfileCount) Then
                    ' If the needed profile count not arrived: copy the new Profile in the buffer and increase the recived buffer count
                    uiProfileDataSize = uiSize
                    ' Kopieren des Unmanaged Datenpuffers (data) in die Anwendung
                    Marshal.Copy(data, abyProfileBuffer, bProfileReceived * uiSize, uiSize)
                    bProfileReceived += 1
                End If

                If (bProfileReceived >= uiNeededProfileCount) Then
                    ' If the needed profile count is arrived: set the event
                    hProfileEvent.Set()

                End If
            End If
        End Sub


        ' Display the X/Z-Data of one profile
        Shared Sub DisplayProfile(adValueX As Double(), adValueZ As Double(), uiResolution As UInteger)

            Dim iNumberSize As Integer = 0
            For i As Integer = 0 To uiResolution - 1
                ' Prints the X- and Z-values
                iNumberSize = adValueX(i).ToString().Length
                Console.Write(Environment.NewLine & "Profiledata (" & i & "): X = " & adValueX(i).ToString())

                Do Until iNumberSize = 8
                    Console.Write(" ")
                    iNumberSize += 1
                Loop

                iNumberSize = adValueZ(i).ToString().Length
                Console.Write(" Z = " & adValueZ(i).ToString())

                Do Until iNumberSize = 8
                    Console.Write(" ")
                    iNumberSize += 1
                Loop

                ' Wait for display
                If (i Mod 8 = 0) Then
                    System.Threading.Thread.Sleep(10)
                End If
            Next
            Console.WriteLine("")
        End Sub

        ' Display the timestamp
        Shared Sub DisplayTimestamp(abyTimestamp As Byte())

            Dim dShutterOpen As Double = 0.0
            Dim dShutterClose As Double = 0.0
            Dim uiProfileCount As UInteger = 0UI

            ' Decode the timestamp
            CLLTI.Timestamp2TimeAndCount(abyTimestamp, dShutterOpen, dShutterClose, uiProfileCount)
            Console.WriteLine("ShutterOpen: " & dShutterOpen & " ShutterClose: " & dShutterClose)
            Console.WriteLine("ProfileCount: " & uiProfileCount)
        End Sub

        ' Display the error text
        Shared Sub OnError(strErrorTxt As String, iErrorValue As Integer)

            Dim acErrorString(200) As Byte

            Console.WriteLine(strErrorTxt)
            If (CLLTI.TranslateErrorValue(hLLT, iErrorValue, acErrorString, acErrorString.GetLength(0)) _
                                            >= CLLTI.GENERAL_FUNCTION_OK) Then
                Console.WriteLine(System.Text.Encoding.ASCII.GetString(acErrorString, 0, acErrorString.GetLength(0)))
            End If
        End Sub

    End Class

End Namespace