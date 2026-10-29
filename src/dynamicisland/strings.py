"""The island's own handful of words.

Everything on a card comes from the application that sent it, so the island has
only two strings of its own, both in the inline reply field: the placeholder
(when the sender supplies none) and the send button.  Two strings do not
justify a Qt translation pipeline with .ts files and a build step — a table
picked by the session locale is the honest size of the problem.

The panel applet is a different story: it is a KDE package and uses gettext
catalogues, see ``applet/*/translate``.
"""

from __future__ import annotations

from PySide6.QtCore import Property, QLocale, QObject, Signal

#: Keyed by ISO 639-1 language, without a region: the reply field says the same
#: thing in Taiwan as it does in Beijing. Wording follows KDE's own catalogues.
TABLE = {
    "en": {
        "reply": "Reply…", "send": "Send",
        "pause": "Pause", "resume": "Resume", "cancel": "Cancel",
        "job": "File operation",
        "volume": "Volume", "microphone": "Microphone",
        "brightness": "Brightness", "keyboard": "Keyboard backlight",
        "media": "Now playing", "on": "On", "off": "Off",
    },
    "de": {
        "reply": "Antworten…", "send": "Senden",
        "pause": "Anhalten", "resume": "Fortsetzen", "cancel": "Abbrechen",
        "job": "Dateivorgang",
        "volume": "Lautstärke", "microphone": "Mikrofon",
        "brightness": "Helligkeit", "keyboard": "Tastaturbeleuchtung",
        "media": "Jetzt läuft", "on": "An", "off": "Aus",
    },
    "ru": {
        "reply": "Ответить…", "send": "Отправить",
        "pause": "Приостановить", "resume": "Продолжить", "cancel": "Отменить",
        "job": "Операция с файлами",
        "volume": "Громкость", "microphone": "Микрофон",
        "brightness": "Яркость", "keyboard": "Подсветка клавиатуры",
        "media": "Сейчас играет", "on": "Вкл.", "off": "Выкл.",
    },
    "zh": {
        "reply": "回复…", "send": "发送",
        "pause": "暂停", "resume": "继续", "cancel": "取消",
        "job": "文件操作",
        "volume": "音量", "microphone": "麦克风",
        "brightness": "亮度", "keyboard": "键盘背光",
        "media": "正在播放", "on": "开启", "off": "关闭",
    },
    "ja": {
        "reply": "返信…", "send": "送信",
        "pause": "一時停止", "resume": "再開", "cancel": "キャンセル",
        "job": "ファイル操作",
        "volume": "音量", "microphone": "マイク",
        "brightness": "明るさ", "keyboard": "キーボードバックライト",
        "media": "再生中", "on": "オン", "off": "オフ",
    },
}

FALLBACK = "en"


def language(preferred: str = "", locale: QLocale | None = None) -> str:
    """Which of our languages to speak.

    *preferred* is what the settings ask for — a tag like ``de``, or ``auto``
    (or nothing at all) to follow the session, which is what a desktop
    application should do unless it is told otherwise.
    """
    tag = str(preferred or "").replace("_", "-").split("-")[0].lower()
    if tag in TABLE:
        return tag

    locale = locale or QLocale()
    for name in [*locale.uiLanguages(), locale.name()]:
        tag = name.replace("_", "-").split("-")[0].lower()
        if tag in TABLE:
            return tag
    return FALLBACK


class Strings(QObject):
    """Exposed to QML as ``Strings``.

    The properties are not constant: the language can be changed in the
    settings while the island runs, and a reply field still saying "Antworten"
    afterwards would be a bug nobody would think to report.
    """

    changed = Signal()

    def __init__(self, parent: QObject | None = None, preferred: str = "") -> None:
        super().__init__(parent)
        self._language = language(preferred)

    def follow(self, preferred: str) -> None:
        """Speak what the settings now ask for."""
        chosen = language(preferred)
        if chosen == self._language:
            return
        self._language = chosen
        self.changed.emit()

    @Property(str, notify=changed)
    def reply(self) -> str:
        return TABLE[self._language]["reply"]

    @Property(str, notify=changed)
    def send(self) -> str:
        return TABLE[self._language]["send"]

    def word(self, key: str) -> str:
        """For the Python side — job buttons are built there, not in QML."""
        return TABLE[self._language][key]
