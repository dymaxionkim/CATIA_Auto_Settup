:
: setup2.bat
:
: backup2.bat로 백업해 둔 설정을 적용시켜주는 배치파일
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



: 백업받을 때의 사용자 계정 폴더 이름을 변수에 기억하기
set cmd="more USERPROFILE.backup2"
FOR /F %%j IN (' %cmd% ') DO SET USERPROFILE_backup2=%%j


: CATEnv (관리자 모드로 CATIA 실행이 가능하도록 해 둔 설정)
:
: Find & Replace
: Ref ::: http://stackoverflow.com/questions/23087463/batch-script-to-find-and-replace-a-string-in-text-file-within-a-minute-for-files
set "search=%USERPROFILE_backup2%"
set "replace=%USERPROFILE%"
set "textfile=.\backup2\CATEnv\CATIA.V5R20.B20.txt"
set "newfile=.\backup2\CATEnv\CATIA.V5R20.B20.new"
call repl.bat "%search%" "%replace%" L < "%textfile%" > "%newfile%"
copy /Y "%newfile%" "C:\ProgramData\DassaultSystemes\CATEnv\CATIA.V5R20.B20.txt"



: 시스템 사용자변수 설정 (CATIA 시작 속도 향상)
: (이런거 필요없으면 이 모듈을 주석처리 하면 됨)
:
: CATIA 시작되었을 때 새 도큐먼트 만들기 창을 안 띄우는 설정
setx CATNoStartDocument "no"
: CATIA 시작할 때 스플래쉬 그림 안 보이게 하는 설정
setx CNEXTSPLASHSCREEN "no"
: CATIA 뒷 배경 화면에 이상한(?) 우주 그림 안 띄우는 설정
setx CNEXTBACKGROUND "no"
: DXF 파일을 Drafting Bacground에 불러들일 수 있도록 해 주는 설정
setx DXF_IMPORT_MODEL_IN_BACKGROUND "1"


: 바로가기 아이콘
xcopy ".\backup2\Quick Launch\*.*" "%USERPROFILE%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\" /y /s /e /h /k
xcopy ".\backup2\Quick Launch\*.*" "%USERPROFILE%\Desktop\" /y /s /e /h /k

: 사용자 셋팅
xcopy ".\backup2\AppData\*.*" "%USERPROFILE%\AppData\Roaming\DassaultSystemes\" /y /s /e /h /k

: 스크립트
xcopy ".\backup2\VBScript\*.*" "C:\Program Files\Dassault Systemes\B20\win_b64\VBScript\" /y /s /e /h /k

: Standard
xcopy ".\backup2\standard\*.*" "C:\Program Files\Dassault Systemes\B20\win_b64\resources\standard\" /y /s /e /h /k

: MechanicalStandardParts 카탈로그
rmdir /s /q "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts"
mkdir "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts\"
xcopy ".\backup2\MechanicalStandardParts\*.*" "C:\Program Files\Dassault Systemes\B20\win_b64\startup\components\MechanicalStandardParts\" /y /s /e /h /k

: 필수적인 추가 폰트
xcopy ".\backup2\Fonts\*.*" "C:\Windows\Fonts\" /y /s /e /h /k



