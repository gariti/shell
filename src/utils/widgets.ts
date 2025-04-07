import { Binding } from "astal";
import { Astal, astalify, Gtk, hook, Widget } from "astal/gtk4";
import AstalHyprland from "gi://AstalHyprland";

export const setupCustomTooltip = (
    self: JSX.Element,
    text: string | Binding<string>,
    labelProps: Widget.LabelProps = {}
) => {
    return;
    if (!text) return null;

    self.set_has_tooltip(true);

    const window = new Widget.Window({
        visible: false,
        namespace: "caelestia-tooltip",
        layer: Astal.Layer.OVERLAY,
        keymode: Astal.Keymode.NONE,
        exclusivity: Astal.Exclusivity.IGNORE,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT,
        child: new Widget.Label({ ...labelProps, className: "tooltip", label: text }),
    });
    self.set_tooltip_window(window);

    if (text instanceof Binding) self.hook(text, (_, v) => !v && window.hide());

    const positionWindow = ({ x, y }: { x: number; y: number }) => {
        const { width: mWidth, height: mHeight } = AstalHyprland.get_default().get_focused_monitor();
        const { width: pWidth, height: pHeight } = window.get_preferred_size()[1]!;
        const cursorSize = Gtk.Settings.get_default()?.gtkCursorThemeSize ?? 0;

        let marginLeft = x - pWidth / 2;
        if (marginLeft < 0) marginLeft = 0;
        else if (marginLeft + pWidth > mWidth) marginLeft = mWidth - pWidth;

        let marginTop = y + cursorSize;
        if (marginTop < 0) marginTop = 0;
        else if (marginTop + pHeight > mHeight) marginTop = y - pHeight;

        window.marginLeft = marginLeft;
        window.marginTop = marginTop;
    };

    let lastPos = { x: 0, y: 0 };

    window.connect("size-allocate", () => positionWindow(lastPos));
    self.connect("query-tooltip", () => {
        if (text instanceof Binding && !text.get()) return false;
        if (window.visible) return true;

        const cPos = AstalHyprland.get_default().get_cursor_position();
        positionWindow(cPos);
        lastPos = cPos;

        return true;
    });

    self.connect("destroy", () => window.destroy());

    return window;
};

export const setupChildClickthrough = (self: JSX.Element) =>
    self.connect("size-allocate", () => self.get_window()?.set_child_input_shapes());

const providers = new Map<JSX.Element, Gtk.CssProvider>();

const normaliseCss = (css: string) => (css.includes("{") || css.includes("}") ? css : `* { ${css} }`);

export const getCss = (self: JSX.Element) => providers.get(self) ?? "";

export const setCss = (self: JSX.Element, css: string | Binding<string>) => {
    if (providers.has(self)) {
        const p = providers.get(self)!;
        providers.delete(self);
        self.get_style_context().remove_provider(p);
        p.run_dispose();
    } else {
        self.connect("destroy", () => providers.delete(self));
    }

    const provider = new Gtk.CssProvider();
    self.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
    providers.set(self, provider);

    if (typeof css === "string") {
        css = normaliseCss(css);
        provider.load_from_data(css, css.length);
    } else {
        hook(self, css, (_, v) => {
            v = normaliseCss(v);
            provider.load_from_data(v, v.length);
        });
    }
};

export const toggleClassName = (self: JSX.Element, className: string, value: boolean) => {
    if (value) self.add_css_class(className);
    else self.remove_css_class(className);
};

export const FlowBox = astalify(Gtk.FlowBox);
