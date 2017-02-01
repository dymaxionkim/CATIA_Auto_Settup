:
: setup1.bat
:
: backup1.bat로 백업해 둔 설정으로 복원시켜주는 배치파일
:
: 20150915 (주)도담시스템스 김동호 dhkim@dodaam.com
:
: 검증한 환경 : Windows7, Windows8.1, CATIA V5R20
:
:
:
: *** 조건
: 1. CATIA를 반드시 디폴트 경로로 설치한 경우여야 한다.  임의의 다른 경로로 설치했을 경우에는 오류 발생함.
: 2. 본 배치파일은 반드시 '관리자 권한'으로 실행해야 한다.
:

@echo on
setlocal



: 시스템 사용자변수 설정을 디폴트로 복원
:
: CATIA 시작되었을 때 새 도큐먼트 만들기 창을 안 띄우는 설정
setx CATNoStartDocument "yes"
: CATIA 시작할 때 스플래쉬 그림 안 보이게 하는 설정
setx CNEXTSPLASHSCREEN "yes"
: CATIA 뒷 배경 화면에 이상한(?) 우주 그림 안 띄우는 설정
setx CNEXTBACKGROUND "yes"
: DXF 파일을 Drafting Bacground에 불러들일 수 있도록 해 주는 설정
setx DXF_IMPORT_MODEL_IN_BACKGROUND "0"


: 사용자 셋팅 복원
rmdir /s /q "%USERPROFILE%\AppData\Roaming\DassaultSystemes"
mkdir "%USERPROFILE%\AppData\Roaming\DassaultSystemes"
xcopy ".\backup1\AppData\*.*" "%USERPROFILE%\AppData\Roaming\DassaultSystemes\" /y /s /e /h /k

: 스크립트 복원
rmdir /s /q "C:\Program Files\Dassault Systemes\B20\win_b64\VBScript"
mkdir "C:\Program Files\Dassault Systemes\B20\win_b64\VBScript\"
xcopy ".\backup1\VBScript\*.*" "C:\Program Files\Dassault Systemes\B20\win_b64\VBScript\" /y /s /e /h /k

: Standard 복원
rmdir /s /q "C:\Program Files\Dassault Systemes\B20\win_b64\resources\standard"
mkdir "C:\Program Files\Dassault Systemes\B20\win_b64\resources\standard\"
xcopy ".\backup1\standard\*.*" "C:\Program Files\Dassault Systemes\B20\win_b64\resources\standard\" /y /s /e /h /k

: MechanicalStandardParts 카탈로그 복원
rmdir /s /q "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts"
mkdir "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts\"
xcopy ".\backup1\MechanicalStandardParts\*.*" "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts\" /y /s /e /h /k




