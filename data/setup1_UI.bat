:
: setup1_UI.bat
:
: backup1.bat로 백업해 둔 설정 중에서 UI 부분만 복원시켜주는 배치파일
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



: UI 복원
rmdir /s /q "%USERPROFILE%\AppData\Roaming\DassaultSystemes\CATSettings"
mkdir "%USERPROFILE%\AppData\Roaming\DassaultSystemes\CATSettings"
xcopy ".\backup1\AppData\CATSettings\*.*" "%USERPROFILE%\AppData\Roaming\DassaultSystemes\CATSettings" /y /s /e /h /k



