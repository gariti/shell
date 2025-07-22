pragma Singleton

import "../utils/scripts/fuzzysort.js" as Fuzzy
import "../utils"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string currentNamePath: `${Paths.state}/wallpaper/last.txt`.slice(7)
    readonly property string path: `${Paths.pictures}/Wallpapers`.slice(7)

    readonly property list<Wallpaper> list: wallpapers.instances
    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent

    readonly property list<var> preppedWalls: list.map(w => ({
                name: Fuzzy.prepare(w.name),
                path: Fuzzy.prepare(w.path),
                wall: w
            }))

    function fuzzyQuery(search: string): var {
        return Fuzzy.go(search, preppedWalls, {
            all: true,
            keys: ["name", "path"],
            scoreFn: r => r[0].score * 0.9 + r[1].score * 0.1
        }).map(r => r.obj.wall);
    }

    function setWallpaper(path: string): void {
        actualCurrent = path;
        setWall.path = path;
        setWall.startDetached();
    }

    function setRandomWallpaper(): void {
        if (list.length === 0) {
            console.log("Wallpapers: No wallpapers found, cannot set random wallpaper");
            return;
        }
        
        const randomIndex = Math.floor(Math.random() * list.length);
        const randomWallpaper = list[randomIndex];
        console.log(`Wallpapers: Setting random wallpaper ${randomIndex + 1}/${list.length}: ${randomWallpaper.name}`);
        setWallpaper(randomWallpaper.path);
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;
        getPreviewColoursProc.running = true;
    }

    function stopPreview(): void {
        showPreview = false;
        Colours.endPreviewOnNextChange = true;
    }

    reloadableId: "wallpapers"

    IpcHandler {
        target: "wallpaper"

        function get(): string {
            return root.actualCurrent;
        }

        function set(path: string): void {
            root.setWallpaper(path);
        }

        function random(): void {
            root.setRandomWallpaper();
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.actualCurrent = text().trim()
            // Restore wallpaper on startup if one was previously set
            if (root.actualCurrent && root.actualCurrent !== "") {
                setWall.path = root.actualCurrent
                setWall.startDetached()
            }
        }
    }

    Process {
        id: getPreviewColoursProc

        command: ["caelestia", "scheme", "print", root.previewPath]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                Colours.load(data, true);
                Colours.showPreview = true;
            }
        }
    }

    Process {
        id: setWall

        property string path

        command: ["caelestia", "wallpaper", "set", path]
    }

    Process {
        running: true
        command: ["find", root.path, "-type", "f", "(", "-name", "*.jpg", "-o", "-name", "*.jpeg", "-o", "-name", "*.png", "-o", "-name", "*.svg", ")"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                wallpapers.model = data.trim().split("\n")
                // Set random wallpaper after loading the list
                if (wallpapers.model.length > 0) {
                    // Use a timer to ensure the list is fully populated
                    randomWallpaperTimer.start()
                }
            }
        }
    }

    Timer {
        id: randomWallpaperTimer
        interval: 500  // 500ms delay to ensure list is populated
        repeat: false
        onTriggered: {
            console.log("Wallpapers: Setting random wallpaper on startup");
            root.setRandomWallpaper();
        }
    }

    Variants {
        id: wallpapers

        Wallpaper {}
    }

    component Wallpaper: QtObject {
        required property string modelData
        readonly property string path: modelData
        readonly property string name: path.slice(path.lastIndexOf("/") + 1, path.lastIndexOf("."))
    }
}
