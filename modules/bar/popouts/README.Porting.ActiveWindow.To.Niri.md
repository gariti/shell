
Analysis of Screencopy Compatibility Between Hyprland and Niri Compositors


Prepared for: Application Development Team


Subject: Porting a Screencopy-Based Application from Hyprland to Niri


Date: June 15, 2025


Executive Summary: Verifying ScreencopyView Compatibility with Niri

The assertion that an application using a ScreencopyView component is fundamentally incompatible with the Niri Wayland compositor requires careful deconstruction. While the premise is logical given the fragmented nature of the Wayland ecosystem, analysis indicates the core assumption is incorrect in this specific case. The Niri compositor, despite its distinct architectural foundation, deliberately implements the wlr-screencopy-unstable-v1 protocol. Therefore, at the protocol level, compatibility exists.
The component in question, ScreencopyView, is not a standard Wayland protocol but a higher-level C++/Qt object within a project identified as quickshell. Any incompatibility is therefore not a result of Niri lacking the necessary protocol. The issue is more likely rooted in one of the following: subtle differences in the protocol's implementation between Hyprland (a native wlroots compositor) and Niri (which provides a compatibility layer); dependencies within ScreencopyView on other Hyprland-specific or wlroots-specific protocols that Niri does not implement; or hardcoded assumptions in the application logic that are valid for Hyprland but fail on Niri.
While debugging the existing implementation is a possible path forward, this report strongly recommends migrating the application's screen capture functionality to use the xdg-desktop-portal framework. This is the modern, secure, and compositor-agnostic standard that both Hyprland and Niri endorse and fully support. This approach eliminates the fragility of relying on compositor-specific protocols and ensures broad future portability.
The existence of wlr-screencopy support in Niri is a noteworthy strategic decision. Niri is built using the Smithay toolkit, a Rust-based alternative to the C-based wlroots library that powers Hyprland and Sway. Typically, protocols prefixed with wlr- are exclusive to the wlroots ecosystem and are not implemented by compositors like GNOME's Mutter or KDE's KWin. A significant number of popular Wayland-native tools, such as wf-recorder and grim, were developed specifically for wlroots and depend on its protocols. To lower the barrier to entry for users migrating from these popular compositors, Niri's developers have made a deliberate and non-trivial engineering effort to re-implement key wlr protocols, including wlr-screencopy, as a compatibility feature. This decision acknowledges the market influence of wlroots-based tools and provides a functional bridge, making Niri an exception in the otherwise fragmented landscape.

The Wayland Screen Capture Landscape: A Fragmented Ecosystem

The root of this porting challenge lies in the fundamental design philosophy of the Wayland protocol. Wayland itself is a minimal display protocol that defines communication between a client and a compositor. The compositor is the single source of truth, managing all display resources, which enhances security and performance. However, this minimalist design delegates complex functionality, such as screen capture, to be implemented via extension protocols. The slow pace of official standardization for these extensions has led to a "Cambrian explosion" of competing, semi-proprietary protocols developed by different compositor projects to fill critical functionality gaps.

Technical Deep Dive: wlr-screencopy-unstable-v1

The wlr-screencopy-unstable-v1 protocol was developed by the wlroots project to provide a direct, low-level mechanism for clients to request a copy of the screen's contents into a client-provided buffer. It has become the de facto standard for screen capture on wlroots-based compositors like Hyprland and Sway.
The protocol operates through a clear sequence of requests and events:
The client binds to the global zwlr_screencopy_manager_v1 interface advertised by the compositor.
The client sends a capture_output or capture_output_region request. This creates a zwlr_screencopy_frame_v1 object, which represents a single capture operation.
The compositor responds by sending one or more buffer events to the client. These events detail the supported buffer types (e.g., shared memory via wl_shm or direct GPU memory access via linux_dmabuf), formats, and other constraints. This sequence concludes with a buffer_done event.
The client, having received the constraints, allocates a wl_buffer that conforms to one of the advertised types. It then sends a copy or copy_with_damage request to the compositor, passing the buffer to be filled.
If the capture is successful, the compositor fills the buffer with the screen data and sends a ready event to the client. This event signals that the buffer's contents are valid and can be read. If the capture fails for any reason, the compositor sends a failed event.
This protocol supports capturing entire outputs or specific regions, optionally overlaying the cursor, and includes optimizations like damage tracking, which allows the compositor to copy only the regions of the screen that have changed since the last frame.

Case Study in Fragmentation: Competing Protocols

The limitations and wlroots-specific nature of wlr-screencopy have led other projects to develop their own, incompatible solutions.
COSMIC Screencopy (cosmic-screencopy-unstable-v2): Developed by System76 for the COSMIC desktop environment, this protocol serves the same purpose but with a completely different API. It uses distinct requests like capture_frame_with_cursor and events like stopped, making an application written for wlr-screencopy entirely unable to function on a COSMIC compositor without significant modification.
Hyprland-Specific Protocols (hyprland-toplevel-export-v1): Even within the wlroots family, fragmentation exists. Hyprland maintains its own repository of custom protocols to enable unique features. The hyprland-toplevel-export-v1 protocol was created specifically to allow the capture of individual windows (known as "toplevels"), a capability not present in early versions of wlr-screencopy. This demonstrates how even closely related compositors diverge to meet application demands, further complicating portability.

The Standardization Horizon: ext-image-copy-capture-v1

The Wayland ecosystem is slowly maturing and consolidating around common standards. In a significant step forward, the ext-image-copy-capture-v1 protocol has been officially merged into the wayland-protocols repository, intended to supersede wlr-screencopy. This new protocol standardizes features that were previously handled by compositor-specific extensions, offering native support for capturing toplevels (windows) and the cursor, along with improved damage tracking mechanisms.
This development has a clear implication: building a new application today on wlr-screencopy-unstable-v1 means building on a legacy protocol that is actively being replaced. This provides a strong technical justification for migrating to a more modern and future-proof solution. The history of these protocols reflects a direct response to evolving application requirements. Initial tools needed only basic output capture, which wlr-screencopy provided. As demand grew for more advanced features like window sharing in communication apps, a feature gap emerged. Compositors like Hyprland filled this gap with custom protocols, forcing applications to write compositor-specific code. The official standardization of ext-image-copy-capture-v1 and the parallel rise of the high-level xdg-desktop-portal framework represent the ecosystem's solution to this fragmentation. An application's use of a component like ScreencopyView, which is likely built directly on wlr-screencopy, is a fossil record of an earlier era in Wayland's development. Porting presents an opportunity to modernize the application's architecture to align with the current, more stable standards.

Comparative Architectural Analysis: Hyprland vs. Niri

A successful port requires understanding the architectural differences between the source and target environments.

Hyprland: The wlroots Archetype

Hyprland is a dynamic tiling Wayland compositor built upon the wlroots library, a set of modular components designed to facilitate the creation of compositors. Its build configuration explicitly includes wlr-screencopy-unstable-v1.xml as a core protocol, confirming native, first-party support. Beyond the standard wlroots protocols, Hyprland bundles its own set of extensions (hyprland-protocols) to provide unique functionality such as advanced window management and visual effects, creating a distinct "Hyprland environment". For high-level, application-agnostic screen sharing, Hyprland provides and recommends the use of its xdg-desktop-portal-hyprland backend.

Niri: The Smithay-Powered Challenger

Niri is a scrollable-tiling Wayland compositor built on Smithay, a comprehensive library for creating compositors written in Rust. This places it in a different technological lineage from the C-based wlroots ecosystem. Despite this, the official Niri documentation makes a critical statement regarding compatibility: "Wlr protocols: yes, we have most of the important ones like layer-shell, gamma-control, screencopy". This is further clarified on its screencasting documentation page: "Alternatively, you can use tools that rely on the wlr-screencopy protocol, which niri also supports". This support is not achieved by using wlroots code but is a complete re-implementation of the protocol's wire format and semantics within Niri's Smithay-based architecture. Like Hyprland, Niri's primary and recommended method for screen capture is through the desktop portal framework, for which it requires the xdg-desktop-portal-gnome backend.

Potential Porting Friction Points

Given that both compositors support the wlr-screencopy protocol, any incompatibility must arise from more subtle implementation details.
Buffer Formats and Modifiers: While the protocol for negotiating buffers is the same, the specific formats and DMA-BUF modifiers advertised by the compositors may differ. This is dependent on the underlying graphics drivers (e.g., Mesa) and hardware. An application that makes hardcoded assumptions about available formats based on its experience with Hyprland may fail when Niri offers a different set. Commits in the quickshell repository related to DMA-BUF planes and modifiers suggest its ScreencopyView component operates at this low level, making it highly susceptible to such variations.
Timing and Synchronization: The internal event loops and frame rendering lifecycles of Hyprland and Niri are different. This can lead to subtle timing variations in the delivery of Wayland events. A race condition in the application's logic that was never triggered on Hyprland might be exposed by the different event timing on Niri.
Dependencies on Other Protocols: The application or the ScreencopyView component might implicitly rely on other wlroots-specific protocols (e.g., wlr-output-management-unstable-v1 to enumerate displays before initiating a capture). If Niri does not provide a compatibility implementation for these other protocols, the application's logic will fail.

Protocol and Feature Compatibility Matrix


Feature / Protocol
Hyprland Support
Niri Support
Notes & Implications for Porting
Compositor Toolkit
wlroots (C)
Smithay (Rust)
Fundamental architectural differences. Expect subtle behavioral variations even with compatible protocols.
wlr-screencopy-unstable-v1
Yes (Native)
Yes (Compatibility)
The core protocol is compatible. Incompatibility likely lies in implementation details or other dependencies.
hyprland-toplevel-export-v1
Yes
No
Application features relying on Hyprland-specific protocols will break and must be re-implemented.
ext-image-copy-capture-v1
Partial/In Progress
Likely, via Smithay updates
This is the future standard, but support is still emerging. Not a reliable target for porting today.
xdg-desktop-portal Backend
xdg-desktop-portal-hyprland
xdg-desktop-portal-gnome
Both fully support the portal standard. This is the most portable and robust path.
Primary Capture Method
xdg-desktop-portal
xdg-desktop-portal
Both compositors guide users towards the high-level portal, signaling it as the preferred method.


The Modern Solution: The xdg-desktop-portal Framework

The most effective way to resolve the porting issue and ensure long-term stability is to move away from direct protocol interaction and adopt the xdg-desktop-portal framework.

Architectural Overview

The portal is a standardized D-Bus API that functions as a trusted intermediary between sandboxed (or unsandboxed) applications and the compositor.1 Its primary purpose is to handle security-sensitive operations, like file access and screen capture, in a controlled manner. For application developers, the portal's key benefit is that it abstracts away all compositor-specific implementation details. An application makes a generic D-Bus call, and the portal backend (e.g.,
xdg-desktop-portal-hyprland or xdg-desktop-portal-gnome) handles the specifics of communicating with its host compositor and presenting a native user interface for permissions. This design completely solves the protocol fragmentation problem from the application's perspective.

The End-to-End Screen Capture Flow

The process of capturing the screen via the portal involves coordination between the application, D-Bus, the portal backend, the compositor, and the PipeWire multimedia framework.
Application Request: The application uses a D-Bus library to make a method call to org.freedesktop.portal.ScreenCast.CreateSession on the well-known org.freedesktop.portal.Desktop bus name.
Portal Routing: The system's D-Bus daemon activates the xdg-desktop-portal service. This service inspects the XDG_CURRENT_DESKTOP environment variable to determine which backend to use and forwards the request accordingly (e.g., to xdg-desktop-portal-gnome when running on Niri).
User Interaction: The portal backend communicates with the compositor (Niri) to retrieve a list of capturable sources (monitors and windows). It then displays a dialog, native to the desktop environment, asking the user to select a source and grant permission.
PipeWire Integration: Once the user grants permission, the backend orchestrates the creation of a media stream with the compositor via PipeWire, a low-level framework for routing video and audio. The portal receives a file descriptor that provides access to this PipeWire stream.
Application Connection: The portal sends this file descriptor and associated stream metadata back to the application in the D-Bus response.
Stream Consumption: The application uses a PipeWire client library to connect to the stream using the provided file descriptor and begins receiving video frames.
The org.freedesktop.portal.ScreenCast D-Bus interface provides several key methods for this process, including CreateSession to begin, SelectSources to configure options like whether to capture windows or monitors, and Start to trigger the user permission dialog.

Screencopy Methodologies: A Comparative Analysis


Criterion
Direct Protocol (wlr-screencopy)
Portal Framework (xdg-desktop-portal)
Portability
Low. Tied to a specific compositor family (wlroots). Requires compatibility layers on others (like Niri), which may be imperfect or removed in the future.
High. Works on any Wayland compositor with a portal backend (GNOME, KDE, Sway, Hyprland, Niri, etc.). The application code is identical everywhere.
Security
Low. The client has a direct handle to copy screen contents. There is no standardized permission model; the compositor simply allows or denies the connection.
High. Mediated by a trusted system service. The user is presented with a clear, standardized permission dialog. The application never has direct access to the screen buffer, only to the resulting PipeWire stream.
Feature Set
Limited. wlr-screencopy v1/v2 lacks standardized window capture. Requires compositor-specific extensions.
Rich. Standardized support for monitor, window, and region capture, cursor modes, and persistent permissions.
Implementation Complexity
High. Requires manual Wayland object management, buffer negotiation (SHM/DMA-BUF), and synchronization. Highly error-prone.
Medium. Requires a D-Bus library to make the initial request and a PipeWire library to consume the stream. The complex parts (UI, compositor interaction) are handled by the portal.
Future-Proofing
Poor. wlr-screencopy is being superseded by ext-image-copy-capture and is considered a legacy protocol.
Excellent. This is the officially sanctioned and actively developed path forward for this functionality across all major desktop environments.


Developer Implementation Guide: Porting Your Application

Two paths can be taken to resolve the issue: a short-term debugging effort or a long-term architectural migration.

Path A: Debugging the Existing wlr-screencopy Implementation

This approach aims for a minimal-effort fix and should be attempted before committing to a full migration.
Verify Protocol Advertisement: Use a command-line tool like wayland-info or inspect the compositor's startup logs to confirm that Niri is correctly advertising the zwlr_screencopy_manager_v1 global interface in your session.
Enable Wayland Debugging: Launch the application with the WAYLAND_DEBUG=1 environment variable. This will print every Wayland protocol message to stderr. Run the application on both Hyprland and Niri and compare the message flows side-by-side. Look for any protocol error events or unexpected message sequences on Niri.
Analyze Buffer Constraints: Modify the application to log the contents of the buffer events it receives from the compositor on both platforms. Pay close attention to the supported formats (e.g., wl_shm, linux_dmabuf), FourCC codes, and DMA-BUF modifiers. The incompatibility may be as simple as the application attempting to create a buffer with a format/modifier combination that Hyprland supports but Niri does not. The development history of the quickshell project suggests this is a likely point of failure.
Check for Other Protocol Dependencies: Scrutinize the source code of ScreencopyView and any related components. Identify if it uses any other wlr- or hyprland- specific protocols that Niri may not implement.

Path B: Migrating to xdg-desktop-portal and PipeWire (Recommended)

This path involves re-architecting the screen capture feature to use modern, portable APIs.
Initiate the Portal Request via D-Bus:
Integrate a D-Bus client library (e.g., sd-bus, GDBus, QtDBus) into the application.
Connect to the user's session bus and construct an asynchronous method call to the org.freedesktop.portal.ScreenCast.Start method on the /org/freedesktop/portal/desktop object path. The method's arguments can be used to configure the session, such as specifying that both monitor and window capture should be available (types = 3) and that the cursor should be embedded in the stream (cursor_mode = 2).
Handle the Portal Response:
The D-Bus call will return asynchronously via a signal. The response for a successful Start call will contain a variant dictionary (a{sv}).
Extract the PipeWire Stream Information:
From the response dictionary, parse the streams array. Each element in this array represents a capturable stream and contains its own properties. The essential property is the PipeWire node ID, which identifies the source node in the PipeWire graph. The portal will also return a file descriptor that grants access to the PipeWire context.
Consume the PipeWire Video Stream:
Use a PipeWire client library (e.g., libpipewire) to manage the connection.
Initialize a connection to the PipeWire daemon using the file descriptor provided by the portal.
Create a pw_stream object. Its properties must identify the application as a video consumer and set the PW_KEY_TARGET_OBJECT property to the node ID received from the portal.
Connect the stream with PW_DIRECTION_INPUT.
Implement callbacks for stream events. The param_changed callback is used to learn the video format (dimensions, pixel format), and the process callback is the core of the capture loop.
Inside the process callback, call pw_stream_dequeue_buffer() to receive a buffer containing a video frame. The frame data will be located in a field like b->buffer->datas.data. After processing the frame, call pw_stream_queue_buffer() to return the buffer to PipeWire for reuse.

Conclusion and Strategic Recommendations

The initial information suggesting a fundamental incompatibility between the application's ScreencopyView component and the Niri compositor is, at its core, misleading. The Niri compositor does provide a compatibility implementation for the wlr-screencopy-unstable-v1 protocol. The porting issue is not due to a missing protocol but almost certainly stems from a more subtle incompatibility in its implementation or a hidden dependency on another Hyprland-specific feature within the application's codebase.
However, relying on this compatibility layer is a fragile and high-maintenance strategy. The wlr-screencopy protocol is a legacy technology being actively superseded by the standardized ext-image-copy-capture-v1 protocol. Basing an application on a non-native, reverse-engineered implementation of a legacy protocol exposes it to future breakage should Niri's developers modify or deprecate that compatibility layer.
The most robust, portable, and secure solution is to undertake a one-time architectural migration of the application's screen capture functionality. It is strongly recommended to refactor the ScreencopyView component and its surrounding logic to use the xdg-desktop-portal D-Bus interface for initiating the capture session and the PipeWire client library for consuming the resulting video stream. This approach will align the application with the modern Wayland standard, guarantee compatibility across the vast majority of current and future compositors, and provide a superior security model for the end-user. While this migration requires a greater upfront development investment than debugging the current implementation, it will significantly reduce long-term maintenance costs and eliminate this entire class of compositor-specific porting problems.
Works cited
XDG Desktop Portal - ArchWiki, accessed June 15, 2025, https://wiki.archlinux.org/title/XDG_Desktop_Portal
