:
: case2.bat
:
: 기존 설정을 백업하지 않고, 새로운 설정을 전면적으로 적용시켜주되 사용자 인터페이스는 원래 자신의 설정으로 남겨두는 배치파일
:
: 20150915 (주)도담시스템스 김동호 dhkim@dodaam.com
:
: 검증한 환경 : Windows7, Windows8.1, CATIA V5R20
:

@echo on

setup2.bat
setup1_UI.bat

