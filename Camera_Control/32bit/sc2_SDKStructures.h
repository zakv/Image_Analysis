//-----------------------------------------------------------------//
// Name        | sc2_structures.h            | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | SC2                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | INTEL PC                                          //
//-----------------------------------------------------------------//
// Environment | Microsoft Visual C++ 6.0                          //
//-----------------------------------------------------------------//
// Purpose     | SC2 - Structure defines                           //
//-----------------------------------------------------------------//
// Author      |  FRE, PCO AG                                      //
//-----------------------------------------------------------------//
// Revision    |  rev. 1.06 rel. 1.06                              //
//-----------------------------------------------------------------//
// Notes       | Rev 0.01 covers six! groups of structures and the //
//             | famous camera descriptor:                         //
//             | 1. General control group.                         //
//             | 2. Sensor control group.                          //
//             | 3. Timing control group.                          //
//             | 4. Storage control group.                         //
//             | 5. Recording control group.                       //
//             | 6. Image read group.                              //
//             | Each data entry in the structure will be defined  //
//             | in the way as they are defined on the Firmware.   //
//             |                                                   //
//             | Rev 0.02: Added an API sruct which handles some   //
//             | info about the device, allocated within PnP and   //
//             | holds some flags and function ptrs.               //
//             |                                                   //
//             | Rev 0.03: Added ROI Granularity and               //
//             | Delay, Exposure Step to the camera descriptor.    //
//             |                                                   //
//             | See pco.camera SDK manual for further information.//
//-----------------------------------------------------------------//
// Attention!! | Attention!! If these structures are released to   //
//             | market in any form, the position of each data     //
//             | entry must not be moved any longer! Enhancements  //
//             | can be done by exploiting the dummy entries and   //
//             | dummy fields.                                     //
//-----------------------------------------------------------------//
// (c) 2002 PCO AG * Donaupark 11 *                                //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
// Revision History:                                               //
//-----------------------------------------------------------------//
// Rev.:     | Date:      | Changed:                               //
// --------- | ---------- | ---------------------------------------//
//  0.01     | 15.05.2003 |  FRE/new file                          //
//-----------------------------------------------------------------//
//  0.02     | 28.05.2003 |  FRE/ upd. some elements, added APIMgm.//
//-----------------------------------------------------------------//
//  0.03     | 05.11.2003 |  FRE/ add. some elements               //
//-----------------------------------------------------------------//
//  0.14     | 09.01.2004 |  FRE/ add. hw-fwversion                //
//-----------------------------------------------------------------//
//  0.16     | 23.03.2004 |  Removed single entries for dwDelay    //
//           |            |  and dwExposure, now they are part of  //
//           |            |  the delay/exposure table, FRE         //
//-----------------------------------------------------------------//
//  1.00     | 04.05.2004 |  Released to market.                   //
//           |            |                                        //
//-----------------------------------------------------------------//
//  1.01     | 04.06.2004 |  FRE/ add. FPS exposure mode.          //
//           |            |                                        //
//-----------------------------------------------------------------//
//  1.02     | 04.06.2004 |  FRE/ add. changes due to explicit     //
//           |            |            linking. added camlink.     //
//-----------------------------------------------------------------//
//  1.03     | 17.12.2004 |  FRE/ add. PCO_OpenCameraEx and struct //
//           |            |  adapted, inserted CL_SER              //
//           | 22.02.2005 |  FRE/ added dwImageSize @ bufferstruct //
//-----------------------------------------------------------------//
//  1.04     | 21.04.2005 |  Added Noisefilter, removed HW-Desc,   //
//           |            |  FRE                                   //
//           | 02.06.2005 |  MBL IF National Instruments inserted  //
//-----------------------------------------------------------------//
//  1.05     | 27.02.2006 |  Added PCO_GetCameraName, FRE          //
//           |            |  Added PCO_xxxHotPixelxxx, FRE         //
//-----------------------------------------------------------------//
//  1.06     | 02.06.2006 |  Added PCO_GetCameraDescriptionEx, FRE //
//           |            |  Added PCO_xxxModulationMode, FRE      //
//           |            |  Added PCO_WaitforBuffer, FRE          //
//-----------------------------------------------------------------//
//  1.07     | 24.10.2006 |  Added Hasotech, FRE                   //
//-----------------------------------------------------------------//
//  1.08     | 14.10.2007 |  Removed Hasotech, FRE                 //
//-----------------------------------------------------------------//
//  1.09     | 05.12.2007 |  Added GigE, FRE                       //
//           | 02.04.2007 |  Added USB, FRE                        //
//           | 17.04.2008 |  Minor corrections, FRE                //
//           | 28.05.2008 |  Reviewed structure alignment and      //
//           |            |  some additional dummy words, FRE      //
//-----------------------------------------------------------------//
//  1.10     | 05.03.2009 |  FRE: Added Get/SetFrameRate           //
//           |            |  Added HW IO functions and desc.       //
//-----------------------------------------------------------------//

// The wZZAlignDummies are only used in order to reflect the compiler output.
// Default setting of the MS-VC-compiler is 8 byte alignment!!
// Despite the default setting of 8 byte the MS compiler falls back to the biggest member, e.g.
// in case the biggest member in a struct is a DWORD, all members will be aligned to 4 bytes and
// not to default of 8.

#if !defined  SC2_STRUCTURES_H
#define SC2_STRUCTURES_H

// Defines: 
// WORD: 16bit unsigned
// SHORT: 16bit signed
// DWORD: 32bit unsigned

#define PCO_STRUCTREV      102         // set this value to wStructRev

#define PCO_BUFCNT 16                   // see PCO_API struct
#define PCO_MAXDELEXPTABLE 16          // see PCO_Timing struct
#define PCO_RAMSEGCNT 4                // see PCO_Storage struct
#define PCO_MAXVERSIONHW   10
#define PCO_MAXVERSIONFW   10


#define PCO_ARM_COMMAND_TIMEOUT 10000
#define PCO_HPX_COMMAND_TIMEOUT 10000
#define PCO_COMMAND_TIMEOUT       400

// SDK-Dll internal defines (different to interface type in sc2_defs.h!!!
// In case you're going to enumerate interface types, please refer to sc2_defs.h.
#define PCO_INTERFACE_FW     1         // Firewire interface
#define PCO_INTERFACE_CL_MTX 2         // Cameralink Matrox Solios / Helios
#define PCO_INTERFACE_CL_ME3 3         // Cameralink Silicon Software Me3
#define PCO_INTERFACE_CL_NAT 4         // Cameralink National Instruments
#define PCO_INTERFACE_GIGE   5         // Gigabit Ethernet
#define PCO_INTERFACE_USB    6         // USB 2.0
#define PCO_INTERFACE_CL_ME4 7         // Cameralink Silicon Software Me4

#define PCO_LASTINTERFACE PCO_INTERFACE_CL_ME4

#define PCO_INTERFACE_CL_SER 10
#define PCO_INTERFACE_GENERIC 20

#define PCO_OPENFLAG_GENERIC_IS_CAMLINK  0x0001

typedef struct                         // Buffer list structure for  PCO_WaitforBuffer
{
 short sBufNr;
 unsigned short ZZwAlignDummy;
 unsigned long  dwStatusDll;
 unsigned long  dwStatusDrv;                    // 12
}PCO_Buflist;

typedef struct
{
  unsigned short  wSize;                 // Sizeof this struct
  unsigned short  wInterfaceType;        // 1: Firewire, 2: CamLink with Matrox, 3: CamLink with Silicon SW
  unsigned short  wCameraNumber;
  unsigned short  wCameraNumAtInterface; // Current number of camera at the interface
  unsigned short  wOpenFlags[10];        // [0]: moved to dwnext to position 0xFF00
                                         // [1]: moved to dwnext to position 0xFFFF0000
                                         // [2]: Bit0: PCO_OPENFLAG_GENERIC_IS_CAMLINK
                                         //            Set this bit in case of a generic Cameralink interface
                                         //            This enables the import of the additional three camera-
                                         //            link interface functions.

  unsigned long   dwOpenFlags[5];        // [0]-[4]: moved to strCLOpen.dummy[0]-[4]
  void*           wOpenPtr[6];
  unsigned short  zzwDummy[8];           // 88 - 64bit: 112
}PCO_OpenStruct;

typedef struct
{
  char            szName[16];      // string with board name
  unsigned short  wBatchNo;        // production batch no
  unsigned short  wRevision;       // use range 0 to 99
  unsigned short  wVariant;        // variant    // 22
  unsigned short  ZZwDummy[20];    //            // 62
}
PCO_SC2_Hardware_DESC;

typedef struct
{
  char            szName[16];      // string with device name
  unsigned char   bMinorRev;       // use range 0 to 99
  unsigned char   bMajorRev;       // use range 0 to 255
  unsigned short  wVariant;        // variant    // 20
  unsigned short  ZZwDummy[22];    //            // 64
}
PCO_SC2_Firmware_DESC;

typedef struct
{
  unsigned short        BoardNum;       // number of devices
  PCO_SC2_Hardware_DESC Board[PCO_MAXVERSIONHW];// 622
}
PCO_HW_Vers;

typedef struct
{
  unsigned short        DeviceNum;       // number of devices
  PCO_SC2_Firmware_DESC Device[PCO_MAXVERSIONFW];// 642
}
PCO_FW_Vers;

typedef struct
{ 
  unsigned short     wSize;                   // Sizeof this struct
  unsigned short     wCamType;                // Camera type
  unsigned short     wCamSubType;             // Camera sub type
  unsigned short     ZZwAlignDummy1; 
  unsigned int       dwSerialNumber;          // Serial number of camera
  unsigned int       dwHWVersion;             // Hardware version number
  unsigned int       dwFWVersion;             // Firmware version number
  unsigned short     wInterfaceType;          // Interface type
  unsigned short     wHWnum;                  // number of devices
  unsigned char      strHardwareVersion[616]; // Hardware versions of all boards
//  unsigned short     wDevnum;                 // number of devices
  unsigned char      strFirmwareVersion[640]; // Firmware versions of all devices
  unsigned char      MatlabDummy[6];
  unsigned short     ZZwDummy[39];
} PCO_CameraType;

typedef struct
{
  unsigned short      wSize;                   // Sizeof this struct
  unsigned short      ZZwAlignDummy1;
  PCO_CameraType      strCamType;           // previous described structure // 1368
  unsigned long       dwCamHealthWarnings;     // Warnings in camera system
  unsigned long       dwCamHealthErrors;       // Errors in camera system
  unsigned long       dwCamHealthStatus;       // Status of camera system      // 1380
  short               sCCDTemperature;         // CCD temperature
  short               sCamTemperature;         // Camera temperature           // 1384
  short               sPowerSupplyTemperature; // Power device temperature
  unsigned short      ZZwDummy[37];                                            // 1460
} PCO_General;

typedef struct
{
  unsigned short      wSize;                   // Sizeof this struct
  unsigned short      wSensorTypeDESC;         // Sensor type
  unsigned short      wSensorSubTypeDESC;      // Sensor subtype
  unsigned short      wMaxHorzResStdDESC;      // Maxmimum horz. resolution in std.mode
  unsigned short      wMaxVertResStdDESC;      // Maxmimum vert. resolution in std.mode // 10
  unsigned short      wMaxHorzResExtDESC;      // Maxmimum horz. resolution in ext.mode
  unsigned short      wMaxVertResExtDESC;      // Maxmimum vert. resolution in ext.mode
  unsigned short      wDynResDESC;             // Dynamic resolution of ADC in bit
  unsigned short      wMaxBinHorzDESC;         // Maxmimum horz. binning
  unsigned short      wBinHorzSteppingDESC;    // Horz. bin. stepping (0:bin, 1:lin)    // 20
  unsigned short      wMaxBinVertDESC;         // Maxmimum vert. binning
  unsigned short      wBinVertSteppingDESC;    // Vert. bin. stepping (0:bin, 1:lin)
  unsigned short      wRoiHorStepsDESC;        // Minimum granularity of ROI in pixels
  unsigned short      wRoiVertStepsDESC;       // Minimum granularity of ROI in pixels
  unsigned short      wNumADCsDESC;            // Number of ADCs in system              // 30
  unsigned short      ZZwAlignDummy1;
  unsigned long       dwPixelRateDESC[4];      // Possible pixelrate in Hz              // 48
  unsigned long       ZZdwDummypr[20];                                                  // 128
  unsigned short      wConvFactDESC[4];        // Possible conversion factor in e/cnt   // 136
  unsigned short      ZZdwDummycv[20];                                                  // 176
  unsigned short      wIRDESC;                 // IR enhancment possibility
  unsigned short      ZZwAlignDummy2;
  unsigned long       dwMinDelayDESC;          // Minimum delay time in ns
  unsigned long       dwMaxDelayDESC;          // Maximum delay time in ms
  unsigned long       dwMinDelayStepDESC;      // Minimum stepping of delay time in ns  // 192
  unsigned long       dwMinExposureDESC;       // Minimum exposure time in ns
  unsigned long       dwMaxExposureDESC;       // Maximum exposure time in ms           // 200
  unsigned long       dwMinExposureStepDESC;   // Minimum stepping of exposure time in ns
  unsigned long       dwMinDelayIRDESC;        // Minimum delay time in ns
  unsigned long       dwMaxDelayIRDESC;        // Maximum delay time in ms              // 212
  unsigned long       dwMinExposureIRDESC;     // Minimum exposure time in ns
  unsigned long       dwMaxExposureIRDESC;     // Maximum exposure time in ms           // 220
  unsigned short      wTimeTableDESC;          // Timetable for exp/del possibility
  unsigned short      wDoubleImageDESC;        // Double image mode possibility
  short               sMinCoolSetDESC;         // Minimum value for cooling
  short               sMaxCoolSetDESC;         // Maximum value for cooling
  short               sDefaultCoolSetDESC;     // Default value for cooling             // 230
  unsigned short      wPowerDownModeDESC;      // Power down mode possibility
  unsigned short      wOffsetRegulationDESC;   // Offset regulation possibility
  unsigned short      wColorPatternDESC;       // Color pattern of color chip
                                       // four nibbles (0,1,2,3) in word 
                                       //  ----------------- 
                                       //  | 3 | 2 | 1 | 0 |
                                       //  ----------------- 
                                       //   
                                       // describe row,column  2,2 2,1 1,2 1,1
                                       // 
                                       //   column1 column2
                                       //  ----------------- 
                                       //  |       |       |
                                       //  |   0   |   1   |   row1
                                       //  |       |       |
                                       //  -----------------
                                       //  |       |       |
                                       //  |   2   |   3   |   row2
                                       //  |       |       |
                                       //  -----------------
                                       // 
  unsigned short      wPatternTypeDESC;        // Pattern type of color chip
                                       // 0: Bayer pattern RGB
                                       // 1: Bayer pattern CMY
  unsigned short      wDummy1;                 // former DSNU correction mode             // 240
  unsigned short      wDummy2;                 //
  unsigned short      ZZwAlignDummy3;          //
  unsigned long       dwGeneralCapsDESC1;      // General capabilities:
                                       // Bit 0: Noisefilter available
                                       // Bit 1: Hotpixelfilter available
                                       // Bit 2: Hotpixel works only with noisefilter
                                       // Bit 3: Timestamp ASCII only available (Timestamp mode 3 enabled)

                                       // Bit 4: Dataformat 2x12
                                       // Bit 5: Record Stop Event available
                                       // Bit 6: Hot Pixel correction
                                       // Bit 7: Ext.Exp.Ctrl. not available

                                       // Bit 8: Timestamp not available
                                       // Bit 9: Acquire mode not available
                                       // Bit10: Dataformat 4x16
                                       // Bit11: Dataformat 5x16

                                       // Bit12: Camera has no internal recorder memory
                                       // Bit13: Camera can be set to fast timing mode (PIV)
                                       // Bit14: Camera can produce metadata
                                       // Bit15: Camera allows Set/GetFrameRate cmd

                                       // Bit16: Camera has Correlated Double Image Mode
                                       // Bit17: Camera has CCM
                                       // Bit18: // Bit19: 
                                        
                                       // Bit20: // Bit21: // Bit22: // Bit23: 
                                       // Bit24: // Bit25: // Bit26: // Bit27:
                                       // Bit28: reserved for future desc.// Bit29:  reserved for future desc.

                                       // Bit 30: HW_IO_SIGNAL_DESCRIPTOR available
                                       // Bit 31: Enhanced descriptor available

  unsigned long       dwGeneralCapsDESC2;      // General capabilities 2                  // 252
  unsigned long       dwExtSyncFrequency[2];   // lists two frequencies for external sync feature
  unsigned long       dwReservedDESC[4];       // 32bit dummy                             // 276
  unsigned long       ZZdwDummy[40];                                                      // 436
} PCO_Description;

typedef struct
{
  unsigned short      wSize;                   // Sizeof this struct
  unsigned short      ZZwAlignDummy1;
  unsigned long       dwMinPeriodicalTimeDESC2;// Minimum periodical time tp in (nsec)
  unsigned long       dwMaxPeriodicalTimeDESC2;// Maximum periodical time tp in (msec)        (12)
  unsigned long       dwMinPeriodicalConditionDESC2;// System imanent condition in (nsec)
                                       // tp - (td + te) must be equal or longer than
                                       // dwMinPeriodicalCondition
  unsigned long       dwMaxNumberOfExposuresDESC2;// Maximum number of exporures possible        (20)
  long                lMinMonitorSignalOffsetDESC2;// Minimum monitor signal offset tm in (nsec)
                                       // if(td + tstd) > dwMinMon.)
                                       //   tm must not be longer than dwMinMon
                                       // else
                                       //   tm must not be longer than td + tstd
  unsigned long       dwMaxMonitorSignalOffsetDESC2;// Maximum -''- in (nsec)                      
  unsigned long       dwMinPeriodicalStepDESC2;// Minimum step for periodical time in (nsec)  (32)
  unsigned long       dwStartTimeDelayDESC2;   // Minimum monitor signal offset tstd in (nsec)
                                       // see condition at dwMinMonitorSignalOffset
  unsigned long       dwMinMonitorStepDESC2;   // Minimum step for monitor time in (nsec)     (40)
  unsigned long       dwMinDelayModDESC2;      // Minimum delay time for modulate mode in (nsec)
  unsigned long       dwMaxDelayModDESC2;      // Maximum delay time for modulate mode in (msec)
  unsigned long       dwMinDelayStepModDESC2;  // Minimum delay time step for modulate mode in (nsec)(52)
  unsigned long       dwMinExposureModDESC2;   // Minimum exposure time for modulate mode in (nsec)
  unsigned long       dwMaxExposureModDESC2;   // Maximum exposure time for modulate mode in (msec)(60)
  unsigned long       dwMinExposureStepModDESC2;// Minimum exposure time step for modulate mode in (nsec)
  unsigned long       dwModulateCapsDESC2;     // Modulate capabilities descriptor
  unsigned long       dwReserved[16];                                                         //(132)
  unsigned long       ZZdwDummy[41];                                                          // 296
} PCO_Description2;

typedef struct
{
  unsigned short      wSize;                   // Sizeof this struct
} PCO_DescriptionEx;


// Hardware IO Signals definition
// SIGNAL options definitions (up to 16 different defines)
#define SIGNAL_DEF_ENABLE   0x00000001 // Signal can be enabled/disabled
#define SIGNAL_DEF_OUTPUT   0x00000002 // Signal is a status signal (output)
#define SIGNAL_DEF_MASK     0x000000FF // Signal options mask

// SIGNAL Type definitions (up to 16 different types)
#define SIGNAL_TYPE_TTL     0x00000001 // Signal can be switched to TTL level
                                       // (0V to 0.8V, 2V to VCC, VCC is 4.75V to 5.25V)
#define SIGNAL_TYPE_HL_SIG  0x00000002 // Signal can be switched to high level signal
                                       // (0V to 5V, 10V to VCC, VCC is 56V)
#define SIGNAL_TYPE_CONTACT 0x00000004 // Signal can be switched to contact level
#define SIGNAL_TYPE_RS485   0x00000008 // Signal can be switched to RS485 level
#define SIGNAL_TYPE_MASK    0x0000FFFF // Signal type mask

// SIGNAL Polarity definitions (up to 16 different types)
#define SIGNAL_POL_HIGH     0x00000001 // Signal can be switched to sense low level
#define SIGNAL_POL_LOW      0x00000002 // Signal can be switched to sense high level
#define SIGNAL_POL_RISE     0x00000004 // Signal can be switched to sense rising edge
#define SIGNAL_POL_FALL     0x00000008 // Signal can be switched to sense falling edge
#define SIGNAL_POL_MASK     0x0000FFFF // Signal polarity mask

// SIGNAL Filter settings definitions (up to 16 different filter)
#define SIGNAL_FILTER_OFF   0x00000001 // Filter can be switched off (t > ~65ns)
#define SIGNAL_FILTER_MED   0x00000002 // Filter can be switched to medium (t > 1us)
#define SIGNAL_FILTER_HIGH  0x00000004 // Signal can be switched to high (t > 100ms)
#define SIGNAL_FILTER_MASK  0x0000FFFF // Signal polarity mask


#define NUM_MAX_SIGNALS     20         // Maximum number of signals available

typedef struct
{
  unsigned short wSize;                         // Sizeof ‘this’ (for future enhancements)
  unsigned short ZZwAlignDummy1;
  char           strSignalName0[25];          // Name of signal 104
  char           strSignalName1[25];          // Name of signal 104
  char           strSignalName2[25];          // Name of signal 104
  char           strSignalName3[25];          // Name of signal 104
  unsigned short wSignalDefinitions;             // Flags showing signal options
                                       // 0x01: Signal can be enabled/disabled
                                       // 0x02: Signal is a status (output)
                                       // Rest: future use, set to zero!
  unsigned short wSignalTypes;                   // Flags showing the selectability of signal types
                                       // 0x01: TTL
                                       // 0x02: High Level TTL
                                       // 0x04: Contact Mode
                                       // 0x08: RS485 diff.
                                       // Rest: future use, set to zero!
  unsigned short wSignalPolarity;                // Flags showing the selectability
                                       // of signal levels/transitions
                                       // 0x01: Low Level active
                                       // 0x02: High Level active
                                       // 0x04: Rising edge active
                                       // 0x08: Falling edge active
                                       // Rest: future use, set to zero!
  unsigned short wSignalFilter;                  // Flags showing the selectability of filter
                                       // settings
                                       // 0x01: Filter can be switched off (t > ~65ns)
                                       // 0x02: Filter can be switched to medium (t > ~1us)
                                       // 0x04: Filter can be switched to high (t > ~100ms) 112
  unsigned long  dwDummy[22];                   // reserved for future use. (only in SDK) 200
}PCO_Single_Signal_Desc;

typedef struct
{
  unsigned short         wSize;             // Sizeof ‘this’ (for future enhancements)
  unsigned short         wNumOfSignals;     // Parameter to fetch the num. of descr. from the camera
  PCO_Single_Signal_Desc strSingeSignalDesc[NUM_MAX_SIGNALS];// Array of singel signal descriptors // 4004
  unsigned long          dwDummy[524];      // reserved for future use.    // 6100
} PCO_Signal_Description;

#define PCO_SENSORDUMMY 7
typedef struct
{
  unsigned short         wSize;                   // Sizeof this struct
  unsigned short         ZZwAlignDummy1;
  PCO_Description        strDescription;      // previous described structure // 440
  PCO_Description2       strDescription2;    // second descriptor            // 736
  unsigned long          ZZdwDummy2[256];         //                              // 1760
  unsigned short         wSensorformat;           // Sensor format std/ext
  unsigned short         wRoiX0;                  // Roi upper left x
  unsigned short         wRoiY0;                  // Roi upper left y
  unsigned short         wRoiX1;                  // Roi lower right x
  unsigned short         wRoiY1;                  // Roi lower right y            // 1770
  unsigned short         wBinHorz;                // Horizontal binning
  unsigned short         wBinVert;                // Vertical binning
  unsigned short         ZZwAlignDummy2;
  unsigned long          dwPixelRate;             // 32bit unsigend, Pixelrate in Hz: // 1780
                                       // depends on descriptor values
  unsigned short         wConvFact;               // Conversion factor:
                                       // depends on descriptor values
  unsigned short         wDoubleImage;            // Double image mode
  unsigned short         wADCOperation;           // Number of ADCs to use
  unsigned short         wIR;                     // IR sensitivity mode
  short                  sCoolSet;                // Cooling setpoint             // 1790
  unsigned short         wOffsetRegulation;       // Offset regulation mode       // 1792
  unsigned short         wNoiseFilterMode;        // Noise filter mode
  unsigned short         wFastReadoutMode;        // Fast readout mode for dimax
  unsigned short         wDSNUAdjustMode;         // DSNU Adjustment mode
  unsigned short         wCDIMode;                // Correlated double image mode // 1800
  unsigned short         ZZwDummy[36];                                            // 1872
  PCO_Signal_Description strSignalDesc;// Signal descriptor            // 7972
  unsigned long          ZZdwDummy[PCO_SENSORDUMMY];                              // 8000
} PCO_Sensor;

typedef struct
{
  unsigned short   wSize;                         // Sizeof this struct
  unsigned short   wSignalNum;                    // Index for strSignal
  unsigned short   wEnabled;                      // Flag shows enable state of the signal (0: off, 1: on)
  unsigned short   wType;                         // Selected signal type
  unsigned short   wPolarity;                     // Selected signal polarity
  unsigned short   wFilterSetting;                // Selected signal filter // 12
  unsigned short   wSelected;                     // Select signal (0: standard signal, >1 other signal)
  unsigned short   ZZwReserved;
  unsigned long    ZZdwReserved[11];              // 60
} PCO_Signal;

typedef struct
{
  unsigned short   wSize;
  unsigned short   wDummy;
  unsigned long    FrameTime_ns;                 // Frametime replaces COC_Runtime
  unsigned long    FrameTime_s;   
  unsigned long    ExposureTime_ns;
  unsigned long    ExposureTime_s;               // 5
  unsigned long    TriggerSystemDelay_ns;        // System internal min. trigger delay
  unsigned long    TriggerSystemJitter_ns;       // Max. possible trigger jitter -0/+ ... ns
  unsigned long    TriggerDelay_ns;              // Resulting trigger delay = system delay
  unsigned long    TriggerDelay_s;               // + delay of SetDelayExposureTime ... // 9
  unsigned long    ZZdwDummy[11];                // 20
} PCO_ImageTiming;


#define PCO_TIMINGDUMMY 24
typedef struct
{
  unsigned short        wSize;                   // Sizeof this struct
  unsigned short        wTimeBaseDelay;          // Timebase delay 0:ns, 1:µs, 2:ms
  unsigned short        wTimeBaseExposure;       // Timebase expos 0:ns, 1:µs, 2:ms
  unsigned short        ZZwAlignDummy1;                                             // 8
  unsigned long         ZZdwDummy0[2];           // removed single entry for dwDelay and dwExposure // 16
  unsigned long         dwDelayTable[PCO_MAXDELEXPTABLE];// Delay table             // 80
  unsigned long         ZZdwDummy1[114];                                            // 536
  unsigned long         dwExposureTable[PCO_MAXDELEXPTABLE];// Exposure table       // 600
  unsigned long         ZZdwDummy2[112];                                            // 1048
  unsigned short        wTriggerMode;            // Trigger mode                    // 1050
                                       // 0: auto, 1: software trg, 2:extern 3: extern exp. ctrl
  unsigned short        wForceTrigger;           // Force trigger (Auto reset flag!)
  unsigned short        wCameraBusyStatus;       // Camera busy status 0: idle, 1: busy
  unsigned short        wPowerDownMode;          // Power down mode 0: auto, 1: user // 1056
  unsigned long         dwPowerDownTime;         // Power down time 0ms...49,7d     // 1060
  unsigned short        wExpTrgSignal;           // Exposure trigger signal status
  unsigned short        wFPSExposureMode;        // Cmos-Sensor FPS exposure mode
  unsigned long         dwFPSExposureTime;       // Resulting exposure time in FPS mode // 1068

  unsigned short        wModulationMode;         // Mode for modulation (0 = modulation off, 1 = modulation on) // 1070
  unsigned short        wCameraSynchMode;        // Camera synchronisation mode (0 = off, 1 = master, 2 = slave)
  unsigned long         dwPeriodicalTime;        // Periodical time (unit depending on timebase) for modulation // 1076
  unsigned short        wTimeBasePeriodical;     // timebase for periodical time for modulation  0 -> ns, 1 -> µs, 2 -> ms
  unsigned short        ZZwAlignDummy3;
  unsigned long         dwNumberOfExposures;     // Number of exposures during modulation // 1084
  long                  lMonitorOffset;          // Monitor offset value in ns      // 1088
  PCO_Signal            strSignal[NUM_MAX_SIGNALS];// Signal settings               // 2288
  unsigned short        wStatusFrameRate;        // Framerate status
  unsigned short        wFrameRateMode;          // Dimax: Mode for frame rate
  unsigned long         dwFrameRate;             // Dimax: Framerate in mHz
  unsigned long         dwFrameRateExposure;     // Dimax: Exposure time in ns      // 2300
  unsigned short        wTimingControlMode;      // Dimax: Timing Control Mode: 0->Exp./Del. 1->FPS
  unsigned short        wFastTimingMode;         // Dimax: Fast Timing Mode: 0->off 1->on
  unsigned short        ZZwDummy[PCO_TIMINGDUMMY];                                               // 2352
} PCO_Timing;

#define PCO_STORAGEDUMMY 39
typedef struct
{
  unsigned short        wSize;                   // Sizeof this struct
  unsigned short        ZZwAlignDummy1;
  unsigned long         dwRamSize;               // Size of camera ram in pages
  unsigned short        wPageSize;               // Size of one page in pixel       // 10
  unsigned short        ZZwAlignDummy4;
  unsigned long         dwRamSegSize[PCO_RAMSEGCNT];// Size of ram segment 1-4 in pages // 28
  unsigned long         ZZdwDummyrs[20];                                            // 108
  unsigned short        wActSeg;                 // no. (0 .. 3) of active segment  // 110
  unsigned short        ZZwDummy[PCO_STORAGEDUMMY];                                 // 188
} PCO_Storage;

#define PCO_RECORDINGDUMMY 33
typedef struct
{
  unsigned short        wSize;                   // Sizeof this struct
  unsigned short        wStorageMode;            // 0 = recorder, 1 = fifo
  unsigned short        wRecSubmode;             // 0 = sequence, 1 = ringbuffer
  unsigned short        wRecState;               // 0 = off, 1 = on
  unsigned short        wAcquMode;               // 0 = internal auto, 1 = external // 10
  unsigned short        wAcquEnableStatus;       // 0 = Acq disabled, 1 = enabled
  unsigned char         ucDay;                   // MSB...LSB: day, month, year; 21.March 2003: 0x150307D3
  unsigned char         ucMonth;                                                    // 14
  unsigned short        wYear;
  unsigned short        wHour;
  unsigned char         ucMin;
  unsigned char         ucSec;                   // MSB...LSB: h, min, s; 17:05:32 : 0x00110520 // 20
  unsigned short        wTimeStampMode;          // 0: no stamp, 1: stamp in first 14 pixel, 2: stamp+ASCII
  unsigned short        wRecordStopEventMode;    // 0: no stop event recording, 1: recording stops with event
  unsigned long         dwRecordStopDelayImages; // Number of images which should pass by till stop event rises. // 28
  unsigned short        wMetaDataMode;           // Metadata mode 0: off, 1: meta data will be added to image data
  unsigned short        wMetaDataSize;           // Size of metadata
  unsigned short        wMetaDataVersion;        // Version info for metadata
  unsigned short        ZZwDummy[PCO_RECORDINGDUMMY];                                               // 100
} PCO_Recording;

typedef struct
{
  unsigned short        wSize;                   // Sizeof this struct
  unsigned short        wXRes;                   // Res. h. = resulting horz.res.(sensor resolution, ROI, binning)
  unsigned short        wYRes;                   // Res. v. = resulting vert.res.(sensor resolution, ROI, binning)
  unsigned short        wBinHorz;                // Horizontal binning
  unsigned short        wBinVert;                // Vertical binning                // 10
  unsigned short        wRoiX0;                  // Roi upper left x
  unsigned short        wRoiY0;                  // Roi upper left y
  unsigned short        wRoiX1;                  // Roi lower right x
  unsigned short        wRoiY1;                  // Roi lower right y
  unsigned short        ZZwAlignDummy1;                                             // 20
  unsigned long         dwValidImageCnt;         // no. of valid images in segment
  unsigned long         dwMaxImageCnt;           // maximum no. of images in segment // 28
  unsigned short        ZZwDummy[40];                                               // 108
} PCO_Segment;

typedef struct
{
  unsigned short        wSize;                     // Sizeof this struct
  unsigned short        ZZwAlignDummy1;                                             // 4
  PCO_Segment           strSegment[PCO_RAMSEGCNT]; // Segment info                  // 436
  PCO_Segment           ZZstrDummySeg[16];         // Segment info dummy            // 2164
  unsigned short        wBitAlignment;             // Bitalignment during readout. 0: MSB, 1: LSB aligned
  unsigned short        wHotPixelCorrectionMode;   // Correction mode for hotpixel
  unsigned short        ZZwDummy[38];                                               // 2244
} PCO_Image;

#define PCO_BUFFER_STATICS   0xFFFF0000  // Mask for all static flags
// Static flags:
#define PCO_BUFFER_ALLOCATED 0x80000000  // A buffer is allocated
#define PCO_BUFFER_EVENTDLL  0x40000000  // An event is allocated
#define PCO_BUFFER_ISEXTERN  0x20000000  // The buffer was allocated externally
#define PCO_BUFFER_EVAUTORES 0x10000000  // Set this flag to do an 'auto reset' of the
                                         // event, in case you call WaitForBuffer
// Dynamic flags:
#define PCO_BUFFER_EVENTSET  0x00008000  // The event of the buffer is set
// Informations about buffer status flags:
// 00000000 00000000 00000000 00000000
// |||||||| |||||||| |||||||| ||||||||
// ||||              |
// ||||              -------------------- Buffer event is set to signaled
// ||||
// |||----------------------------------- Signaled Buffer event will be reset in WaitForBuffer
// ||------------------------------------ Buffer allocated externally
// |------------------------------------- Buffer event handle created inside DLL
// -------------------------------------- Buffer allocated

typedef struct
{
  unsigned short          wSize;                   // Sizeof this struct
  unsigned short          ZZwAlignDummy1;
  unsigned long           dwBufferStatus;          // Buffer status
  void*                   hBufferEvent;            // Handle to buffer event  // 12 (16 @64bit)
  // HANDLE will be 8byte on 64bit OS and 4byte on 32bit OS. 
  unsigned long           ZZdwBufferAddress;       // Buffer address, obsolete
  unsigned long           dwBufferSize;            // Buffer size             // 20 (24 @64bit)
  unsigned long           dwDrvBufferStatus;       // Buffer status in driver
  unsigned long           dwImageSize;             // Image size              // 28 (32 @64bit)
  void                    *pBufferAdress;          // buffer address          // 32 (40 @64bit)
#if !defined _WIN64
  unsigned long           ZZdwDummyFill;           // additional dword        // 36 (40 @64bit)
#endif
  unsigned short          ZZwDummy[32];                                       // 100 (104 @64bit)
} PCO_APIBuffer;


#define TAKENFLAG_TAKEN       0x0001   // Device is taken by an application
#define TAKENFLAG_DEADHANDLE  0x0002   // The handle of this device is invalid because of a camera power down
                                       // or another device removal
#define TAKENFLAG_HANDLEVALID 0x0004   // The handle of this device is valid. Changed accoring to DEADHANDLE flag.

typedef struct
{
  unsigned short          wSize;                 // Sizeof this struct
  unsigned short          wCameraNum;            // Current number of camera
  void*                   hCamera;               // Handle of the device
  unsigned short          wTakenFlag;            // Flags to show whether the device is taken or not. // 10
  unsigned short          ZZwAlignDummy1;                                                             // 12
  void*                   pSC2IFFunc[20];                                                            // 92
  PCO_APIBuffer           strPCOBuf[PCO_BUFCNT]; // Bufferlist                                        // 892
  PCO_APIBuffer           ZZstrDummyBuf[12];     // Bufferlist                                        // 2892
  short                   sBufferCnt;            // Index for buffer allocation
  unsigned short          wCameraNumAtInterface; // Current number of camera at the interface
  unsigned short          wInterface;            // Interface type (used before connecting to camera)
                                       // different from PCO_CameraType (!)
  unsigned short          wXRes;                 // X Resolution in Grabber (CamLink only)            // 2900
  unsigned short          wYRes;                 // Y Resolution in Buffer (CamLink only)             // 2902
  unsigned short          ZZwAlignDummy2;
  unsigned long           dwIF_param[5];         // Interface specific parameter                      // 2924
                                       // 0 (FW:bandwidth or CL:baudrate ) 
                                       // 1 (FW:speed     or CL:clkfreq  ) 
                                       // 2 (FW:channel   or CL:ccline   ) 
                                       // 3 (FW:buffer    or CL:data     ) 
                                       // 4 (FW:iso_bytes or CL:transmit ) 
  unsigned short          ZZwDummy[26];                                                               // 2976
} PCO_APIManagement;

typedef struct
{
  unsigned short          wSize;             // Sizeof this struct
  unsigned short          wStructRev;        // internal parameter, must be set to PCO_STRUCTDEF
  PCO_General             strGeneral;
  PCO_Sensor              strSensor;
  PCO_Timing              strTiming;
  PCO_Storage             strStorage;
  PCO_Recording           strRecording;
  PCO_Image               strImage;
  PCO_APIManagement       strAPIManager;
  unsigned short          ZZwDummy[40];
} PCO_Camera;                          // 17404

#endif // SC2_STRUCTURES_H
