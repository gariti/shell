import QtQuick
import Quickshell.Io
import "../../../widgets"
import "../../../services-niri"
import "../../../utils"
import "../../../config"

StyledText {
    text: getWorkspaceIcon()
    font.pointSize: Appearance.font.size.larger
    font.family: Appearance.font.family.mono
    color: Colours.palette.m3tertiary
    
    // Make the icon clickable
    MouseArea {
        anchors.fill: parent
        onClicked: launchWorkspaceApps()
        cursorShape: Qt.PointingHandCursor
    }
    
    // Simple process launcher
    Process {
        id: launchProcess
    }
    
    // Function to get the appropriate icon based on workspace name or index
    function getWorkspaceIcon() {
        // Debug logging
        console.log("OsIcon Debug:");
        console.log("  currentWorkspaceIsNamed:", NiriService.currentWorkspaceIsNamed);
        console.log("  currentWorkspaceName:", NiriService.currentWorkspaceName);
        console.log("  currentMonitorWorkspaceIndex:", NiriService.currentMonitorWorkspaceIndex);
        
        // First check if workspace has a name
        if (NiriService.currentWorkspaceIsNamed && NiriService.currentWorkspaceName) {
            const workspaceName = NiriService.currentWorkspaceName.toLowerCase();
            console.log("  Using named workspace:", workspaceName);
            
            // Map workspace names to NerdFont icons
            switch (workspaceName) {
                case "code":
                    console.log("  Returning code icon");
                    return "\uf121"; // Code/terminal icon
                case "browsing":
                    console.log("  Returning browsing icon");
                    return "\ue76b"; // Firefox/Browser icon
                case "finance":
                    console.log("  Returning finance icon");
                    return "\uf155"; // Dollar sign icon
                case "social":
                case "social media":
                    console.log("  Returning social media icon");
                    return "\uf27a"; // Social media icon
                case "home":
                    console.log("  Returning home icon");
                    return "\uf015"; // Home icon
                default:
                    console.log("  Returning default OS icon for named workspace");
                    return Icons.osIcon; // Fallback to system OS icon
            }
        } else {
            // Use workspace index for unnamed workspaces
            const workspaceIndex = NiriService.currentMonitorWorkspaceIndex;
            console.log("  Using workspace index:", workspaceIndex);
            
            switch (workspaceIndex) {
                case 1:
                    console.log("  Returning code icon for index 1");
                    return "\uf121"; // Code workspace (index 1)
                case 2:
                    console.log("  Returning browsing icon for index 2");
                    return "\ue76b"; // Browsing workspace (index 2)
                case 3:
                    console.log("  Returning finance icon for index 3");
                    return "\uf155"; // Finance workspace (index 3)
                case 4:
                    console.log("  Returning home icon for index 4");
                    return "\uf015"; // Home workspace (index 4)
                case 5:
                    console.log("  Returning social media icon for index 5");
                    return "\uf27a"; // Social media workspace (index 5)
                default:
                    console.log("  Returning default OS icon for index", workspaceIndex);
                    return Icons.osIcon; // Fallback to system OS icon for other workspaces
            }
        }
    }
    
    // Function to launch workspace-specific applications using Niri spawn
    function launchWorkspaceApps() {
        const workspaceName = NiriService.currentWorkspaceIsNamed ? 
            NiriService.currentWorkspaceName.toLowerCase() : 
            `index${NiriService.currentMonitorWorkspaceIndex}`;
            
        console.log("Launching apps for workspace:", workspaceName);
        
        // Use Niri's spawn action to launch apps on current workspace
        switch (workspaceName) {
            case "code":
            case "index1":
                // Launch development apps on current workspace
                spawnOnCurrentWorkspace("code");
                spawnOnCurrentWorkspace("brave --profile-directory=code");
                break;
                
            case "browsing":
            case "index2":
                // Launch browsing apps
                spawnOnCurrentWorkspace("brave");
                break;
                
            case "finance":
            case "index3":
                // Launch finance apps
                spawnOnCurrentWorkspace("brave --profile-directory=finance");
                break;
                
            case "home":
            case "index4":
                // Launch home/productivity apps
                spawnOnCurrentWorkspace("brave --profile-directory=home");
                break;
                
            case "social":
            case "social media":
            case "index5":
                // Launch social media apps
                spawnOnCurrentWorkspace("brave --profile-directory=social");
                break;
            default:
                console.log("No specific apps configured for workspace:", workspaceName);
                break;
        }
    }
    
    // Helper function to spawn apps on current workspace using Niri
    function spawnOnCurrentWorkspace(command) {
        console.log("Spawning on current workspace:", command);
        // Split command into parts for proper execution
        const parts = command.split(" ");
        const fullCommand = ["niri", "msg", "action", "spawn", "--"].concat(parts);
        launchProcess.command = fullCommand;
        launchProcess.startDetached();
    }

    // Update icon when workspace changes
    Connections {
        target: NiriService
        function onCurrentWorkspaceNameChanged() {
            console.log("Workspace name changed, updating icon");
            text = getWorkspaceIcon();
        }
        function onCurrentWorkspaceIsNamedChanged() {
            console.log("Workspace named status changed, updating icon");
            text = getWorkspaceIcon();
        }
        function onCurrentMonitorWorkspaceIndexChanged() {
            console.log("Workspace index changed, updating icon");
            text = getWorkspaceIcon();
        }
    }
    
    // Initialize the icon when component is loaded
    Component.onCompleted: {
        console.log("OsIcon component loaded, setting initial icon");
        text = getWorkspaceIcon();
    }
}
