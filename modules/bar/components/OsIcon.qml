import QtQuick
import QtQuick.Effects
import Quickshell.Io
import "../../../widgets"
import "../../../services-niri"
import "../../utils"
import "../../../config"

StyledText {
    id: osIcon
    text: getWorkspaceIcon()
    
    // Fixed size and font settings for consistent appearance
    width: 24
    height: 24
    font.pointSize: getIconFontSize()  // Dynamic font size based on workspace
    font.family: Appearance.font.family.mono
    color: Colours.palette.m3tertiary
    
    // Center the text within the fixed dimensions
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    
    // Remove any default padding/margins
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    
    // Smooth transitions for hover effects
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    // Make the icon clickable with hover effects
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: launchWorkspaceApps()
        cursorShape: Qt.PointingHandCursor
        
        onEntered: {
            osIcon.scale = 1.15
            osIcon.color = Colours.palette.m3primary
        }
        
        onExited: {
            osIcon.scale = 1.0
            osIcon.color = Colours.palette.m3tertiary
        }
        
        onPressed: {
            osIcon.scale = 1.05
        }
        
        onReleased: {
            osIcon.scale = mouseArea.containsMouse ? 1.15 : 1.0
        }
    }
    
    // Simple process launcher
    Process {
        id: launchProcess
    }
    
    // Function to get the appropriate font size based on workspace
    function getIconFontSize() {
        // Check if this is the first workspace (code workspace or index 1)
        const isFirstWorkspace = (NiriService.currentWorkspaceIsNamed && 
                                  NiriService.currentWorkspaceName && 
                                  NiriService.currentWorkspaceName.toLowerCase() === "code") ||
                                 (!NiriService.currentWorkspaceIsNamed && 
                                  NiriService.currentMonitorWorkspaceIndex === 1);
        
        // Make the first workspace icon 25% bigger
        return isFirstWorkspace ? 20 : 16;  // 20 is 16 * 1.25
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
                    return ""; // Code/terminal icon
                case "browsing":
                    console.log("  Returning browsing icon");
                    return ""; // Browser icon
                case "finance":
                    console.log("  Returning finance icon");
                    return ""; // Dollar sign icon
                case "social":
                case "social media":
                    console.log("  Returning social media icon");
                    return "\uf27a"; // Social media icon
                case "home":
                    console.log("  Returning home icon");
                    return "\uf015"; // Home icon
                default:
                    console.log("  Returning default OS icon for named workspace");
                    return "\uf301"; // Fallback to system OS icon
            }
        } else {
            // Use workspace index for unnamed workspaces
            const workspaceIndex = NiriService.currentMonitorWorkspaceIndex;
            console.log("  Using workspace index:", workspaceIndex);
            
            switch (workspaceIndex) {

                default:
                    console.log("  Returning default OS icon for index", workspaceIndex);
                    return ""; // Fallback to system OS icon for other workspaces
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
                
            case "index2":
                // Generic unnamed workspace - no specific apps
                console.log("No specific apps configured for unnamed workspace at index 2");
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
