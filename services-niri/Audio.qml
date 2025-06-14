pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    function setVolume(volume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = volume;
        }
    }

    function toggleMute(): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function setMuted(muted: bool): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = muted;
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}
