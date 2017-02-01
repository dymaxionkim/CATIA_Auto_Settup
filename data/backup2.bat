:
: backup2.bat
:
: 도담시스템스 전용 설정을 뽑아내서 백업해 주는 배치파일
:
: 20150915 (주)도담시스템스 김동호 dhkim@dodaam.com
:
: 검증한 환경 : Windows7, Windows8.1, CATIA V5R20
:

@echo on
setlocal

: 현재 사용자 계정 폴더 이름을 파일로 저장하기
echo %USERPROFILE% > "USERPROFILE.backup2"


: 바로가기 아이콘
mkdir "backup2\Quick Launch"
copy /Y "%USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\CATIAENV.lnk" ".\backup2\Quick Launch"
copy /Y "%USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\CNEXT -admin.lnk" ".\backup2\Quick Launch"
copy /Y "%USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\CNEXT.lnk" ".\backup2\Quick Launch"

: CATEnv
mkdir "backup2\CATEnv"
copy /Y "C:\ProgramData\DassaultSystemes\CATEnv\CATIA.V5R20.B20.txt" ".\backup2\CATEnv"


: 사용자 셋팅
mkdir "backup2\AppData"
xcopy "%USERPROFILE%\AppData\Roaming\DassaultSystemes\*.*" ".\backup2\AppData\" /y /s /e /h /k

: 스크립트
mkdir "backup2\VBScript"
xcopy "C:\Program Files\Dassault Systemes\B20\win_b64\VBScript\*.*" ".\backup2\VBScript\" /y /s /e /h /k

: Standard
mkdir "backup2\standard"
xcopy "C:\Program Files\Dassault Systemes\B20\win_b64\resources\standard\*.*" ".\backup2\standard\" /y /s /e /h /k


: MechanicalStandardParts 카탈로그
mkdir "backup2\MechanicalStandardParts"
xcopy "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts\*.*" ".\backup2\MechanicalStandardParts\" /y /s /e /h /k


: 필수적인 추가 폰트
mkdir "backup2\Fonts"
copy /Y "C:\Windows\Fonts\ARIALUNI.TTF" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\G2MJ.TTF" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\GNGT.TTF" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\NGULIM.TTF" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\SAMMUL.TTF" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\SGRP.TTF" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\Smj.ttf" ".\backup2\Fonts\"
copy /Y "C:\Windows\Fonts\SUMJ.TTF" ".\backup2\Fonts\"




