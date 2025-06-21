pragma Singleton

import "../utils/scripts/fuzzysort.js" as Fuzzy
import "../utils"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string currentNamePath: `${Paths.state}/variant/last.txt`.slice(7)

    readonly property list<Variant> list: variants.instances
    property string actualCurrent: "auto"

    readonly property list<var> preppedVariants: list.map(v => ({
                name: Fuzzy.prepare(v.name),
                variant: v
            }))

    readonly property string current: actualCurrent

    function fuzzyQuery(search: string): var {
        return Fuzzy.go(search, preppedVariants, {
            all: true,
            keys: ["name"],
            scoreFn: r => r[0].score
        }).map(r => r.obj.variant);
    }

    function setVariant(name: string): void {
        actualCurrent = name;
        setVariantProc.variantName = name;
        setVariantProc.startDetached();
    }

    reloadableId: "variants"

    IpcHandler {
        target: "variant"

        function get(): string {
            return root.actualCurrent;
        }

        function set(name: string): void {
            root.setVariant(name);
        }

        function list(): string {
            return root.list.map(v => v.name).join("\n");
        }
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.actualCurrent = text().trim()
    }

    Process {
        id: setVariantProc

        property string variantName

        command: ["caelestia", "scheme", "variant", variantName]
    }

    // Initialize with common scheme variants
    Component.onCompleted: {
        variants.model = ["auto", "light", "dark", "vibrant", "muted", "high-contrast"];
    }

    Variants {
        id: variants

        Variant {}
    }

    component Variant: QtObject {
        required property var modelData
        readonly property string name: modelData
    }
}
