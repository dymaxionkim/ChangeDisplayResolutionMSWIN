Function Set-ScreenResolution { 
    param ( 
    [Parameter(Mandatory=$true, 
               Position = 0)] 
    [int] 
    $No,
    [Parameter(Mandatory=$true, 
               Position = 1)] 
    [int] 
    $Width, 
    [Parameter(Mandatory=$true, 
               Position = 2)] 
    [int] 
    $Height,
    [Parameter(Mandatory=$false, 
               Position = 3)] 
    [int] 
    $Frequency 
    ) 
    $pinvokeCode = @" 
    using System; 
    using System.Runtime.InteropServices; 
    namespace Resolution 
    { 
        [StructLayout(LayoutKind.Sequential)] 
        public struct DEVMODE1 
        { 
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
            public string dmDeviceName; 
            public short dmSpecVersion; 
            public short dmDriverVersion; 
            public short dmSize; 
            public short dmDriverExtra; 
            public int dmFields; 
            public short dmOrientation; 
            public short dmPaperSize; 
            public short dmPaperLength; 
            public short dmPaperWidth; 
            public short dmScale; 
            public short dmCopies; 
            public short dmDefaultSource; 
            public short dmPrintQuality; 
            public short dmColor; 
            public short dmDuplex; 
            public short dmYResolution; 
            public short dmTTOption; 
            public short dmCollate; 
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
            public string dmFormName; 
            public short dmLogPixels; 
            public short dmBitsPerPel; 
            public int dmPelsWidth; 
            public int dmPelsHeight; 
            public int dmDisplayFlags; 
            public int dmDisplayFrequency; 
            public int dmICMMethod; 
            public int dmICMIntent; 
            public int dmMediaType; 
            public int dmDitherType; 
            public int dmReserved1; 
            public int dmReserved2; 
            public int dmPanningWidth; 
            public int dmPanningHeight; 
        }; 
        [StructLayout(LayoutKind.Sequential)] 
        public struct DISPLAY_DEVICE 
        { 
            public int cb; 
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
            public string DeviceName; 
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] 
            public string DeviceString; 
            public int StateFlags; 
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] 
            public string DeviceID; 
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)] 
            public string DeviceKey; 
        }; 
        class User_32 
        { 
            [DllImport("user32.dll")] 
            public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE1 devMode); 
            [DllImport("user32.dll")] 
            public static extern int ChangeDisplaySettingsEx(string deviceName, ref DEVMODE1 devMode, uint mustNull01, int flags, uint mustNull02);
            [DllImport("user32.dll")] 
            public static extern int EnumDisplayDevices(string lpDevice, int iDevNum, ref DISPLAY_DEVICE lpDisplayDevice, int dwFlags); 
            public const int ENUM_CURRENT_SETTINGS = -1; 
            public const int CDS_UPDATEREGISTRY = 0x01; 
            public const int CDS_TEST = 0x02; 
            public const int DISP_CHANGE_SUCCESSFUL = 0; 
            public const int DISP_CHANGE_RESTART = 1; 
            public const int DISP_CHANGE_FAILED = -1; 
        } 
        public class ScreenResolution 
        { 
            static public string ChangeResolution(int no, int width, int height, int frequency) 
            { 
                DISPLAY_DEVICE DispDev = GetDisplayDevice(); 
                if (0 != User_32.EnumDisplayDevices(null, no, ref DispDev, 0)) 
                { 
                    DEVMODE1 dm = GetDevMode1(); 
                    if (0 != User_32.EnumDisplaySettings(DispDev.DeviceName, User_32.ENUM_CURRENT_SETTINGS, ref dm)) 
                    { 
                        dm.dmPelsWidth = width; 
                        dm.dmPelsHeight = height; 
                        if (frequency > 0) {
                            dm.dmDisplayFrequency = frequency;
                            dm.dmFields = 0x580000;
                        }
                        else
                        {
                            dm.dmFields = 0x180000;
                        }
                        int iRet = User_32.ChangeDisplaySettingsEx(DispDev.DeviceName, ref dm, 0, User_32.CDS_TEST, 0);
                        if (iRet == User_32.DISP_CHANGE_FAILED) 
                        { 
                            return "Unable To Process Your Request. Sorry For This Inconvenience."; 
                        } 
                        else 
                        { 
                            iRet = User_32.ChangeDisplaySettingsEx(DispDev.DeviceName, ref dm, 0, User_32.CDS_UPDATEREGISTRY, 0);
                            switch (iRet) 
                            { 
                                case User_32.DISP_CHANGE_SUCCESSFUL: 
                                    { 
                                        return "Success"; 
                                    } 
                                case User_32.DISP_CHANGE_RESTART: 
                                    { 
                                        return "You Need To Reboot For The Change To Happen.\n If You Feel Any Problem After Rebooting Your Machine\nThen Try To Change Resolution In Safe Mode."; 
                                    } 
                                default: 
                                    { 
                                        return "Failed To Change The Resolution"; 
                                    } 
                            } 
                        } 
                    } 
                    else 
                    { 
                        return "Failed To Change The Resolution."; 
                    } 
                } 
                else 
                { 
                    return "Failed To Get Monitor Device From MonitorNo"; 
                } 
            } 
            private static DEVMODE1 GetDevMode1() 
            { 
                DEVMODE1 dm = new DEVMODE1(); 
                dm.dmDeviceName = new String(new char[32]); 
                dm.dmFormName = new String(new char[32]); 
                dm.dmSize = (short)Marshal.SizeOf(dm); 
                return dm; 
            }
            private static DISPLAY_DEVICE GetDisplayDevice() 
            { 
                DISPLAY_DEVICE dv = new DISPLAY_DEVICE(); 
                dv.DeviceName = new String(new char[32]); 
                dv.DeviceString = new String(new char[128]); 
                dv.DeviceID = new String(new char[128]); 
                dv.DeviceKey = new String(new char[128]); 
                dv.cb = (int)Marshal.SizeOf(dv); 
                dv.StateFlags = 1; 
                return dv; 
            } 
        } 
    } 
    "@ 
    Add-Type $pinvokeCode -ErrorAction SilentlyContinue 
    [Resolution.ScreenResolution]::ChangeResolution($no,$width,$height,$frequency) 
    }
    