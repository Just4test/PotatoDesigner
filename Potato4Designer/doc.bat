set FLEX_HOME=C:/Program Files/Adobe/Adobe Flash Builder 4.7 (64 Bit)/sdks/4.6.0
java -Xmx1024m -Dsun.io.useCanonCaches=false -Xbootclasspath/p:"%FLEX_HOME%/lib/xalan.jar" -classpath "%FLEX_HOME%/lib/asdoc.jar" flex2.tools.ASDoc +flexlib="%FLEX_HOME%/frameworks" -main-title "Mirage API Documentation" -window-title "Mirage API Documentation" -footer "北京超闪软件有限公司" -source-path src -doc-sources . -library-path "%FLEX_HOME%\frameworks\libs\air\airglobal.swc" -library-path "D:\work\leeflash\core\bin\core.swc"

pause
