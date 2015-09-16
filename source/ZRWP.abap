*&---------------------------------------------------------------------*
*& Report ZRWP
*&---------------------------------------------------------------------*
*& Author: João Antônio Soares
*&---------------------------------------------------------------------*

REPORT ZRWP.

*&---------------------------------------------------------------------*
*& Data definition
*&---------------------------------------------------------------------*

DATA: BEGIN OF tasklist OCCURS 0,
        line(255) TYPE c,
      END OF tasklist,

      windir(3)     TYPE c,
      filename_bat  TYPE string VALUE 'tasklist.bat',
      filename_log  TYPE string VALUE 'tasklist.log',
      filepath_bat  TYPE string,
      filepath_log  TYPE string,
      filesize_log  TYPE i,
      rc            TYPE i.

*&---------------------------------------------------------------------*
*& Selection screen to enter process name
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1.
  PARAMETER: p_proc TYPE string.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& Get Windows root drive
*&---------------------------------------------------------------------*

CALL FUNCTION 'GUI_GET_DESKTOP_INFO'
  EXPORTING
    TYPE = 2
  CHANGING
    RETURN  = windir.

TRANSLATE p_proc TO LOWER CASE.

*&---------------------------------------------------------------------*
*& Create a command line
*&---------------------------------------------------------------------*

CLEAR: tasklist, tasklist[].

CONCATENATE 'tasklist -fi "IMAGENAME eq ' p_proc '" /fo CSV > ' windir
            filename_log INTO tasklist-line RESPECTING BLANKS.
            
APPEND tasklist.

CONCATENATE:  windir filename_bat INTO filepath_bat,
              windir filename_log INTO filepath_log.
              
*&---------------------------------------------------------------------*
*& Download .bat file
*&---------------------------------------------------------------------*

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME      = filepath_bat
    NO_AUTH_CHECK = 'X'
  TABLES
    DATA_TAB      = tasklist[].
    
*&---------------------------------------------------------------------*
*& Execute .bat file
*&---------------------------------------------------------------------*

CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
  EXPORTING
    APPLICATION = filepath_bat
    MINIMIZED = 'X'
  EXCEPTIONS
    CNTL_ERROR = 1
    ERROR_NO_GUI = 2
    BAD_PARAMETER = 3
    FILE_NOT_FOUND = 4
    PATH_NOT_FOUND = 5
    FILE_EXTENSION_UNKNOWN = 6
    ERROR_EXECUTE_FAILED = 7
    SYNCHRONOUS_FAILED = 8
    NOT_SUPPORTED_BY_GUI = 9
    OTHERS = 10.
    
*&---------------------------------------------------------------------*
*& Get return file size
*&---------------------------------------------------------------------*

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_GET_SIZE
  EXPORTING
    FILE_NAME = filepath_log
  IMPORTING
    FILE_SIZE = filesize_log
  EXCEPTIONS
    FILE_GET_SIZE_FAILED  = 1
    CNTL_ERROR            = 2
    ERROR_NO_GUI          = 3
    NOT_SUPPORTED_BY_GUI  = 4
    OTHERS                = 5.

CALL METHOD  cl_gui_cfw=>flush( ).

*&---------------------------------------------------------------------*
*& Delete created files
*&---------------------------------------------------------------------*

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_DELETE
  EXPORTING
    FILENAME  = filepath_log
  CHANGING
    RC        = rc.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_DELETE
  EXPORTING
    FILENAME  = filepath_bat
  CHANGING
    RC        = rc.
    
*&---------------------------------------------------------------------*
*& Output
*&---------------------------------------------------------------------*

IF filesize_log EQ 0.
  WRITE 'Process is not running.'.
ELSEIF filesize_log > 0.
  WRITE 'Process is running.'.
ENDIF.
