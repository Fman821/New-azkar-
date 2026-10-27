#!/usr/bin/env python3
"""Adds what the generated Android project needs for reminders and the app name.

Run from the project root after `flutter create --platforms=android .`:

    python3 tool/patch_android.py .

Changes:
  - permissions: INTERNET, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED,
    SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, USE_FULL_SCREEN_INTENT
  - app label: እስላማዊ አዝካር
  - boot/alarm receivers used by flutter_local_notifications
  - core library desugaring (needed by flutter_local_notifications on Android)

It is safe to run twice: every change is skipped if it is already there.
If an expected part of the project is missing, it stops with an error instead
of guessing.
"""

import pathlib
import re
import sys

LABEL = 'እስላማዊ አዝካር'
PERMISSIONS = [
    'android.permission.INTERNET',
    'android.permission.POST_NOTIFICATIONS',
    'android.permission.RECEIVE_BOOT_COMPLETED',
    'android.permission.SCHEDULE_EXACT_ALARM',
    # Alarm mode asks for exact times and a full-screen alert on the lock screen.
    'android.permission.USE_EXACT_ALARM',
    'android.permission.USE_FULL_SCREEN_INTENT',
]
RECEIVERS = """
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
            android:exported="false" />
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
    """
DESUGAR_LIB = 'com.android.tools:desugar_jdk_libs:2.1.4'


def fail(message: str) -> None:
    print(f'patch_android: {message}', file=sys.stderr)
    sys.exit(1)


def patch_manifest(app_dir: pathlib.Path) -> None:
    manifest = app_dir / 'src' / 'main' / 'AndroidManifest.xml'
    if not manifest.exists():
        fail(f'{manifest} not found')
    text = manifest.read_text(encoding='utf-8')

    # Permissions go right after the opening <manifest ...> tag.
    tag = re.search(r'<manifest\b[^>]*>', text)
    if not tag:
        fail('no <manifest> tag in AndroidManifest.xml')
    missing = [p for p in PERMISSIONS if p not in text]
    if missing:
        lines = ''.join(f'\n    <uses-permission android:name="{p}" />' for p in missing)
        text = text[: tag.end()] + lines + text[tag.end():]

    # App name shown under the icon.
    app_tag = re.search(r'<application\b[^>]*>', text)
    if not app_tag:
        fail('no <application> tag in AndroidManifest.xml')
    new_tag = re.sub(r'android:label="[^"]*"', f'android:label="{LABEL}"', app_tag.group(0))
    if new_tag == app_tag.group(0) and f'android:label="{LABEL}"' not in new_tag:
        new_tag = new_tag.replace('<application', f'<application android:label="{LABEL}"', 1)
    text = text[: app_tag.start()] + new_tag + text[app_tag.end():]

    # Receivers go just before </application>.
    if 'ScheduledNotificationReceiver' not in text:
        if '</application>' not in text:
            fail('no </application> in AndroidManifest.xml')
        text = text.replace('</application>', RECEIVERS + '</application>', 1)

    manifest.write_text(text, encoding='utf-8')
    print('patch_android: manifest ok')


def patch_gradle(app_dir: pathlib.Path) -> None:
    kts = app_dir / 'build.gradle.kts'
    groovy = app_dir / 'build.gradle'
    if kts.exists():
        path, is_kts = kts, True
    elif groovy.exists():
        path, is_kts = groovy, False
    else:
        fail('no build.gradle(.kts) in android/app')

    text = path.read_text(encoding='utf-8')
    if DESUGAR_LIB in text:
        print('patch_android: gradle already patched')
        return

    if is_kts:
        option = 'isCoreLibraryDesugaringEnabled = true'
        dependency = f'    coreLibraryDesugaring("{DESUGAR_LIB}")\n'
    else:
        option = 'coreLibraryDesugaringEnabled true'
        dependency = f"    coreLibraryDesugaring '{DESUGAR_LIB}'\n"

    # Put the option into the existing compileOptions block if there is one,
    # otherwise add a new block at the start of android { }.
    existing = re.search(r'^[ \t]*compileOptions\s*\{[ \t]*\n', text, re.M)
    if existing:
        text = text[: existing.end()] + f'        {option}\n' + text[existing.end():]
    else:
        android = re.search(r'^android\s*\{[ \t]*\n', text, re.M)
        if not android:
            fail(f'no android {{ block in {path.name}')
        block = f'    compileOptions {{\n        {option}\n    }}\n'
        text = text[: android.end()] + block + text[android.end():]

    deps = re.search(r'^dependencies\s*\{[ \t]*\n', text, re.M)
    if deps:
        text = text[: deps.end()] + dependency + text[deps.end():]
    else:
        text = text.rstrip() + f'\n\ndependencies {{\n{dependency}}}\n'

    if DESUGAR_LIB not in text or option not in text:
        fail(f'desugaring not inserted into {path.name}')
    path.write_text(text, encoding='utf-8')
    print(f'patch_android: {path.name} ok')


def patch_release_shrinking(app_dir: pathlib.Path) -> None:
    """Turns off code and resource shrinking (R8) for release builds.

    R8 strips the generic type information that flutter_local_notifications
    needs to read its saved reminders, which crashes with "Missing type
    parameter" in release builds. Resource shrinking needs code shrinking,
    so both are turned off together.
    """
    kts = app_dir / 'build.gradle.kts'
    groovy = app_dir / 'build.gradle'
    path = kts if kts.exists() else groovy
    is_kts = path == kts
    text = path.read_text(encoding='utf-8')

    settings = [
        ('isMinifyEnabled = false', r'isMinifyEnabled\s*=\s*true') if is_kts
        else ('minifyEnabled false', r'minifyEnabled\s+true'),
        ('isShrinkResources = false', r'isShrinkResources\s*=\s*true') if is_kts
        else ('shrinkResources false', r'shrinkResources\s+true'),
    ]
    for off, on_pattern in settings:
        if re.search(on_pattern, text):
            text = re.sub(on_pattern, off, text)
        elif off not in text:
            release = re.search(r'^[ \t]*release\s*\{[ \t]*\n', text, re.M)
            if not release:
                fail(f'no release {{ block in {path.name}')
            text = text[: release.end()] + f'            {off}\n' + text[release.end():]
        if off not in text:
            fail(f'could not set {off} in {path.name}')
    path.write_text(text, encoding='utf-8')
    print(f'patch_android: {path.name} release shrinking off')


def patch_compile_sdk(app_dir: pathlib.Path) -> None:
    """Sets compileSdk to 36.

    share_plus (and other plugins) must be compiled against Android 34 or
    later, so the project's compileSdk has to be at least that high.
    """
    kts = app_dir / 'build.gradle.kts'
    groovy = app_dir / 'build.gradle'
    path = kts if kts.exists() else groovy
    is_kts = path == kts
    text = path.read_text(encoding='utf-8')
    line = 'compileSdk = 36' if is_kts else 'compileSdk 36'

    pattern = r'(?m)^([ \t]*)compileSdk(?:Version)?(\s*=\s*|\s+)[^\n]*$'
    if re.search(pattern, text):
        text = re.sub(pattern, lambda m: m.group(1) + line, text, count=1)
    else:
        android = re.search(r'^android\s*\{[ \t]*\n', text, re.M)
        if not android:
            fail(f'no android {{ block in {path.name}')
        text = text[: android.end()] + f'    {line}\n' + text[android.end():]
    if line not in text:
        fail(f'could not set compileSdk in {path.name}')
    path.write_text(text, encoding='utf-8')
    print(f'patch_android: {path.name} compileSdk 36')


def main() -> None:
    root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '.')
    app_dir = root / 'android' / 'app'
    if not app_dir.is_dir():
        fail(f'{app_dir} not found. Run `flutter create --platforms=android .` first.')
    patch_manifest(app_dir)
    patch_gradle(app_dir)
    patch_release_shrinking(app_dir)
    patch_compile_sdk(app_dir)
    print('patch_android: done')


if __name__ == '__main__':
    main()
