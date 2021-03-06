#Copyright (C) 2011 Wang Bin <wbsecg1@gmail.com>
#Shanghai, China.
#GPL v2

CONFIG += #ezx#static ezx
CONFIG += profile
#profiling, -pg is not supported for msvc
debug:!*msvc*:profile {
		QMAKE_CXXFLAGS_DEBUG += -pg
		QMAKE_LFLAGS_DEBUG += -pg
}

#$$[TARGET_PLATFORM]
#$$[QT_ARCH] #windows symbian windowsce arm
PLATFORM_EXT =
ARCH_EXT =
TOOLCHAIN_EXT =
unix {
  PLATFORM_EXT = _unix
  *linux*: PLATFORM_EXT = _linux
  *maemo*: PLATFORM_EXT = _maemo
} else:win32 {
  PLATFORM_EXT = _win32
} else:macx {
  PLATFORM_EXT = _macx
}

ezx {
  QT_VERSION = 2.3.8
  CONFIG += qt warn_on release
  DEFINES += QT_THREAD_SUPPORT CONFIG_EZX
  PLATFORM_EXT = _ezx
  QMAKE_CXXFLAGS.ARMCC +=
}

#*arm*: ARCH_EXT = $${ARCH_EXT}_arm
#isEqual(QT_ARCH, arm) {
contains(QT_ARCH, arm.*) {
  ARCH_EXT = $${ARCH_EXT}_$${QT_ARCH}
}
*64:   ARCH_EXT = $${ARCH_EXT}_x64
*llvm*: TOOLCHAIN_EXT = _llvm
#*msvc*:

#before target name changed
TRANSLATIONS += i18n/$${TARGET}_zh-cn.ts #i18n/$${TARGET}_zh_CN.ts

isEqual(TEMPLATE, app) {
  DESTDIR = bin
  TARGET = $${TARGET}$${PLATFORM_EXT}$${ARCH_EXT}$${TOOLCHAIN_EXT}
}
else: DESTDIR = lib

OBJECTS_DIR = .obj/$${PLATFORM_EXT}$${ARCH_EXT}$${TOOLCHAIN_EXT}
 #for Qt2, Qt3 which does not have QT_VERSION. Qt4: $$[QT_VERSION]
MOC_DIR = .moc/$${QT_VERSION}
RCC_DIR = .rcc/$${QT_VERSION}
UI_DIR  = .ui/$${QT_VERSION}

#unix: QMAKE_POST_LINK=strip $(TARGET)
!build_pass:message(target: $$DESTDIR/$$TARGET)


#qtLibraryTarget
defineReplace(qtLibraryName) {
   unset(LIBRARY_NAME)
   LIBRARY_NAME = $$1
   CONFIG(debug, debug|release) {
	  !debug_and_release|build_pass {
		  mac:RET = $$member(LIBRARY_NAME, 0)_debug
			  else:win32:RET = $$member(LIBRARY_NAME, 0)d
	  }
   }
   isEmpty(RET):RET = $$LIBRARY_NAME
   return($$RET)
}

#fakelib
defineReplace(qtStaticLib) {
	unset(LIB_FULLNAME)
	TEMPLATE += fakelib
	LIB_FULLNAME = $$qtLibraryTarget($$1)
	TEMPLATE -= fakelib
	*msvc*: LIB_FULLNAME = $$member(LIB_FULLNAME, 0).lib
	else: LIB_FULLNAME = lib$$member(LIB_FULLNAME, 0).a
	return($$LIB_FULLNAME)
}

defineReplace(qtSharedLib) {
	unset(LIB_FULLNAME)
	TEMPLATE += fakelib
	LIB_FULLNAME = $$qtLibraryTarget($$1)
	TEMPLATE -= fakelib
	win32: LIB_FULLNAME = $$member(LIB_FULLNAME, 0).dll
	else: LIB_FULLNAME = lib$$member(LIB_FULLNAME, 0).so
	return($$LIB_FULLNAME)
}
