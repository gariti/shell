import "services-niri"
import "widgets" 
import "config"
import "modules/background"
import "modules/drawers"
import Quickshell

ShellRoot {
    Background {}
    Drawers {}
    
    Scope {
        // Include shortcuts directly
        CustomShortcut {
            name: "session"
            description: "Toggle session menu"
            onPressed: {
                const visibilities = Visibilities.getForActive();
                if (visibilities) visibilities.session = !visibilities.session;
            }
        }

        CustomShortcut {
            name: "launcher"
            description: "Toggle launcher"
            onPressed: {
                const visibilities = Visibilities.getForActive();
                if (visibilities) visibilities.launcher = !visibilities.launcher;
            }
        }
    }
}
