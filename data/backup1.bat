:
: backup1.bat
:
: 기존의 원래 설정을 백업해 두는 배치파일
:
: 20150915 (주)도담시스템스 김동호 dhkim@dodaam.com
:
: 검증한 환경 : Windows7, Windows8.1, CATIA V5R20
:

@echo on
setlocal

: 현재 사용자 계정 폴더 이름을 파일로 저장하기
echo %USERPROFILE% > "USERPROFILE.backup1"


: 사용자 셋팅
mkdir "backup1\AppData"
xcopy "%USERPROFILE%\AppData\Roaming\DassaultSystemes\*.*" ".\backup1\AppData\" /y /s /e /h /k

: 스크립트
mkdir "backup1\VBScript"
xcopy "C:\Program Files\Dassault Systemes\B20\win_b64\VBScript\*.*" ".\backup1\VBScript\" /y /s /e /h /k

: Standard
mkdir "backup1\standard"
xcopy "C:\Program Files\Dassault Systemes\B20\win_b64\resources\standard\*.*" ".\backup1\standard\" /y /s /e /h /k

: MechanicalStandardParts 카탈로그
mkdir "backup1\MechanicalStandardParts"
xcopy "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts\*.*" ".\backup1\MechanicalStandardParts\" /y /s /e /h /k







